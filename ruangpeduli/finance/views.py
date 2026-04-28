from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.db.models import Sum
from django.utils import timezone
from profiles.models import OrphanageProfile
from .models import JenisPemasukan, Pemasukan, Pengeluaran
from .serializers import JenisPemasukanSerializer, PemasukanSerializer, PengeluaranSerializer


def _get_panti(user):
    """Return (panti, error_response). error_response is None on success."""
    if user.role != 'panti':
        return None, Response({'error': 'Hanya akun panti yang dapat mengakses fitur ini'}, status=status.HTTP_403_FORBIDDEN)
    panti = get_object_or_404(OrphanageProfile, user=user)
    return panti, None


# ─── Dashboard ────────────────────────────────────────────────────────────────

class DashboardView(APIView):
    """
    GET /api/finance/dashboard/
    GET /api/finance/dashboard/?month=3&year=2026
    Returns: total_pemasukan, total_pengeluaran, saldo for the given month.
    Requires JWT (panti role).
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        panti, err = _get_panti(request.user)
        if err:
            return err

        now   = timezone.now()
        month = int(request.query_params.get('month', now.month))
        year  = int(request.query_params.get('year',  now.year))

        total_pemasukan = Pemasukan.objects.filter(
            panti=panti, tanggal__month=month, tanggal__year=year
        ).aggregate(total=Sum('jumlah'))['total'] or 0

        total_pengeluaran = Pengeluaran.objects.filter(
            panti=panti, tanggal__month=month, tanggal__year=year
        ).aggregate(total=Sum('jumlah'))['total'] or 0

        all_pemasukan   = Pemasukan.objects.filter(panti=panti).aggregate(total=Sum('jumlah'))['total'] or 0
        all_pengeluaran = Pengeluaran.objects.filter(panti=panti).aggregate(total=Sum('jumlah'))['total'] or 0

        return Response({
            'month': month,
            'year':  year,
            'total_pemasukan':   total_pemasukan,
            'total_pengeluaran': total_pengeluaran,
            'saldo':             all_pemasukan - all_pengeluaran,
        })


# ─── Jenis Pemasukan ──────────────────────────────────────────────────────────

class JenisPemasukanListView(APIView):
    """
    GET  /api/finance/jenis-pemasukan/  → list dropdown options (requires JWT)
    POST /api/finance/jenis-pemasukan/  → add new option (requires JWT)
      Body: { nama }
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        panti, err = _get_panti(request.user)
        if err:
            return err
        qs = JenisPemasukan.objects.filter(panti=panti)
        return Response(JenisPemasukanSerializer(qs, many=True).data)

    def post(self, request):
        panti, err = _get_panti(request.user)
        if err:
            return err
        nama = request.data.get('nama', '').strip()
        if not nama:
            return Response({'error': 'nama wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)
        if JenisPemasukan.objects.filter(panti=panti, nama__iexact=nama).exists():
            return Response({'error': 'Jenis ini sudah ada'}, status=status.HTTP_400_BAD_REQUEST)
        obj = JenisPemasukan.objects.create(panti=panti, nama=nama)
        return Response(JenisPemasukanSerializer(obj).data, status=status.HTTP_201_CREATED)


class JenisPemasukanDetailView(APIView):
    """
    DELETE /api/finance/jenis-pemasukan/<id>/  (requires JWT)
    """
    permission_classes = [IsAuthenticated]

    def delete(self, request, pk):
        panti, err = _get_panti(request.user)
        if err:
            return err
        obj = get_object_or_404(JenisPemasukan, pk=pk)
        if obj.panti_id != panti.id:
            return Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)
        obj.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# ─── Pemasukan ────────────────────────────────────────────────────────────────

class PemasukanListView(APIView):
    """
    GET  /api/finance/pemasukan/              → all records (requires JWT)
    GET  /api/finance/pemasukan/?month=3&year=2026 → filter by month
    POST /api/finance/pemasukan/  Body: { jenis_pemasukan, jumlah, catatan, tanggal }
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        panti, err = _get_panti(request.user)
        if err:
            return err
        qs = Pemasukan.objects.filter(panti=panti)
        month = request.query_params.get('month')
        year  = request.query_params.get('year')
        if month:
            qs = qs.filter(tanggal__month=month)
        if year:
            qs = qs.filter(tanggal__year=year)
        return Response(PemasukanSerializer(qs, many=True).data)

    def post(self, request):
        panti, err = _get_panti(request.user)
        if err:
            return err
        serializer = PemasukanSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(panti=panti)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class PemasukanDetailView(APIView):
    """
    PUT    /api/finance/pemasukan/<id>/  Body: { ...fields }  (requires JWT)
    DELETE /api/finance/pemasukan/<id>/                       (requires JWT)
    """
    permission_classes = [IsAuthenticated]

    def _check(self, request, pk):
        panti, err = _get_panti(request.user)
        if err:
            return None, err
        obj = get_object_or_404(Pemasukan, pk=pk)
        if obj.panti_id != panti.id:
            return None, Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)
        return obj, None

    def put(self, request, pk):
        obj, err = self._check(request, pk)
        if err:
            return err
        serializer = PemasukanSerializer(obj, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        obj, err = self._check(request, pk)
        if err:
            return err
        obj.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# ─── Pengeluaran ──────────────────────────────────────────────────────────────

class PengeluaranListView(APIView):
    """
    GET  /api/finance/pengeluaran/              (requires JWT)
    GET  /api/finance/pengeluaran/?month=3&year=2026
    POST /api/finance/pengeluaran/  Body: { kategori, jumlah, catatan, tanggal }
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        panti, err = _get_panti(request.user)
        if err:
            return err
        qs = Pengeluaran.objects.filter(panti=panti)
        month = request.query_params.get('month')
        year  = request.query_params.get('year')
        if month:
            qs = qs.filter(tanggal__month=month)
        if year:
            qs = qs.filter(tanggal__year=year)
        return Response(PengeluaranSerializer(qs, many=True).data)

    def post(self, request):
        panti, err = _get_panti(request.user)
        if err:
            return err
        serializer = PengeluaranSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(panti=panti)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class PengeluaranDetailView(APIView):
    """
    PUT    /api/finance/pengeluaran/<id>/  Body: { ...fields }  (requires JWT)
    DELETE /api/finance/pengeluaran/<id>/                       (requires JWT)
    """
    permission_classes = [IsAuthenticated]

    def _check(self, request, pk):
        panti, err = _get_panti(request.user)
        if err:
            return None, err
        obj = get_object_or_404(Pengeluaran, pk=pk)
        if obj.panti_id != panti.id:
            return None, Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)
        return obj, None

    def put(self, request, pk):
        obj, err = self._check(request, pk)
        if err:
            return err
        serializer = PengeluaranSerializer(obj, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        obj, err = self._check(request, pk)
        if err:
            return err
        obj.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
