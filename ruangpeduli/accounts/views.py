from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from django.utils import timezone
from datetime import timedelta
from django.conf import settings
from django.core.mail import send_mail
import random
import string
from django.db import transaction, IntegrityError
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from accounts.models import User, PendingRegistration, PasswordResetPending
from .serializers import RegisterStartSerializer

def _get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


OTP_HTML = """
    <div style="font-family: Arial, sans-serif; max-width: 420px;
                margin: auto; padding: 24px;">
        <h2 style="color: #F43D5E; margin-bottom: 4px;">RuangPeduli</h2>
        <p style="color: #555; margin-bottom: 24px;">
            Halo! Berikut kode OTP untuk verifikasi akun kamu:
        </p>
        <div style="font-size: 38px; font-weight: bold;
                    letter-spacing: 10px; color: #F43D5E;
                    text-align: center; padding: 20px 0;
                    background: #FFF0F2;
                    border-radius: 10px; margin-bottom: 20px;">
            {otp}
        </div>
        <p style="color: #888; font-size: 13px; line-height: 1.6;">
            Kode ini berlaku selama <b>5 menit</b>.<br>
            Jangan bagikan kode ini kepada siapapun.
        </p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
        <p style="color: #bbb; font-size: 11px;">
            Jika kamu tidak merasa mendaftar di RuangPeduli, abaikan email ini.
        </p>
    </div>
"""


def _verify_google_token(token: str):
    """Try verifying against all registered client IDs."""
    client_ids = [c for c in [
        settings.GOOGLE_CLIENT_ID,
    ] if c]
    last_error = None
    for client_id in client_ids:
        try:
            return id_token.verify_oauth2_token(token, google_requests.Request(), client_id)
        except ValueError as e:
            last_error = e
    raise ValueError(last_error)


def _send_otp_email(email: str, otp: str) -> bool:
    try:
        send_mail(
            subject="Kode OTP RuangPeduli",
            message=f"Kode OTP kamu: {otp}\nBerlaku selama 5 menit.",
            from_email=f"RuangPeduli <{settings.EMAIL_HOST_USER}>",
            recipient_list=[email],
            fail_silently=False,
            html_message=OTP_HTML.format(otp=otp),
        )
        print(f"✅ Email terkirim via Gmail SMTP ke {email}")
        return True
    except Exception as e:
        print(f"⚠️ Gmail SMTP error: {e}")
        return False

class RegisterStartView(generics.CreateAPIView):
    queryset = PendingRegistration.objects.all()
    serializer_class = RegisterStartSerializer
    permission_classes = [permissions.AllowAny]

    def create(self, request, *args, **kwargs):
        email = request.data.get('email')
        username = request.data.get('username')

        # ✅ Cek email + role sudah terdaftar di User
        role = request.data.get('role')
        if User.objects.filter(email=email, role=role).exists():
            return Response(
                {'error': 'Email sudah terdaftar untuk role ini, silakan login'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # ✅ Cek username sudah dipakai
        if User.objects.filter(username=username).exists():
            return Response(
                {'error': 'Username sudah digunakan'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Lanjut proses normal
        return super().create(request, *args, **kwargs)

    def perform_create(self, serializer):
        # Hapus pending lama dengan email yang sama
        PendingRegistration.objects.filter(
            email=serializer.validated_data['email']
        ).delete()

        pending = serializer.save()

        otp = ''.join(random.choices(string.digits, k=5))
        pending.otp_code = otp
        pending.expires_at = timezone.now() + timedelta(minutes=5)
        pending.save()

        print(f"{'='*40}")
        print(f"📧 Email  : {pending.email}")
        print(f"🔑 OTP    : {otp}")
        print(f"⏰ Expires: {pending.expires_at}")
        print(f"🆔 ID     : {pending.id}")
        print(f"{'='*40}")

        sent = _send_otp_email(pending.email, otp)
        if sent:
            print(f"✅ Email OTP berhasil dikirim ke {pending.email}")
        else:
            print(f"⚠️ Email gagal, gunakan OTP dari log: {otp}")

class VerifyOtpView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        pending_id = request.data.get('pending_id')
        otp = request.data.get('otp')

        if not pending_id or not otp:
            return Response(
                {'error': 'pending_id dan otp wajib diisi'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            pending = PendingRegistration.objects.get(id=pending_id)
        except PendingRegistration.DoesNotExist:
            return Response(
                {'error': 'Sesi registrasi tidak ditemukan, silakan daftar ulang'},
                status=status.HTTP_404_NOT_FOUND
            )

        # ❌ OTP expired → hapus pending
        if pending.expires_at is None or timezone.now() > pending.expires_at:
            pending.delete()  # ← HAPUS
            return Response(
                {'error': 'OTP sudah expired, silakan daftar ulang'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # ❌ OTP salah → biarkan pending, user bisa coba lagi
        if pending.otp_code != otp:
            return Response(
                {'error': 'OTP salah, silakan coba lagi'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # ✅ OTP benar → buat user
        try:
            with transaction.atomic():
                user = User.objects.create(
                    username=pending.username,
                    email=pending.email,
                    password=pending.password,
                    role=pending.role,
                )

                if pending.role == 'masyarakat':
                    from profiles.models import SocietyProfile
                    SocietyProfile.objects.create(
                        user=user,
                        nama_pengguna=pending.nama_pengguna,
                        alamat=pending.alamat,
                        nomor_telepon=pending.nomor_telepon or '',
                    )
                elif pending.role == 'panti':
                    from profiles.models import OrphanageProfile
                    OrphanageProfile.objects.create(
                        user=user,
                        nama_panti=pending.nama_panti,
                        alamat_panti=pending.alamat_panti,
                        nomor_panti=pending.nomor_panti,
                        provinsi=pending.provinsi_panti or '',
                        kabupaten_kota=pending.kabupaten_kota_panti or '',
                        kecamatan=pending.kecamatan_panti or '',
                        kelurahan=pending.kelurahan_panti or '',
                        kode_pos=pending.kode_pos_panti or '',
                        lat=pending.lat_panti,
                        lng=pending.lng_panti,
                    )

                pending.delete()  # ← hapus pending setelah berhasil
                print(f"✅ User {user.username} berhasil dibuat!")

        except IntegrityError:
            pending.delete()  # ← hapus pending kalau duplikat
            return Response(
                {'error': 'Username atau email sudah digunakan, silakan daftar ulang'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            pending.delete()  # ← hapus pending kalau error lain
            return Response(
                {'error': f'Terjadi kesalahan: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        panti_id = None
        if user.role == 'panti':
            from profiles.models import OrphanageProfile
            try:
                panti_id = OrphanageProfile.objects.get(user=user).id
            except OrphanageProfile.DoesNotExist:
                pass

        tokens = _get_tokens_for_user(user)
        return Response(
            {
                'success': True,
                'message': 'Registrasi berhasil!',
                'user_id': user.id,
                'username': user.username,
                'role': user.role,
                'panti_id': panti_id,
                **tokens,
            },
            status=status.HTTP_201_CREATED
        )
    
class LoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        email = request.data.get('email')
        password = request.data.get('password')
        role = request.data.get('role')

        if not email or not password or not role:
            return Response(
                {'error': 'Email, sandi, dan role wajib diisi'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            user = User.objects.get(email=email, role=role)
        except User.DoesNotExist:
            return Response(
                {'error': 'Email atau sandi salah'},
                status=status.HTTP_401_UNAUTHORIZED
            )

        if not user.check_password(password):
            return Response(
                {'error': 'Email atau sandi salah'},
                status=status.HTTP_401_UNAUTHORIZED
            )

        panti_id = None
        if user.role == 'panti':
            from profiles.models import OrphanageProfile
            try:
                panti_id = OrphanageProfile.objects.get(user=user).id
            except OrphanageProfile.DoesNotExist:
                pass

        tokens = _get_tokens_for_user(user)
        return Response({
            'success': True,
            'user_id': user.id,
            'username': user.username,
            'email': user.email,
            'role': user.role,
            'panti_id': panti_id,
            **tokens,
        }, status=status.HTTP_200_OK)


class ForgotPasswordRequestView(APIView):
    """
    POST /api/forgot-password/
    Body: { "email": "..." }
    Sends OTP to email if user exists.
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        email = request.data.get('email', '').strip()
        if not email:
            return Response({'error': 'Email wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)

        if not User.objects.filter(email=email).exists():
            return Response({'error': 'Email tidak terdaftar'}, status=status.HTTP_404_NOT_FOUND)

        # Delete any previous reset pending for this email
        PasswordResetPending.objects.filter(email=email).delete()

        otp = ''.join(random.choices(string.digits, k=5))
        pending = PasswordResetPending.objects.create(
            email=email,
            otp_code=otp,
            expires_at=timezone.now() + timedelta(minutes=5),
        )

        print(f"{'='*40}")
        print(f"📧 Reset email : {email}")
        print(f"🔑 OTP         : {otp}")
        print(f"⏰ Expires     : {pending.expires_at}")
        print(f"{'='*40}")

        sent = _send_otp_email(email, otp)
        if not sent:
            return Response({'error': 'Gagal mengirim email, coba lagi'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response({'message': 'Kode OTP telah dikirim ke email kamu'}, status=status.HTTP_200_OK)


class ForgotPasswordResetView(APIView):
    """
    POST /api/reset-password/
    Body: { "email": "...", "otp": "...", "new_password": "..." }
    Verifies OTP and resets password for all accounts with that email.
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        email = request.data.get('email', '').strip()
        otp = request.data.get('otp', '').strip()
        new_password = request.data.get('new_password', '')

        if not email or not otp or not new_password:
            return Response({'error': 'Email, OTP, dan sandi baru wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)

        import re
        if len(new_password) < 6:
            return Response({'error': 'Sandi minimal 6 karakter'}, status=status.HTTP_400_BAD_REQUEST)
        if not re.search(r'[A-Z]', new_password):
            return Response({'error': 'Sandi harus mengandung minimal 1 huruf kapital'}, status=status.HTTP_400_BAD_REQUEST)
        if not re.search(r'\d', new_password):
            return Response({'error': 'Sandi harus mengandung minimal 1 angka'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            pending = PasswordResetPending.objects.get(email=email)
        except PasswordResetPending.DoesNotExist:
            return Response({'error': 'Sesi reset tidak ditemukan, silakan minta OTP lagi'}, status=status.HTTP_404_NOT_FOUND)

        if timezone.now() > pending.expires_at:
            pending.delete()
            return Response({'error': 'OTP sudah expired, silakan minta OTP lagi'}, status=status.HTTP_400_BAD_REQUEST)

        if pending.otp_code != otp:
            return Response({'error': 'OTP salah, silakan coba lagi'}, status=status.HTTP_400_BAD_REQUEST)

        # Reset password for all accounts with this email
        users = User.objects.filter(email=email)
        for user in users:
            user.set_password(new_password)
            user.save()

        pending.delete()
        print(f"✅ Password reset untuk {email} ({users.count()} akun)")

        return Response({'message': 'Sandi berhasil direset. Silakan login.'}, status=status.HTTP_200_OK)


class ResendOtpView(APIView):
    """
    POST /api/resend-otp/
    Kirim ulang OTP ke email yang sama.
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        email = request.data.get('email')

        if not email:
            return Response(
                {'error': 'Email wajib diisi'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            pending = PendingRegistration.objects.get(email=email)
        except PendingRegistration.DoesNotExist:
            return Response(
                {'error': 'Email tidak ditemukan'},
                status=status.HTTP_404_NOT_FOUND
            )

        # Generate OTP baru
        otp = ''.join(random.choices(string.digits, k=5))
        pending.otp_code = otp
        pending.expires_at = timezone.now() + timedelta(minutes=5)
        pending.save()

        print(f"🔄 Resend OTP ke {email}: {otp}")

        sent = _send_otp_email(email, otp)
        if not sent:
            return Response(
                {'error': 'Gagal mengirim email, coba lagi'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        return Response(
            {'message': 'OTP baru telah dikirim ke email kamu'},
            status=status.HTTP_200_OK
        )

class ChangePasswordView(APIView):
    """
    POST /api/change-password/
    Header: Authorization: Bearer <access_token>
    Body: { "current_password": "...", "new_password": "..." }
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        current_password = request.data.get('current_password', '').strip()
        new_password     = request.data.get('new_password', '').strip()

        if not current_password or not new_password:
            return Response({'error': 'Semua kolom wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)

        if len(new_password) < 8:
            return Response({'error': 'Kata sandi baru minimal 8 karakter'}, status=status.HTTP_400_BAD_REQUEST)

        user = request.user
        if not user.check_password(current_password):
            return Response({'error': 'Kata sandi saat ini salah'}, status=status.HTTP_400_BAD_REQUEST)

        user.set_password(new_password)
        user.save()
        return Response({'success': True}, status=status.HTTP_200_OK)


class RequestEmailChangeView(APIView):
    """
    POST /api/request-email-change/
    Header: Authorization: Bearer <access_token>
    Sends OTP to user's current email so they can verify before changing it.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        user = request.user
        user_id = user.id

        key = f'emailchange:{user_id}'
        PasswordResetPending.objects.filter(email=key).delete()

        otp = ''.join(random.choices(string.digits, k=5))
        PasswordResetPending.objects.create(
            email=key,
            otp_code=otp,
            expires_at=timezone.now() + timedelta(minutes=5),
        )

        sent = _send_otp_email(user.email, otp)
        if not sent:
            return Response({'error': 'Gagal mengirim OTP, coba lagi'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response({'sent_to': user.email}, status=status.HTTP_200_OK)


class RequestNewEmailVerifyView(APIView):
    """
    POST /api/request-new-email-verify/
    Header: Authorization: Bearer <access_token>
    Body: { "otp_current": "12345", "new_email": "new@example.com" }
    Verifies OTP from current email, then sends a new OTP to the new email.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        user_id   = request.user.id
        otp_current = request.data.get('otp_current', '').strip()
        new_email = request.data.get('new_email', '').strip()

        if not otp_current or not new_email:
            return Response({'error': 'otp_current dan new_email wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)

        # Verify current email OTP
        key_old = f'emailchange:{user_id}'
        try:
            pending_old = PasswordResetPending.objects.get(email=key_old)
        except PasswordResetPending.DoesNotExist:
            return Response({'error': 'Sesi tidak ditemukan, kirim ulang OTP'}, status=status.HTTP_404_NOT_FOUND)

        if timezone.now() > pending_old.expires_at:
            pending_old.delete()
            return Response({'error': 'OTP sudah expired, kirim ulang OTP'}, status=status.HTTP_400_BAD_REQUEST)

        if pending_old.otp_code != otp_current:
            return Response({'error': 'OTP salah, silakan coba lagi'}, status=status.HTTP_400_BAD_REQUEST)

        # Check new email not already taken
        if User.objects.filter(email=new_email).exclude(pk=user_id).exists():
            return Response({'error': 'Email sudah digunakan akun lain'}, status=status.HTTP_400_BAD_REQUEST)

        # Send OTP to new email (user_id already set above from request.user.id)
        key_new = f'emailchange_new:{user_id}'
        PasswordResetPending.objects.filter(email=key_new).delete()
        otp_new = ''.join(random.choices(string.digits, k=5))
        PasswordResetPending.objects.create(
            email=key_new,
            otp_code=otp_new,
            expires_at=timezone.now() + timedelta(minutes=5),
        )

        sent = _send_otp_email(new_email, otp_new)
        if not sent:
            return Response({'error': 'Gagal mengirim OTP ke email baru, coba lagi'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # Clean up old OTP
        pending_old.delete()
        return Response({'sent_to': new_email}, status=status.HTTP_200_OK)


class ConfirmEmailChangeView(APIView):
    """
    POST /api/confirm-email-change/
    Header: Authorization: Bearer <access_token>
    Body: { "otp_new": "12345", "new_email": "new@example.com" }
    Verifies OTP sent to new email then updates email.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        user_id   = request.user.id
        otp_new   = request.data.get('otp_new', '').strip()
        new_email = request.data.get('new_email', '').strip()

        if not otp_new or not new_email:
            return Response({'error': 'otp_new dan new_email wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)

        key_new = f'emailchange_new:{user_id}'
        try:
            pending = PasswordResetPending.objects.get(email=key_new)
        except PasswordResetPending.DoesNotExist:
            return Response({'error': 'Sesi tidak ditemukan, mulai ulang proses ganti email'}, status=status.HTTP_404_NOT_FOUND)

        if timezone.now() > pending.expires_at:
            pending.delete()
            return Response({'error': 'OTP sudah expired, kirim ulang OTP'}, status=status.HTTP_400_BAD_REQUEST)

        if pending.otp_code != otp_new:
            return Response({'error': 'OTP salah, silakan coba lagi'}, status=status.HTTP_400_BAD_REQUEST)

        if User.objects.filter(email=new_email).exclude(pk=user_id).exists():
            return Response({'error': 'Email sudah digunakan akun lain'}, status=status.HTTP_400_BAD_REQUEST)

        user = request.user
        user.email = new_email
        user.save()
        pending.delete()

        return Response({'success': True, 'new_email': new_email}, status=status.HTTP_200_OK)


class GoogleAuthView(APIView):
    """
    POST /api/google-auth/
    Body: { "id_token": "...", "role": "masyarakat|panti" }
    Verify Google token. If user exists → login. If not → return email/name for registration.
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        token = request.data.get('id_token', '').strip()
        role  = request.data.get('role', '').strip()

        if not token or not role:
            return Response({'error': 'id_token dan role wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)

        if not settings.GOOGLE_CLIENT_ID and not settings.GOOGLE_CLIENT_ID_ANDROID:
            return Response({'error': 'Google Client ID belum dikonfigurasi'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        try:
            idinfo = _verify_google_token(token)
        except ValueError as e:
            return Response({'error': f'Token Google tidak valid: {str(e)}'}, status=status.HTTP_400_BAD_REQUEST)

        email = idinfo.get('email', '')
        name  = idinfo.get('name', '')

        user = User.objects.filter(email=email, role=role).first()

        if user:
            panti_id = None
            if user.role == 'panti':
                from profiles.models import OrphanageProfile
                try:
                    panti_id = OrphanageProfile.objects.get(user=user).id
                except OrphanageProfile.DoesNotExist:
                    pass
            tokens = _get_tokens_for_user(user)
            return Response({
                'exists': True,
                'user_id': user.id,
                'username': user.username,
                'email': user.email,
                'role': user.role,
                'panti_id': panti_id,
                **tokens,
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'exists': False,
                'email': email,
                'name': name,
            }, status=status.HTTP_200_OK)


class GoogleRegisterView(APIView):
    """
    POST /api/google-register/
    Create user directly from Google data — no OTP needed (Google already verified email).
    Body: { "id_token", "role", "username", "nama_pengguna"/"nama_panti", "alamat"/"alamat_panti", "nomor_panti" }
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        token    = request.data.get('id_token', '').strip()
        role     = request.data.get('role', '').strip()
        username = request.data.get('username', '').strip()

        if not token or not role or not username:
            return Response({'error': 'id_token, role, dan username wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)

        if not settings.GOOGLE_CLIENT_ID and not settings.GOOGLE_CLIENT_ID_ANDROID:
            return Response({'error': 'Google Client ID belum dikonfigurasi'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        try:
            idinfo = _verify_google_token(token)
        except ValueError as e:
            return Response({'error': f'Token Google tidak valid: {str(e)}'}, status=status.HTTP_400_BAD_REQUEST)

        email = idinfo.get('email', '')

        if User.objects.filter(email=email, role=role).exists():
            return Response({'error': 'Email sudah terdaftar untuk role ini, silakan login'}, status=status.HTTP_400_BAD_REQUEST)

        if User.objects.filter(username=username).exists():
            return Response({'error': 'Username sudah digunakan'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            with transaction.atomic():
                from django.contrib.auth.hashers import make_password
                user = User.objects.create(
                    username=username,
                    email=email,
                    password=make_password(None),  # unusable password — login via Google
                    role=role,
                )

                if role == 'masyarakat':
                    from profiles.models import SocietyProfile
                    SocietyProfile.objects.create(
                        user=user,
                        nama_pengguna=request.data.get('nama_pengguna', ''),
                        alamat=request.data.get('alamat', ''),
                        nomor_telepon=request.data.get('nomor_telepon', ''),
                    )
                elif role == 'panti':
                    from profiles.models import OrphanageProfile
                    profile = OrphanageProfile.objects.create(
                        user=user,
                        nama_panti=request.data.get('nama_panti', ''),
                        alamat_panti=request.data.get('alamat_panti', ''),
                        nomor_panti=request.data.get('nomor_panti', ''),
                        provinsi=request.data.get('provinsi_panti', ''),
                        kabupaten_kota=request.data.get('kabupaten_kota_panti', ''),
                        kecamatan=request.data.get('kecamatan_panti', ''),
                        kelurahan=request.data.get('kelurahan_panti', ''),
                        kode_pos=request.data.get('kode_pos_panti', ''),
                        lat=request.data.get('lat_panti'),
                        lng=request.data.get('lng_panti'),
                    )

            panti_id = profile.id if role == 'panti' else None
            tokens = _get_tokens_for_user(user)
            return Response({
                'success': True,
                'user_id': user.id,
                'username': user.username,
                'email': user.email,
                'role': user.role,
                'panti_id': panti_id,
                **tokens,
            }, status=status.HTTP_201_CREATED)

        except IntegrityError:
            return Response({'error': 'Username atau email sudah digunakan'}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'error': f'Terjadi kesalahan: {str(e)}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
