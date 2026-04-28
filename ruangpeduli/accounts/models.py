from django.contrib.auth.models import AbstractUser
from django.db import models
import uuid

class User(AbstractUser):
    ROLE_CHOICES = [
        ('masyarakat', 'Masyarakat'),
        ('panti', 'Panti Sosial'),
    ]
    role = models.CharField(max_length=20, choices=ROLE_CHOICES)

    def __str__(self):
        return f"{self.username} ({self.role})"

    @property
    def profile(self):
        """Ambil profile sesuai role user"""
        if self.role == 'masyarakat':
            return getattr(self, 'society_profile', None)
        elif self.role == 'panti':
            return getattr(self, 'orphanage_profile', None)
        return None

    @property
    def nama(self):
        """Ambil nama sesuai role"""
        if self.role == 'masyarakat':
            p = getattr(self, 'society_profile', None)
            return p.nama_pengguna if p else self.username
        elif self.role == 'panti':
            p = getattr(self, 'orphanage_profile', None)
            return p.nama_panti if p else self.username
        return self.username


class PendingRegistration(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(max_length=150, default='')
    email = models.EmailField()
    password = models.CharField(max_length=255, default='')
    role = models.CharField(max_length=20, default='masyarakat')

    # Masyarakat
    nama_pengguna = models.CharField(max_length=255, null=True, blank=True)
    alamat = models.TextField(null=True, blank=True)
    nomor_telepon = models.CharField(max_length=20, null=True, blank=True)

    # Panti
    nama_panti = models.CharField(max_length=255, null=True, blank=True)
    alamat_panti = models.TextField(null=True, blank=True)
    nomor_panti = models.CharField(max_length=20, null=True, blank=True)
    provinsi_panti = models.CharField(max_length=100, null=True, blank=True)
    kabupaten_kota_panti = models.CharField(max_length=100, null=True, blank=True)
    kecamatan_panti = models.CharField(max_length=100, null=True, blank=True)
    kelurahan_panti = models.CharField(max_length=100, null=True, blank=True)
    kode_pos_panti = models.CharField(max_length=10, null=True, blank=True)
    lat_panti = models.FloatField(null=True, blank=True)
    lng_panti = models.FloatField(null=True, blank=True)

    # OTP
    otp_code = models.CharField(max_length=5, null=True, blank=True)
    expires_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.email} - {self.role} (pending)"


class PasswordResetPending(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField()
    otp_code = models.CharField(max_length=5)
    expires_at = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.email} (reset pending)"