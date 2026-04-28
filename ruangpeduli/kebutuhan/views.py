from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from django.shortcuts import get_object_or_404
from profiles.models import OrphanageProfile
from .models import KebutuhanItem
from .serializers import KebutuhanItemSerializer, KebutuhanItemWithPantiSerializer


class KebutuhanAllView(APIView):
    """
    GET /api/kebutuhan/all/ → list all kebutuhan across every panti (public)
    """
    permission_classes = [AllowAny]

    def get(self, request):
        qs = KebutuhanItem.objects.select_related('panti').order_by('panti__nama_panti', '-created_at')
        return Response(KebutuhanItemWithPantiSerializer(qs, many=True).data)


class KebutuhanListView(APIView):
    """
    GET  /api/kebutuhan/?panti=<id>  → list kebutuhan for a panti (public)
    POST /api/kebutuhan/             → add item (panti only, requires JWT)
      Body: { nama, satuan, jumlah }
    """
    permission_classes = [AllowAny]

    def get(self, request):
        panti_id = request.query_params.get('panti')
        if not panti_id:
            return Response({'error': 'panti query param wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)
        qs = KebutuhanItem.objects.filter(panti_id=panti_id)
        return Response(KebutuhanItemSerializer(qs, many=True).data)

    def post(self, request):
        if not request.user.is_authenticated:
            return Response({'error': 'Login diperlukan'}, status=status.HTTP_401_UNAUTHORIZED)
        if request.user.role != 'panti':
            return Response({'error': 'Hanya akun panti yang dapat menambah kebutuhan'}, status=status.HTTP_403_FORBIDDEN)

        nama   = request.data.get('nama', '').strip()
        satuan = request.data.get('satuan', '').strip()
        jumlah = request.data.get('jumlah')

        if not all([nama, satuan, jumlah]):
            return Response({'error': 'nama, satuan, jumlah wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)

        panti = get_object_or_404(OrphanageProfile, user=request.user)

        try:
            jumlah = int(jumlah)
            if jumlah <= 0:
                raise ValueError
        except (ValueError, TypeError):
            return Response({'error': 'jumlah harus bilangan bulat positif'}, status=status.HTTP_400_BAD_REQUEST)

        item = KebutuhanItem.objects.create(panti=panti, nama=nama, satuan=satuan, jumlah=jumlah)
        return Response(KebutuhanItemSerializer(item).data, status=status.HTTP_201_CREATED)


class KebutuhanDetailView(APIView):
    """
    DELETE /api/kebutuhan/<id>/  → delete item (panti owner only, requires JWT)
    """
    permission_classes = [IsAuthenticated]

    def delete(self, request, pk):
        if request.user.role != 'panti':
            return Response({'error': 'Hanya akun panti yang dapat menghapus kebutuhan'}, status=status.HTTP_403_FORBIDDEN)
        item = get_object_or_404(KebutuhanItem, pk=pk)
        if item.panti.user_id != request.user.id:
            return Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)
        item.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
