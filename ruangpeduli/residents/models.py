from django.db import models
from profiles.models import OrphanageProfile


class GenderChoice(models.TextChoices):
    LAKI_LAKI  = 'laki-laki',  'Laki-laki'
    PEREMPUAN  = 'perempuan',  'Perempuan'


class Penghuni(models.Model):
    """Resident (anak) yang tinggal di panti."""
    panti         = models.ForeignKey(OrphanageProfile, on_delete=models.CASCADE, related_name='penghuni')
    nama          = models.CharField(max_length=200)
    tahun_lahir   = models.PositiveIntegerField()
    jenis_kelamin = models.CharField(max_length=20, choices=GenderChoice.choices)

    class Meta:
        ordering = ['nama']

    def __str__(self):
        return f'{self.nama} ({self.tahun_lahir})'


class Pekerja(models.Model):
    """Pegawai / staf yang bekerja di panti."""
    panti    = models.ForeignKey(OrphanageProfile, on_delete=models.CASCADE, related_name='pekerja')
    nama     = models.CharField(max_length=200)
    divisi   = models.CharField(max_length=100)
    posisi   = models.CharField(max_length=100)

    class Meta:
        ordering = ['divisi', 'nama']

    def __str__(self):
        return f'{self.nama} — {self.posisi} ({self.divisi})'
