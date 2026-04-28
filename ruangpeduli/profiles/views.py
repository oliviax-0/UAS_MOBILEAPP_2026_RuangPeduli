from rest_framework import viewsets, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from django.shortcuts import get_object_or_404
from .models import SocietyProfile, OrphanageProfile, PantiMedia
from .serializers import SocietyProfileSerializer, OrphanageProfileSerializer, PantiMediaSerializer, PantiVideoSerializer


class SocietyProfileViewSet(viewsets.ModelViewSet):
    serializer_class = SocietyProfileSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        queryset = SocietyProfile.objects.all()
        user_id = self.request.query_params.get('user_id')
        if user_id is not None:
            queryset = queryset.filter(user_id=user_id)
        return queryset

    def partial_update(self, request, *args, **kwargs):
        if request.data.get('remove_profile_picture') == 'true':
            instance = self.get_object()
            if instance.profile_picture:
                instance.profile_picture.delete(save=False)
                instance.profile_picture = None
                instance.save(update_fields=['profile_picture'])
        return super().partial_update(request, *args, **kwargs)


class OrphanageProfileViewSet(viewsets.ModelViewSet):
    queryset = OrphanageProfile.objects.all()
    serializer_class = OrphanageProfileSerializer
    permission_classes = [AllowAny]

    def partial_update(self, request, *args, **kwargs):
        if request.data.get('remove_profile_picture') == 'true':
            instance = self.get_object()
            if instance.profile_picture:
                instance.profile_picture.delete(save=False)
                instance.profile_picture = None
                instance.save(update_fields=['profile_picture'])
        return super().partial_update(request, *args, **kwargs)


class PantiMediaView(APIView):
    """
    GET    /api/profiles/panti/<panti_id>/media/              → list media
    POST   /api/profiles/panti/<panti_id>/media/              → add media
      Multipart: { media_type, file?, video_url?, order? }
    DELETE /api/profiles/panti/<panti_id>/media/<media_id>/   → delete media
    """
    permission_classes = [AllowAny]

    def get(self, request, panti_id):
        panti = get_object_or_404(OrphanageProfile, pk=panti_id)
        serializer = PantiMediaSerializer(
            panti.media.all(), many=True, context={'request': request}
        )
        return Response(serializer.data)

    def post(self, request, panti_id):
        panti = get_object_or_404(OrphanageProfile, pk=panti_id)
        serializer = PantiMediaSerializer(
            data=request.data, context={'request': request}
        )
        if serializer.is_valid():
            serializer.save(panti=panti)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, panti_id, media_id):
        panti = get_object_or_404(OrphanageProfile, pk=panti_id)
        media = get_object_or_404(PantiMedia, pk=media_id, panti=panti)
        media.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class AllPantiVideosView(APIView):
    """
    GET /api/profiles/media/videos/
    Returns all video media uploaded by any panti, with panti info included.
    """
    permission_classes = [AllowAny]

    def get(self, request):
        videos = PantiMedia.objects.filter(
            media_type='video'
        ).select_related('panti').order_by('-created_at')
        serializer = PantiVideoSerializer(videos, many=True, context={'request': request})
        return Response(serializer.data)