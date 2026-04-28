from django.db import models
from profiles.models import OrphanageProfile


class KebutuhanItem(models.Model):
    panti      = models.ForeignKey(OrphanageProfile, on_delete=models.CASCADE, related_name='kebutuhan')
    nama       = models.CharField(max_length=200)
    satuan     = models.CharField(max_length=50)
    jumlah     = models.PositiveIntegerField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.nama} ({self.jumlah} {self.satuan}) – {self.panti.nama_panti}'
