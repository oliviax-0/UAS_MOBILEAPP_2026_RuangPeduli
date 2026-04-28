from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated, IsAuthenticatedOrReadOnly
from django.shortcuts import get_object_or_404
from django.db.models import Q
from profiles.models import OrphanageProfile
from .models import Berita, BeritaImage, BeritaVote, Video
from .serializers import BeritaSerializer, BeritaImageSerializer, VideoSerializer


# ─── Berita ───────────────────────────────────────────────────────────────────

class BeritaListView(APIView):
    """
    GET  /api/content/berita/            → list published beritas (all pantis) — public
    GET  /api/content/berita/?panti=<id> → filter by panti — public
    POST /api/content/berita/            → create (panti only, requires JWT)
      Body: { panti_id, title, content, thumbnail?, is_published? }
    """
    permission_classes = [IsAuthenticatedOrReadOnly]

    def get(self, request):
        qs = Berita.objects.filter(is_published=True).select_related('author', 'panti')
        panti_id = request.query_params.get('panti')
        if panti_id:
            qs = qs.filter(panti_id=panti_id)
        search = request.query_params.get('search', '').strip()
        if search:
            qs = qs.filter(
                Q(title__icontains=search) |
                Q(content__icontains=search) |
                Q(panti__nama_panti__icontains=search)
            )
        serializer = BeritaSerializer(qs, many=True, context={'request': request})
        return Response(serializer.data)

    def post(self, request):
        user = request.user
        if user.role != 'panti':
            return Response({'error': 'Hanya akun panti yang dapat membuat berita'}, status=status.HTTP_403_FORBIDDEN)

        panti = get_object_or_404(OrphanageProfile, user=user)

        data = request.data.dict() if hasattr(request.data, 'dict') else dict(request.data)
        if 'thumbnail' in request.FILES:
            data['thumbnail'] = request.FILES.get('thumbnail')
        data['author'] = user.id
        data['panti']  = panti.id

        serializer = BeritaSerializer(data=data, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class BeritaDetailView(APIView):
    """
    GET    /api/content/berita/<id>/  → detail — public
    PUT    /api/content/berita/<id>/  → update (owner panti only, requires JWT)
    DELETE /api/content/berita/<id>/  → delete (owner panti only, requires JWT)
    """
    permission_classes = [IsAuthenticatedOrReadOnly]

    def get(self, request, pk):
        berita = get_object_or_404(Berita, pk=pk)
        serializer = BeritaSerializer(berita, context={'request': request})
        return Response(serializer.data)

    def put(self, request, pk):
        berita = get_object_or_404(Berita, pk=pk)
        if berita.author_id != request.user.id:
            return Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)

        serializer = BeritaSerializer(berita, data=request.data, partial=True, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        berita = get_object_or_404(Berita, pk=pk)
        if berita.author_id != request.user.id:
            return Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)
        berita.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class BeritaVoteView(APIView):
    """
    GET  /api/content/berita/<id>/vote/ → current vote state — public (shows user_vote if JWT sent)
    POST /api/content/berita/<id>/vote/ → vote (requires JWT)
      Body: { vote_type: 'up'|'down' }
    """
    permission_classes = [AllowAny]

    def get(self, request, pk):
        berita = get_object_or_404(Berita, pk=pk)
        user_vote = None
        if request.user.is_authenticated:
            existing = BeritaVote.objects.filter(berita=berita, user=request.user).first()
            if existing:
                user_vote = existing.vote_type
        return Response({
            'upvote_count': berita.upvote_count,
            'downvote_count': berita.downvote_count,
            'user_vote': user_vote,
        })

    def post(self, request, pk):
        if not request.user.is_authenticated:
            return Response({'error': 'Login diperlukan untuk vote'}, status=status.HTTP_401_UNAUTHORIZED)

        berita = get_object_or_404(Berita, pk=pk)
        vote_type = request.data.get('vote_type')

        if vote_type not in ('up', 'down'):
            return Response({'error': 'vote_type harus up atau down'}, status=status.HTTP_400_BAD_REQUEST)

        existing = BeritaVote.objects.filter(berita=berita, user=request.user).first()

        if existing:
            if existing.vote_type == vote_type:
                existing.delete()
                action = 'removed'
                user_vote = None
            else:
                existing.vote_type = vote_type
                existing.save()
                action = 'switched'
                user_vote = vote_type
        else:
            BeritaVote.objects.create(berita=berita, user=request.user, vote_type=vote_type)
            action = 'added'
            user_vote = vote_type

        return Response({
            'action': action,
            'upvote_count': berita.upvote_count,
            'downvote_count': berita.downvote_count,
            'user_vote': user_vote,
        })


# ─── Video ────────────────────────────────────────────────────────────────────

class VideoListView(APIView):
    """
    GET  /api/content/video/            → list published videos — public
    GET  /api/content/video/?panti=<id> → filter by panti — public
    POST /api/content/video/            → create (panti only, requires JWT)
      Body: { title, video_url, description?, thumbnail?, is_published? }
    """
    permission_classes = [IsAuthenticatedOrReadOnly]

    def get(self, request):
        qs = Video.objects.filter(is_published=True).select_related('author', 'panti')
        panti_id = request.query_params.get('panti')
        if panti_id:
            qs = qs.filter(panti_id=panti_id)
        serializer = VideoSerializer(qs, many=True, context={'request': request})
        return Response(serializer.data)

    def post(self, request):
        user = request.user
        if user.role != 'panti':
            return Response({'error': 'Hanya akun panti yang dapat mengunggah video'}, status=status.HTTP_403_FORBIDDEN)

        panti = get_object_or_404(OrphanageProfile, user=user)

        serializer = VideoSerializer(data={
            **request.data,
            'author': user.id,
            'panti': panti.id,
        }, context={'request': request})

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class VideoDetailView(APIView):
    """
    GET    /api/content/video/<id>/  → detail — public
    PUT    /api/content/video/<id>/  → update (owner only, requires JWT)
    DELETE /api/content/video/<id>/  → delete (owner only, requires JWT)
    """
    permission_classes = [IsAuthenticatedOrReadOnly]

    def get(self, request, pk):
        video = get_object_or_404(Video, pk=pk)
        serializer = VideoSerializer(video, context={'request': request})
        return Response(serializer.data)

    def put(self, request, pk):
        video = get_object_or_404(Video, pk=pk)
        if video.author_id != request.user.id:
            return Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)

        serializer = VideoSerializer(video, data=request.data, partial=True, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        video = get_object_or_404(Video, pk=pk)
        if video.author_id != request.user.id:
            return Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)
        video.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# ─── BeritaImage ──────────────────────────────────────────────────────────────

class BeritaImageUploadView(APIView):
    """
    POST   /api/content/berita/<id>/images/             → add image (owner only, requires JWT)
      Multipart form: { image, caption?, order? }
    DELETE /api/content/berita/<id>/images/<image_id>/  → delete image (owner only, requires JWT)
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        berita = get_object_or_404(Berita, pk=pk)
        if berita.author_id != request.user.id:
            return Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)

        serializer = BeritaImageSerializer(data={
            'berita': berita.id,
            'image': request.data.get('image'),
            'caption': request.data.get('caption', ''),
            'order': request.data.get('order', 0),
        })
        if serializer.is_valid():
            serializer.save(berita=berita)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk, image_id):
        berita = get_object_or_404(Berita, pk=pk)
        if berita.author_id != request.user.id:
            return Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)

        image = get_object_or_404(BeritaImage, pk=image_id, berita=berita)
        image.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
