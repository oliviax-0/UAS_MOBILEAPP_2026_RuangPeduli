from rest_framework import serializers
from .models import Donasi


class DonasiSerializer(serializers.ModelSerializer):
    panti_image = serializers.SerializerMethodField()
    tanggal_label = serializers.SerializerMethodField()

    class Meta:
        model = Donasi
        fields = [
            'id', 'nama_panti', 'panti_image',
            'jumlah', 'metode_pembayaran', 'no_referensi',
            'tanggal', 'tanggal_label',
        ]

    def get_panti_image(self, obj):
        if obj.panti and obj.panti.profile_picture:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.panti.profile_picture.url)
        return None

    def get_tanggal_label(self, obj):
        bulan = [
            '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
            'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
        ]
        d = obj.tanggal
        return f'{d.day} {bulan[d.month]} {d.year}'
