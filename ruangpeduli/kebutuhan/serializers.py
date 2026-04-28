from rest_framework import serializers
from .models import KebutuhanItem


class KebutuhanItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = KebutuhanItem
        fields = ['id', 'nama', 'satuan', 'jumlah', 'created_at']
        read_only_fields = ['id', 'created_at']


class KebutuhanItemWithPantiSerializer(serializers.ModelSerializer):
    panti_id   = serializers.IntegerField(source='panti.id',         read_only=True)
    panti_name = serializers.CharField(source='panti.nama_panti',    read_only=True)

    class Meta:
        model  = KebutuhanItem
        fields = ['id', 'panti_id', 'panti_name', 'nama', 'satuan', 'jumlah', 'created_at']
        read_only_fields = ['id', 'created_at']
