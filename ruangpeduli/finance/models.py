from django.db import models
from profiles.models import OrphanageProfile
from inventory.models import InventoryCategory


class JenisPemasukan(models.Model):
    """Dropdown options for income type — created and managed by the panti."""
    panti = models.ForeignKey(OrphanageProfile, on_delete=models.CASCADE, related_name='jenis_pemasukan')
    nama  = models.CharField(max_length=100)   # e.g. "Donasi", "Subsidi Pemerintah", "Zakat"

    class Meta:
        ordering = ['nama']
        unique_together = [('panti', 'nama')]

    def __str__(self):
        return self.nama


class Pemasukan(models.Model):
    """Income record."""
    panti            = models.ForeignKey(OrphanageProfile, on_delete=models.CASCADE, related_name='pemasukan')
    jenis_pemasukan  = models.ForeignKey(JenisPemasukan, on_delete=models.SET_NULL, null=True, related_name='records')
    jumlah           = models.DecimalField(max_digits=15, decimal_places=2)
    catatan          = models.TextField(blank=True, default='')
    tanggal          = models.DateField()
    created_at       = models.DateTimeField(auto_now_add=True, null=True)

    class Meta:
        ordering = ['-tanggal', '-created_at']

    def __str__(self):
        nama = self.jenis_pemasukan.nama if self.jenis_pemasukan else '-'
        return f'Pemasukan ({nama}) Rp{self.jumlah} — {self.tanggal}'


class Pengeluaran(models.Model):
    """Expense record, linked to an InventoryCategory."""
    panti    = models.ForeignKey(OrphanageProfile, on_delete=models.CASCADE, related_name='pengeluaran')
    kategori = models.ForeignKey(InventoryCategory, on_delete=models.SET_NULL, null=True, related_name='pengeluaran')
    jumlah   = models.DecimalField(max_digits=15, decimal_places=2)
    catatan  = models.TextField(blank=True, default='')
    tanggal  = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True, null=True)

    class Meta:
        ordering = ['-tanggal', '-created_at']

    def __str__(self):
        kat = self.kategori.name if self.kategori else 'Tanpa Kategori'
        return f'Pengeluaran ({kat}) Rp{self.jumlah} — {self.tanggal}'
