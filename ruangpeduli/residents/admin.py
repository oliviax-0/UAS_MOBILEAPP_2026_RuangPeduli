from django.contrib import admin
from .models import Penghuni, Pekerja


@admin.register(Penghuni)
class PenghuniAdmin(admin.ModelAdmin):
    list_display = ['nama', 'panti', 'tahun_lahir', 'jenis_kelamin']
    search_fields = ['nama', 'panti__nama_panti']
    list_filter = ['panti', 'jenis_kelamin']


@admin.register(Pekerja)
class PekerjaAdmin(admin.ModelAdmin):
    list_display = ['nama', 'panti', 'divisi', 'posisi']
    search_fields = ['nama', 'panti__nama_panti', 'divisi', 'posisi']
    list_filter = ['panti', 'divisi']
