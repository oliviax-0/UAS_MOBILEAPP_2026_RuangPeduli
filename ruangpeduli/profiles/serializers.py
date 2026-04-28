from rest_framework import serializers
from django.db.models import Sum
from .models import SocietyProfile, OrphanageProfile, PantiMedia


class SocietyProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', required=False)
    email = serializers.EmailField(source='user.email', required=False)
    password = serializers.CharField(write_only=True, required=False, allow_blank=True)

    class Meta:
        model = SocietyProfile
        fields = [
            'id', 'username', 'email', 'password',
            'nama_pengguna', 'alamat', 'nomor_telepon', 'jenis_kelamin',
            'profile_picture',
        ]
        extra_kwargs = {
            'nama_pengguna': {'required': False},
            'alamat': {'required': False},
            'nomor_telepon': {'required': False},
            'jenis_kelamin': {'required': False},
            'profile_picture': {'required': False},
        }

    def update(self, instance, validated_data):
        user_data = validated_data.pop('user', {})
        password = validated_data.pop('password', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        user = instance.user
        if 'username' in user_data:
            user.username = user_data['username']
        if 'email' in user_data:
            user.email = user_data['email']
        if password:
            user.set_password(password)
        user.save()
        return instance


class PantiMediaSerializer(serializers.ModelSerializer):
    class Meta:
        model = PantiMedia
        fields = ['id', 'media_type', 'file', 'video_url', 'title', 'description', 'order', 'created_at']
        read_only_fields = ['created_at']


class PantiVideoSerializer(serializers.ModelSerializer):
    panti_id   = serializers.IntegerField(source='panti.id', read_only=True)
    panti_name = serializers.CharField(source='panti.nama_panti', read_only=True)

    class Meta:
        model  = PantiMedia
        fields = ['id', 'panti_id', 'panti_name', 'file', 'video_url', 'title', 'description', 'order', 'created_at']
        read_only_fields = ['created_at']


class OrphanageProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', required=False)
    email = serializers.EmailField(source='user.email', required=False)
    password = serializers.CharField(write_only=True, required=False, allow_blank=True)
    total_terkumpul = serializers.SerializerMethodField()

    def get_total_terkumpul(self, obj):
        total = obj.pemasukan.aggregate(total=Sum('jumlah'))['total']
        return int(total) if total else 0

    class Meta:
        model = OrphanageProfile
        fields = [
            'id', 'username', 'email', 'nama_panti', 'alamat_panti',
            'nomor_panti', 'profile_picture', 'description', 'password',
            'total_terkumpul', 'provinsi', 'kabupaten_kota',
            'kecamatan', 'kelurahan', 'kode_pos', 'lat', 'lng',
        ]
        extra_kwargs = {
            'nama_panti': {'required': False},
            'alamat_panti': {'required': False},
            'nomor_panti': {'required': False},
            'profile_picture': {'required': False},
        }

    def update(self, instance, validated_data):
        user_data = validated_data.pop('user', {})
        password = validated_data.pop('password', None)

        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        user = instance.user
        if 'username' in user_data:
            user.username = user_data['username']
        if 'email' in user_data:
            user.email = user_data['email']
        if password:
            user.set_password(password)
        user.save()

        return instance
