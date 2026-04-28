from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import SocietyProfile, OrphanageProfile, PantiMedia


@admin.register(SocietyProfile)
class SocietyProfileAdmin(admin.ModelAdmin):
    list_display = ['get_username', 'get_email', 'nama_pengguna', 'alamat']
    search_fields = ['user__username', 'user__email', 'nama_pengguna']

    def get_username(self, obj):
        return obj.user.username
    get_username.short_description = 'Username'

    def get_email(self, obj):
        return obj.user.email
    get_email.short_description = 'Email'


@admin.register(OrphanageProfile)
class OrphanageProfileAdmin(admin.ModelAdmin):
    list_display = ['get_username', 'get_email', 'nama_panti', 'alamat_panti', 'nomor_panti']
    search_fields = ['user__username', 'user__email', 'nama_panti']

    def get_username(self, obj):
        return obj.user.username
    get_username.short_description = 'Username'

    def get_email(self, obj):
        return obj.user.email
    get_email.short_description = 'Email'


@admin.register(PantiMedia)
class PantiMediaAdmin(admin.ModelAdmin):
    list_display = ['panti', 'media_type', 'order', 'created_at']
    list_filter = ['media_type']