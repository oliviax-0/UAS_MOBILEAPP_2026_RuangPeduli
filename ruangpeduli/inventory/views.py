import os
import json
import requests as req_lib
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated, IsAuthenticatedOrReadOnly
from django.shortcuts import get_object_or_404
from profiles.models import OrphanageProfile
from .models import InventoryCategory, InventoryItem, StokLaporan
from .serializers import (
    InventoryCategorySerializer,
    InventoryCategoryLightSerializer,
    InventoryItemSerializer,
    StokLaporanSerializer,
)


def _get_panti(user):
    if user.role != 'panti':
        return None, Response({'error': 'Hanya akun panti yang dapat mengakses fitur ini'}, status=status.HTTP_403_FORBIDDEN)
    panti = get_object_or_404(OrphanageProfile, user=user)
    return panti, None


# ─── Categories ───────────────────────────────────────────────────────────────

class CategoryListView(APIView):
    """
    GET  /api/inventory/categories/            → list all categories — public
    GET  /api/inventory/categories/?panti=<id> → filter by panti — public
    POST /api/inventory/categories/            → create category (panti only, requires JWT)
      Body: { name }
    """
    permission_classes = [IsAuthenticatedOrReadOnly]

    def get(self, request):
        qs = InventoryCategory.objects.select_related('panti')
        panti_id = request.query_params.get('panti')
        if panti_id:
            qs = qs.filter(panti_id=panti_id)
        serializer = InventoryCategoryLightSerializer(qs, many=True)
        return Response(serializer.data)

    def post(self, request):
        panti, err = _get_panti(request.user)
        if err:
            return err
        name = request.data.get('name', '').strip()
        if not name:
            return Response({'error': 'name wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)
        if InventoryCategory.objects.filter(panti=panti, name__iexact=name).exists():
            return Response({'error': 'Kategori dengan nama ini sudah ada'}, status=status.HTTP_400_BAD_REQUEST)
        category = InventoryCategory.objects.create(panti=panti, name=name)
        return Response(InventoryCategoryLightSerializer(category).data, status=status.HTTP_201_CREATED)


class CategoryDetailView(APIView):
    """
    GET    /api/inventory/categories/<id>/  → detail with full item list — public
    PUT    /api/inventory/categories/<id>/  → rename category (panti owner only, requires JWT)
      Body: { name }
    DELETE /api/inventory/categories/<id>/  → delete (panti owner only, requires JWT)
    """
    permission_classes = [IsAuthenticatedOrReadOnly]

    def get(self, request, pk):
        category = get_object_or_404(InventoryCategory, pk=pk)
        serializer = InventoryCategorySerializer(category)
        return Response(serializer.data)

    def _check_owner(self, request, category):
        panti, err = _get_panti(request.user)
        if err:
            return err
        if category.panti.user_id != request.user.id:
            return Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)
        return None

    def put(self, request, pk):
        category = get_object_or_404(InventoryCategory, pk=pk)
        err = self._check_owner(request, category)
        if err:
            return err
        name = request.data.get('name', '').strip()
        if not name:
            return Response({'error': 'name wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)
        category.name = name
        category.save()
        return Response(InventoryCategoryLightSerializer(category).data)

    def delete(self, request, pk):
        category = get_object_or_404(InventoryCategory, pk=pk)
        err = self._check_owner(request, category)
        if err:
            return err
        category.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# ─── Items ────────────────────────────────────────────────────────────────────

class ItemListView(APIView):
    """
    GET  /api/inventory/categories/<cat_id>/items/  → all items — public
    POST /api/inventory/categories/<cat_id>/items/  → add item (panti owner, requires JWT)
      Body: { name, quantity, unit?, description? }
    """
    permission_classes = [IsAuthenticatedOrReadOnly]

    def get(self, request, cat_id):
        category = get_object_or_404(InventoryCategory, pk=cat_id)
        qs = category.items.all()
        status_filter = request.query_params.get('status')
        if status_filter == 'available':
            qs = qs.filter(quantity__gt=0)
        elif status_filter == 'out_of_stock':
            qs = qs.filter(quantity=0)
        return Response(InventoryItemSerializer(qs, many=True).data)

    def post(self, request, cat_id):
        category = get_object_or_404(InventoryCategory, pk=cat_id)
        if request.user.role != 'panti' or category.panti.user_id != request.user.id:
            return Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)

        serializer = InventoryItemSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(category=category)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ItemDetailView(APIView):
    """
    GET    /api/inventory/items/<id>/  → item detail — public
    PUT    /api/inventory/items/<id>/  → update (panti owner, requires JWT)
      Body: { name?, quantity?, unit?, description? }
    DELETE /api/inventory/items/<id>/  → delete (panti owner, requires JWT)
    """
    permission_classes = [IsAuthenticatedOrReadOnly]

    def _check_owner(self, request, item):
        if request.user.role != 'panti' or item.category.panti.user_id != request.user.id:
            return Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)
        return None

    def get(self, request, pk):
        item = get_object_or_404(InventoryItem, pk=pk)
        return Response(InventoryItemSerializer(item).data)

    def put(self, request, pk):
        item = get_object_or_404(InventoryItem, pk=pk)
        err = self._check_owner(request, item)
        if err:
            return err
        serializer = InventoryItemSerializer(item, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        item = get_object_or_404(InventoryItem, pk=pk)
        err = self._check_owner(request, item)
        if err:
            return err
        item.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# ─── Laporan (Stok History) ────────────────────────────────────────────────────

class LaporanView(APIView):
    """
    GET  /api/inventory/laporan/?panti=<id>  → list all laporan for a panti — public
    POST /api/inventory/laporan/             → record stok masuk/keluar (panti owner, requires JWT)
      Body: { item_id, amount, type }   (type: 'masuk' | 'keluar')
    """
    permission_classes = [IsAuthenticatedOrReadOnly]

    def get(self, request):
        panti_id = request.query_params.get('panti')
        if not panti_id:
            return Response({'error': 'panti query param wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)
        qs = StokLaporan.objects.select_related('item__category').filter(
            item__category__panti_id=panti_id
        )
        return Response(StokLaporanSerializer(qs, many=True).data)

    def post(self, request):
        if request.user.role != 'panti':
            return Response({'error': 'Hanya akun panti yang dapat mencatat laporan'}, status=status.HTTP_403_FORBIDDEN)

        item_id = request.data.get('item_id')
        amount  = request.data.get('amount')
        tipe    = request.data.get('type')

        if not all([item_id, amount, tipe]):
            return Response(
                {'error': 'item_id, amount, dan type wajib diisi'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if tipe not in (StokLaporan.MASUK, StokLaporan.KELUAR):
            return Response({'error': "type harus 'masuk' atau 'keluar'"}, status=status.HTTP_400_BAD_REQUEST)

        item = get_object_or_404(InventoryItem, pk=item_id)
        if item.category.panti.user_id != request.user.id:
            return Response({'error': 'Tidak diizinkan'}, status=status.HTTP_403_FORBIDDEN)

        try:
            amount = int(amount)
            if amount <= 0:
                raise ValueError
        except (ValueError, TypeError):
            return Response({'error': 'amount harus bilangan bulat positif'}, status=status.HTTP_400_BAD_REQUEST)

        laporan = StokLaporan.objects.create(item=item, amount=amount, tipe=tipe)
        return Response(StokLaporanSerializer(laporan).data, status=status.HTTP_201_CREATED)


# ─── AI PHRR Prediction ────────────────────────────────────────────────────────

class PredictPhrrView(APIView):
    """
    POST /api/inventory/predict-phrr/
    Body: { panti_id, product_name, unit }
    Returns: { daily_usage: float, reasoning: str }
    Uses Claude API to predict daily usage based on product type + resident count.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        panti_id     = request.data.get('panti_id')
        product_name = request.data.get('product_name', '').strip()
        unit         = request.data.get('unit', 'pcs').strip()

        if not panti_id or not product_name:
            return Response({'error': 'panti_id dan product_name wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)

        panti = get_object_or_404(OrphanageProfile, pk=panti_id)
        penghuni_count = panti.penghuni.count()
        pekerja_count  = panti.pekerja.count()
        total_orang    = max(penghuni_count + pekerja_count, 1)  # at least 1 to avoid near-zero PHRR

        api_key = os.environ.get('GROQ_API_KEY', '')
        if not api_key:
            return Response({'error': 'GROQ_API_KEY belum dikonfigurasi'}, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        prompt = (
            f"Kamu adalah sistem AI untuk manajemen inventaris panti asuhan di Indonesia.\n"
            f"Berikan 3 skenario prediksi pemakaian harian rata-rata (PHRR) untuk produk berikut:\n\n"
            f"Produk: {product_name}\n"
            f"Satuan: {unit}\n"
            f"Jumlah penghuni (anak asuh): {penghuni_count} orang\n"
            f"Jumlah pekerja/staf: {pekerja_count} orang\n"
            f"Total pengguna produk: {total_orang} orang\n\n"
            f"Berikan 3 estimasi berbeda: rendah, sedang, dan tinggi berdasarkan pola konsumsi berbeda.\n"
            f"Pertimbangkan jenis produk dan total {total_orang} orang sebagai faktor pengali.\n\n"
            f"Balas HANYA dalam format JSON berikut, tanpa teks lain:\n"
            f'{{"suggestions": ['
            f'{{"daily_usage": <angka>, "reasoning": "<alasan singkat>"}},'
            f'{{"daily_usage": <angka>, "reasoning": "<alasan singkat>"}},'
            f'{{"daily_usage": <angka>, "reasoning": "<alasan singkat>"}}'
            f']}}'
        )

        try:
            resp = req_lib.post(
                'https://api.groq.com/openai/v1/chat/completions',
                headers={
                    'Authorization': f'Bearer {api_key}',
                    'Content-Type': 'application/json',
                },
                json={
                    'model': 'llama-3.1-8b-instant',
                    'max_tokens': 256,
                    'messages': [{'role': 'user', 'content': prompt}],
                },
                timeout=20,
            )
            resp.raise_for_status()
            text = resp.json()['choices'][0]['message']['content'].strip()
            # Strip markdown code fences if present
            if text.startswith('```'):
                text = text.split('```')[1]
                if text.startswith('json'):
                    text = text[4:]
                text = text.strip('`').strip()
            result = json.loads(text)
            suggestions = result.get('suggestions', [])
            # Normalise each entry
            out = [
                {'daily_usage': float(s.get('daily_usage', 0)), 'reasoning': s.get('reasoning', '')}
                for s in suggestions if s.get('daily_usage') is not None
            ]
            return Response({'suggestions': out, 'unit': unit})
        except Exception as e:
            return Response({'error': f'Gagal memanggil AI: {e}'}, status=status.HTTP_502_BAD_GATEWAY)


# ─── Low Stock Notifications ───────────────────────────────────────────────────

class LowStockView(APIView):
    """
    GET /api/inventory/low-stock/?panti_id=<id>
    Returns items that need_restock (qty=0 OR days_until_empty <= lead_time_days).
    Each item includes days_until_empty so the UI can show urgency.
    """
    permission_classes = [AllowAny]

    def get(self, request):
        panti_id = request.query_params.get('panti_id')
        if not panti_id:
            return Response({'error': 'panti_id wajib diisi'}, status=status.HTTP_400_BAD_REQUEST)

        items = InventoryItem.objects.filter(
            category__panti_id=panti_id
        ).select_related('category')

        result = []
        for item in items:
            if item.needs_restock:
                d = item.days_until_empty
                result.append({
                    'id': item.id,
                    'name': item.name,
                    'quantity': item.quantity,
                    'unit': item.unit,
                    'daily_usage': item.daily_usage,
                    'lead_time_days': item.lead_time_days,
                    'days_until_empty': round(d, 1) if d is not None else None,
                    'category_id': item.category.id,
                    'category_name': item.category.name,
                    'is_out_of_stock': item.quantity == 0,
                })

        result.sort(key=lambda x: (x['days_until_empty'] is None, x['days_until_empty'] or 0))
        return Response(result)
