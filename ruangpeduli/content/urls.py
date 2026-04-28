from django.urls import path
from .views import (
    BeritaListView, BeritaDetailView, BeritaVoteView, BeritaImageUploadView,
    VideoListView, VideoDetailView,
)

urlpatterns = [
    path('berita/',                                       BeritaListView.as_view(),        name='berita-list'),
    path('berita/<int:pk>/',                              BeritaDetailView.as_view(),      name='berita-detail'),
    path('berita/<int:pk>/vote/',                         BeritaVoteView.as_view(),        name='berita-vote'),
    path('berita/<int:pk>/images/',                       BeritaImageUploadView.as_view(), name='berita-image-upload'),
    path('berita/<int:pk>/images/<int:image_id>/',        BeritaImageUploadView.as_view(), name='berita-image-delete'),
    path('video/',                                        VideoListView.as_view(),         name='video-list'),
    path('video/<int:pk>/',                               VideoDetailView.as_view(),       name='video-detail'),
]
