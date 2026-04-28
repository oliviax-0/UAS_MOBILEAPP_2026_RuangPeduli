from django.db import models
from accounts.models import User


class Donasi(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='donasi')
    panti = models.ForeignKey(
        'profiles.OrphanageProfile',
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='donasi_masuk',
    )
    nama_panti = models.CharField(max_length=255)          # snapshot nama panti
    jumlah = models.IntegerField()                          # nominal donasi (tanpa admin fee)
    metode_pembayaran = models.CharField(max_length=50, blank=True)
    no_referensi = models.CharField(max_length=50, blank=True)
    tanggal = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-tanggal']

    def __str__(self):
        return f'{self.user} → {self.nama_panti} Rp{self.jumlah}'
