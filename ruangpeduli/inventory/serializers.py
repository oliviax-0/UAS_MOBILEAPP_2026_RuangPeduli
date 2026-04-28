from rest_framework import serializers
from .models import InventoryCategory, InventoryItem, StokLaporan


class InventoryItemSerializer(serializers.ModelSerializer):
    status          = serializers.ReadOnlyField()
    days_until_empty = serializers.ReadOnlyField()
    needs_restock   = serializers.ReadOnlyField()

    class Meta:
        model  = InventoryItem
        fields = [
            'id', 'name', 'quantity', 'unit', 'description',
            'daily_usage', 'lead_time_days',
            'status', 'days_until_empty', 'needs_restock',
        ]


class InventoryCategorySerializer(serializers.ModelSerializer):
    items       = InventoryItemSerializer(many=True, read_only=True)
    item_count  = serializers.SerializerMethodField()
    panti_id    = serializers.IntegerField(source='panti.id', read_only=True)
    panti_name  = serializers.CharField(source='panti.nama_panti', read_only=True)

    class Meta:
        model  = InventoryCategory
        fields = ['id', 'panti_id', 'panti_name', 'name', 'item_count', 'items']

    def get_item_count(self, obj):
        return obj.items.count()


class InventoryCategoryLightSerializer(serializers.ModelSerializer):
    """Lightweight version without items list — for listing all categories."""
    item_count          = serializers.SerializerMethodField()
    available_count     = serializers.SerializerMethodField()
    needs_restock_count = serializers.SerializerMethodField()
    panti_id            = serializers.IntegerField(source='panti.id', read_only=True)
    panti_name          = serializers.CharField(source='panti.nama_panti', read_only=True)

    class Meta:
        model  = InventoryCategory
        fields = ['id', 'panti_id', 'panti_name', 'name', 'item_count', 'available_count', 'needs_restock_count']

    def get_item_count(self, obj):
        return obj.items.count()

    def get_available_count(self, obj):
        return obj.items.filter(quantity__gt=0).count()

    def get_needs_restock_count(self, obj):
        """Number of items that need restocking (qty=0 OR days_until_empty <= lead_time)."""
        return sum(1 for item in obj.items.all() if item.needs_restock)


class StokLaporanSerializer(serializers.ModelSerializer):
    category_name = serializers.SerializerMethodField()
    product_name  = serializers.SerializerMethodField()
    unit          = serializers.SerializerMethodField()
    type          = serializers.CharField(source='tipe', read_only=True)

    class Meta:
        model  = StokLaporan
        fields = ['id', 'category_name', 'product_name', 'amount', 'unit', 'type', 'created_at']

    def get_category_name(self, obj):
        return obj.item.category.name

    def get_product_name(self, obj):
        return obj.item.name

    def get_unit(self, obj):
        return obj.item.unit
