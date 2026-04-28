from django.contrib import admin
from .models import User, PendingRegistration

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ['username', 'email', 'role', 'date_joined']
    search_fields = ['username', 'email']

@admin.register(PendingRegistration)
class PendingRegistrationAdmin(admin.ModelAdmin):
    list_display = ['username', 'email', 'role', 'otp_code', 'expires_at', 'created_at']
    search_fields = ['username', 'email']



