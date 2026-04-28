from django.contrib import admin
from .models import JenisPemasukan, Pemasukan, Pengeluaran


@admin.register(JenisPemasukan)
class JenisPemasukanAdmin(admin.ModelAdmin):
    list_display = ['nama', 'panti']
    search_fields = ['nama', 'panti__nama_panti']
    list_filter = ['panti']


@admin.register(Pemasukan)
class PemasukanAdmin(admin.ModelAdmin):
    list_display = ['panti', 'jenis_pemasukan', 'jumlah', 'tanggal']
    search_fields = ['panti__nama_panti', 'catatan']
    list_filter = ['panti', 'tanggal']
    date_hierarchy = 'tanggal'


@admin.register(Pengeluaran)
class PengeluaranAdmin(admin.ModelAdmin):
    list_display = ['panti', 'kategori', 'jumlah', 'tanggal']
    search_fields = ['panti__nama_panti', 'catatan']
    list_filter = ['panti', 'tanggal']
    date_hierarchy = 'tanggal'
