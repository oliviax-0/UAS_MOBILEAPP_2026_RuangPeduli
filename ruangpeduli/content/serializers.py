from rest_framework import serializers
from .models import Berita, BeritaImage, BeritaVote, Video


class BeritaImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = BeritaImage
        fields = ['id', 'image', 'caption', 'order']


class BeritaSerializer(serializers.ModelSerializer):
    images = BeritaImageSerializer(many=True, read_only=True)
    upvote_count = serializers.IntegerField(read_only=True)
    downvote_count = serializers.IntegerField(read_only=True)
    panti_name = serializers.CharField(source='panti.nama_panti', read_only=True)
    panti_profile_picture = serializers.ImageField(source='panti.profile_picture', read_only=True)
    author_name = serializers.CharField(source='author.username', read_only=True)

    class Meta:
        model = Berita
        fields = [
            'id', 'title', 'content', 'thumbnail',
            'author', 'author_name', 'panti', 'panti_name', 'panti_profile_picture',
            'is_published', 'created_at', 'updated_at',
            'images', 'upvote_count', 'downvote_count',
        ]
        read_only_fields = ['created_at', 'updated_at']


class VideoSerializer(serializers.ModelSerializer):
    panti_name = serializers.CharField(source='panti.nama_panti', read_only=True)
    author_name = serializers.CharField(source='author.username', read_only=True)

    class Meta:
        model = Video
        fields = [
            'id', 'title', 'description', 'video_url', 'thumbnail',
            'author', 'author_name', 'panti', 'panti_name',
            'is_published', 'created_at', 'updated_at',
        ]
        read_only_fields = ['created_at', 'updated_at']
