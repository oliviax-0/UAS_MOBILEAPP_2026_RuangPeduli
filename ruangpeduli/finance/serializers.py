from rest_framework import serializers
from .models import JenisPemasukan, Pemasukan, Pengeluaran


class JenisPemasukanSerializer(serializers.ModelSerializer):
    class Meta:
        model  = JenisPemasukan
        fields = ['id', 'nama']


class PemasukanSerializer(serializers.ModelSerializer):
    jenis_nama = serializers.CharField(source='jenis_pemasukan.nama', read_only=True)

    class Meta:
        model  = Pemasukan
        fields = ['id', 'jenis_pemasukan', 'jenis_nama', 'jumlah', 'catatan', 'tanggal', 'created_at']


class PengeluaranSerializer(serializers.ModelSerializer):
    kategori_nama = serializers.CharField(source='kategori.name', read_only=True)

    class Meta:
        model  = Pengeluaran
        fields = ['id', 'kategori', 'kategori_nama', 'jumlah', 'catatan', 'tanggal', 'created_at']
