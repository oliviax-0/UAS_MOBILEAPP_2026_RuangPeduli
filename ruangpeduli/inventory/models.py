from django.db import models
from profiles.models import OrphanageProfile


class InventoryCategory(models.Model):
    """A category of inventory items belonging to a panti (e.g. Makanan, Pakaian)."""
    panti = models.ForeignKey(OrphanageProfile, on_delete=models.CASCADE, related_name='inventory_categories')
    name  = models.CharField(max_length=100)

    class Meta:
        ordering = ['name']
        unique_together = [('panti', 'name')]

    def __str__(self):
        return f'{self.panti.nama_panti} — {self.name}'


class InventoryItem(models.Model):
    """A single product inside a category, with its stock quantity."""
    category       = models.ForeignKey(InventoryCategory, on_delete=models.CASCADE, related_name='items')
    name           = models.CharField(max_length=200)
    quantity       = models.PositiveIntegerField(default=0)
    unit           = models.CharField(max_length=50, default='pcs')   # e.g. kg, pcs, lusin, dus
    description    = models.TextField(blank=True, default='')
    daily_usage    = models.FloatField(null=True, blank=True)   # PHRR — predicted or manual
    lead_time_days = models.PositiveIntegerField(default=1)     # days until restock arrives

    class Meta:
        ordering = ['name']

    def __str__(self):
        return f'{self.name} ({self.quantity} {self.unit})'

    @property
    def status(self):
        return 'available' if self.quantity > 0 else 'out_of_stock'

    @property
    def days_until_empty(self):
        """How many days of stock remain. None if daily_usage unknown."""
        if self.daily_usage and self.daily_usage > 0:
            return self.quantity / self.daily_usage
        return None

    @property
    def needs_restock(self):
        """True when stock will run out before the next restock arrives."""
        d = self.days_until_empty
        if d is None:
            return self.quantity == 0
        # If days_until_empty > 365, the PHRR is effectively 0 (e.g. AI gave near-zero
        # because there were no registered penghuni). Fall back to qty == 0 check.
        if d > 365:
            return self.quantity == 0
        return d <= self.lead_time_days


class StokLaporan(models.Model):
    """History log of every stok masuk / stok keluar transaction."""
    MASUK  = 'masuk'
    KELUAR = 'keluar'
    TIPE_CHOICES = [(MASUK, 'Masuk'), (KELUAR, 'Keluar')]

    item       = models.ForeignKey(InventoryItem, on_delete=models.CASCADE, related_name='laporan')
    amount     = models.PositiveIntegerField()
    tipe       = models.CharField(max_length=10, choices=TIPE_CHOICES)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.item.name} {self.tipe} {self.amount} {self.item.unit}'
