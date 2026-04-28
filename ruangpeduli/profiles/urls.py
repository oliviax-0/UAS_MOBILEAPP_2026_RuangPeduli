from django.urls import path
from rest_framework.routers import DefaultRouter
from .views import SocietyProfileViewSet, OrphanageProfileViewSet, PantiMediaView, AllPantiVideosView

router = DefaultRouter()
router.register(r'masyarakat', SocietyProfileViewSet, basename='societyprofile')
router.register(r'panti', OrphanageProfileViewSet, basename='orphanageprofile')

urlpatterns = router.urls + [
    path('panti/<int:panti_id>/media/', PantiMediaView.as_view(), name='panti-media-list'),
    path('panti/<int:panti_id>/media/<int:media_id>/', PantiMediaView.as_view(), name='panti-media-detail'),
    path('media/videos/', AllPantiVideosView.as_view(), name='panti-videos-all'),
]