from django.contrib import admin
from .models import InventoryCategory, InventoryItem


class InventoryItemInline(admin.TabularInline):
    model = InventoryItem
    extra = 0


@admin.register(InventoryCategory)
class InventoryCategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'panti']
    search_fields = ['name', 'panti__nama_panti']
    list_filter = ['panti']
    inlines = [InventoryItemInline]


@admin.register(InventoryItem)
class InventoryItemAdmin(admin.ModelAdmin):
    list_display = ['name', 'category', 'quantity', 'unit', 'status']
    search_fields = ['name', 'category__name']
    list_filter = ['category__panti', 'unit']
