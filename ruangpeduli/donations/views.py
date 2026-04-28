from datetime import date

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from .models import Donasi
from .serializers import DonasiSerializer


class DonasiListCreateView(APIView):
    """
    GET  /api/donations/  → list donations by the logged-in user (requires JWT)
    POST /api/donations/  → create donation (requires JWT)
      Body: { panti_id?, nama_panti?, jumlah, metode_pembayaran?, no_referensi? }
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        donasi = Donasi.objects.filter(user=request.user).order_by('-tanggal')
        serializer = DonasiSerializer(donasi, many=True, context={'request': request})
        return Response(serializer.data)

    def post(self, request):
        panti_id   = request.data.get('panti_id')
        nama_panti = request.data.get('nama_panti', '')
        jumlah     = request.data.get('jumlah')
        metode     = request.data.get('metode_pembayaran', '')
        no_ref     = request.data.get('no_referensi', '')

        if jumlah is None:
            return Response({'error': 'jumlah wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)

        panti = None
        if panti_id:
            try:
                from profiles.models import OrphanageProfile
                panti = OrphanageProfile.objects.get(id=panti_id)
                if not nama_panti:
                    nama_panti = panti.nama_panti
            except Exception:
                pass

        jumlah_int = int(jumlah)

        donasi = Donasi.objects.create(
            user=request.user,
            panti=panti,
            nama_panti=nama_panti,
            jumlah=jumlah_int,
            metode_pembayaran=metode,
            no_referensi=no_ref,
        )

        if panti is not None:
            try:
                from finance.models import JenisPemasukan, Pemasukan
                jenis, _ = JenisPemasukan.objects.get_or_create(
                    panti=panti,
                    nama='Donasi Masyarakat',
                )
                Pemasukan.objects.create(
                    panti=panti,
                    jenis_pemasukan=jenis,
                    jumlah=jumlah_int,
                    tanggal=date.today(),
                    catatan=f'@{request.user.username}',
                )
            except Exception:
                pass

        return Response(
            DonasiSerializer(donasi, context={'request': request}).data,
            status=status.HTTP_201_CREATED,
        )
