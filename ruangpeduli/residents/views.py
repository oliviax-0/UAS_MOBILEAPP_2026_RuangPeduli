from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.db.models import Q
from profiles.models import OrphanageProfile
from .models import Penghuni, Pekerja
from .serializers import PenghuniSerializer, PekerjaSerializer


def _get_panti(user):
    """Return (panti, error_response). error_response is None on success."""
    if user.role != 'panti':
        return None, Response({'error': 'Hanya akun panti yang dapat mengakses fitur ini'}, status=status.HTTP_403_FORBIDDEN)
    panti = get_object_or_404(OrphanageProfile, user=user)
    return panti, None


# ─── Penghuni ─────────────────────────────────────────────────────────────────

class PenghuniListView(APIView):
    """
    GET  /api/residents/penghuni/          → list penghuni milik panti (requires JWT)
    GET  /api/residents/penghuni/?search=x → search by nama
    POST /api/residents/penghuni/          → add penghuni (requires JWT)
      Body: { nama, tahun_lahir, jenis_kelamin }
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        panti, err = _get_panti(request.user)
        if err:
            return err
        qs = Penghuni.objects.filter(panti=panti)
        search = request.query_params.get('search', '').strip()
        if search:
            qs = qs.filter(nama__icontains=search)
        return Response(PenghuniSerializer(qs, many=True).data)

    def post(self, request):
        panti, err = _get_panti(request.user)
        if err:
            return err
        serializer = PenghuniSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(panti=panti)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class PenghuniDetailView(APIView):
    """
    GET    /api/residents/penghuni/<id>/  → detail (panti owner only, requires JWT)
    PUT    /api/residents/penghuni/<id>/  → update (requires JWT)
    DELETE /api/residents/penghuni/<id>/  → delete (requires JWT)
    """
    permission_classes = [IsAuthenticated]

    def _check_owner(self, request, penghuni):
        panti, err = _get_panti(request.user)
        if err:
            return err
        if penghuni.panti_id != panti.id:
            return Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)
        return None

    def get(self, request, pk):
        penghuni = get_object_or_404(Penghuni, pk=pk)
        err = self._check_owner(request, penghuni)
        if err:
            return err
        return Response(PenghuniSerializer(penghuni).data)

    def put(self, request, pk):
        penghuni = get_object_or_404(Penghuni, pk=pk)
        err = self._check_owner(request, penghuni)
        if err:
            return err
        serializer = PenghuniSerializer(penghuni, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        penghuni = get_object_or_404(Penghuni, pk=pk)
        err = self._check_owner(request, penghuni)
        if err:
            return err
        penghuni.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# ─── Pekerja ──────────────────────────────────────────────────────────────────

class PekerjaListView(APIView):
    """
    GET  /api/residents/pekerja/          → list pekerja milik panti (requires JWT)
    GET  /api/residents/pekerja/?search=x → search by nama/divisi/posisi
    POST /api/residents/pekerja/          → add pekerja (requires JWT)
      Body: { nama, divisi, posisi }
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        panti, err = _get_panti(request.user)
        if err:
            return err
        qs = Pekerja.objects.filter(panti=panti)
        search = request.query_params.get('search', '').strip()
        if search:
            qs = qs.filter(
                Q(nama__icontains=search) |
                Q(divisi__icontains=search) |
                Q(posisi__icontains=search)
            )
        return Response(PekerjaSerializer(qs, many=True).data)

    def post(self, request):
        panti, err = _get_panti(request.user)
        if err:
            return err
        serializer = PekerjaSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(panti=panti)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class PekerjaDetailView(APIView):
    """
    GET    /api/residents/pekerja/<id>/  → detail (panti owner only, requires JWT)
    PUT    /api/residents/pekerja/<id>/  → update (requires JWT)
    DELETE /api/residents/pekerja/<id>/  → delete (requires JWT)
    """
    permission_classes = [IsAuthenticated]

    def _check_owner(self, request, pekerja):
        panti, err = _get_panti(request.user)
        if err:
            return err
        if pekerja.panti_id != panti.id:
            return Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)
        return None

    def get(self, request, pk):
        pekerja = get_object_or_404(Pekerja, pk=pk)
        err = self._check_owner(request, pekerja)
        if err:
            return err
        return Response(PekerjaSerializer(pekerja).data)

    def put(self, request, pk):
        pekerja = get_object_or_404(Pekerja, pk=pk)
        err = self._check_owner(request, pekerja)
        if err:
            return err
        serializer = PekerjaSerializer(pekerja, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        pekerja = get_object_or_404(Pekerja, pk=pk)
        err = self._check_owner(request, pekerja)
        if err:
            return err
        pekerja.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
