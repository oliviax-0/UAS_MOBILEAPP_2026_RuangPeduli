from rest_framework import serializers
from .models import Penghuni, Pekerja


class PenghuniSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Penghuni
        fields = ['id', 'nama', 'tahun_lahir', 'jenis_kelamin']


class PekerjaSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Pekerja
        fields = ['id', 'nama', 'divisi', 'posisi']
