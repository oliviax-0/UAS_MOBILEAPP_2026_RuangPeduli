import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/data/inventory_api.dart';

const Color kPink     = Color(0xFFF28C9F);
const Color kPinkLight = Color(0xFFFDE8EC);
const Color kRed      = Color(0xFFE53935);
const Color kOrange   = Color(0xFFFF8C00);

// ─── Main Screen ──────────────────────────────────────────────────────────────

class InventarisNotifikasiScreen extends StatefulWidget {
  final int? pantiId;
  const InventarisNotifikasiScreen({super.key, this.pantiId});

  @override
  State<InventarisNotifikasiScreen> createState() => _InventarisNotifikasiScreenState();
}

class _InventarisNotifikasiScreenState extends State<InventarisNotifikasiScreen> {
  List<LowStockItemModel> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    if (widget.pantiId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final items = await InventoryApi().fetchLowStockItems(widget.pantiId!);
      if (mounted) setState(() { _items = items; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  /// Group items by categoryId → one tile per category
  List<_CategoryAlert> get _categoryAlerts {
    final map = <int, _CategoryAlert>{};
    for (final item in _items) {
      if (map.containsKey(item.categoryId)) {
        map[item.categoryId]!.items.add(item);
        if (item.isOutOfStock) map[item.categoryId]!.hasOutOfStock = true;
      } else {
        map[item.categoryId] = _CategoryAlert(
          categoryId:   item.categoryId,
          categoryName: item.categoryName,
          items:        [item],
          hasOutOfStock: item.isOutOfStock,
        );
      }
    }
    // Sort: categories with out-of-stock first
    final list = map.values.toList()
      ..sort((a, b) => (b.hasOutOfStock ? 1 : 0) - (a.hasOutOfStock ? 1 : 0));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Stok Mendesak',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(width: 6),
            Tooltip(
              message: 'Stok Mendesak merupakan halaman berisikan kumpulan notifikasi\n'
                  'mengenai stok produk yang hampir habis dan peringatan untuk\n'
                  'melakukan stok ulang.',
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(seconds: 4),
              child: Icon(Icons.info_outline_rounded, size: 18, color: Colors.grey[400]),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _fetch,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPink))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center))
              : _items.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: _categoryAlerts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final cat = _categoryAlerts[index];
                        return _CategoryTile(
                          alert: cat,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _CategoryItemsScreen(alert: cat),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────

class _CategoryAlert {
  final int categoryId;
  final String categoryName;
  final List<LowStockItemModel> items;
  bool hasOutOfStock;

  _CategoryAlert({
    required this.categoryId,
    required this.categoryName,
    required this.items,
    required this.hasOutOfStock,
  });
}

// ─── Category Tile ────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final _CategoryAlert alert;
  final VoidCallback onTap;
  const _CategoryTile({required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: kPinkLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        alert.categoryName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.error_rounded,
                        color: alert.hasOutOfStock ? kRed : kOrange,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${alert.items.length} produk perlu perhatian',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[500], size: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Category Items Screen ────────────────────────────────────────────────────

class _CategoryItemsScreen extends StatelessWidget {
  final _CategoryAlert alert;
  const _CategoryItemsScreen({required this.alert});

  @override
  Widget build(BuildContext context) {
    final outOfStock  = alert.items.where((i) => i.isOutOfStock).toList();
    final almostEmpty = alert.items.where((i) => !i.isOutOfStock).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          alert.categoryName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          if (outOfStock.isNotEmpty) ...[
            _SectionHeader(icon: Icons.cancel_rounded, label: 'Habis (${outOfStock.length})', color: kRed),
            const SizedBox(height: 8),
            ...outOfStock.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _NotifTile(item: item),
                )),
            const SizedBox(height: 12),
          ],

          if (almostEmpty.isNotEmpty) ...[
            _SectionHeader(icon: Icons.warning_amber_rounded, label: 'Segera Habis (${almostEmpty.length})', color: kOrange),
            const SizedBox(height: 8),
            ...almostEmpty.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _NotifTile(item: item),
                )),
          ],
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: kPink, size: 48),
          SizedBox(height: 12),
          Text('Semua stok aman!', style: TextStyle(fontSize: 15, color: Colors.grey)),
          SizedBox(height: 4),
          Text('Tidak ada produk yang perlu di-restock.', style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionHeader({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

// ─── Notification Tile ────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final LowStockItemModel item;
  const _NotifTile({required this.item});

  Color get _color => item.isOutOfStock ? kRed : kOrange;

  String get _badge {
    if (item.isOutOfStock) return 'Habis';
    final d = item.daysUntilEmpty;
    if (d != null) return '~${d.toStringAsFixed(1)} hari';
    return 'Segera Habis';
  }

  String get _subtitle {
    final parts = <String>[];
    if (item.dailyUsage != null && item.dailyUsage! > 0) {
      parts.add('PHRR: ${item.dailyUsage} ${item.unit}/hari');
    }
    if (!item.isOutOfStock) {
      parts.add('Sisa: ${item.quantity} ${item.unit}');
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: _color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(
              item.isOutOfStock ? Icons.inventory_2_outlined : Icons.hourglass_bottom_rounded,
              color: _color, size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                if (_subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(_subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: _color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(_badge, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _color)),
          ),
        ],
      ),
    );
  }
}
