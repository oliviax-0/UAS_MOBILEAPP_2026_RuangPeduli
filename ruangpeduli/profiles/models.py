from django.db import models
from accounts.models import User


class SocietyProfile(models.Model):
    """Profile untuk role masyarakat"""
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='society_profile'
    )
    nama_pengguna = models.CharField(max_length=255)
    alamat = models.TextField()
    nomor_telepon = models.CharField(max_length=20, blank=True)
    jenis_kelamin = models.CharField(max_length=20, blank=True)
    profile_picture = models.ImageField(upload_to='masyarakat/profile/', blank=True, null=True)

    def __str__(self):
        return f"{self.nama_pengguna} ({self.user.email})"


class OrphanageProfile(models.Model):
    """Profile untuk role panti"""
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='orphanage_profile'
    )
    nama_panti = models.CharField(max_length=255)
    alamat_panti = models.TextField()
    nomor_panti = models.CharField(max_length=20)
    profile_picture = models.ImageField(upload_to='panti/profile/', blank=True, null=True)
    description = models.TextField(blank=True)
    provinsi = models.CharField(max_length=100, blank=True)
    kabupaten_kota = models.CharField(max_length=100, blank=True)
    kecamatan = models.CharField(max_length=100, blank=True)
    kelurahan = models.CharField(max_length=100, blank=True)
    kode_pos = models.CharField(max_length=10, blank=True)
    lat = models.FloatField(null=True, blank=True)
    lng = models.FloatField(null=True, blank=True)

    def __str__(self):
        return f"{self.nama_panti} ({self.user.email})"


class PantiMedia(models.Model):
    """Foto & Video gallery on panti profile page."""
    MEDIA_TYPES = [('photo', 'Photo'), ('video', 'Video')]

    panti = models.ForeignKey(
        OrphanageProfile,
        on_delete=models.CASCADE,
        related_name='media'
    )
    media_type  = models.CharField(max_length=10, choices=MEDIA_TYPES)
    file        = models.FileField(upload_to='panti/media/', blank=True, null=True)
    video_url   = models.URLField(blank=True)
    title       = models.CharField(max_length=200, blank=True, default='')
    description = models.TextField(blank=True, default='')
    order       = models.PositiveIntegerField(default=0)
    created_at  = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['order', '-created_at']

    def __str__(self):
        return f"{self.media_type} — {self.panti.nama_panti}"