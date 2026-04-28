import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/data/kebutuhan_api.dart';
import 'kebutuhan_tambah_panti.dart';

// ─── Icon auto-mapping ────────────────────────────────────────────────────────

IconData _iconFor(String nama) {
  final n = nama.toLowerCase();
  if (n.contains('susu') || n.contains('milk')) return Icons.coffee_rounded;
  if (n.contains('telur') || n.contains('egg')) return Icons.egg_alt_rounded;
  if (n.contains('beras') || n.contains('rice') || n.contains('nasi')) return Icons.grain_rounded;
  if (n.contains('minyak') || n.contains('oil')) return Icons.opacity_rounded;
  if (n.contains('air') || n.contains('minum') || n.contains('water')) return Icons.water_drop_rounded;
  if (n.contains('roti') || n.contains('bread')) return Icons.bakery_dining_rounded;
  if (n.contains('sayur')) return Icons.eco_rounded;
  if (n.contains('buah') || n.contains('fruit')) return Icons.spa_rounded;
  if (n.contains('daging') || n.contains('ayam') || n.contains('ikan')) return Icons.set_meal_rounded;
  if (n.contains('sabun') || n.contains('deterjen') || n.contains('cuci')) return Icons.soap_rounded;
  if (n.contains('baju') || n.contains('pakaian') || n.contains('celana') || n.contains('seragam')) return Icons.checkroom_rounded;
  if (n.contains('obat') || n.contains('vitamin') || n.contains('medis')) return Icons.medical_services_rounded;
  if (n.contains('buku') || n.contains('tulis') || n.contains('alat tulis')) return Icons.menu_book_rounded;
  if (n.contains('gula') || n.contains('garam') || n.contains('tepung')) return Icons.science_rounded;
  if (n.contains('popok') || n.contains('pampers')) return Icons.child_care_rounded;
  return Icons.inventory_2_rounded;
}

// ─── Kebutuhan List Page ──────────────────────────────────────────────────────

class KebutuhanPantiPage extends StatefulWidget {
  final int pantiId;
  final int userId;

  const KebutuhanPantiPage({super.key, required this.pantiId, required this.userId});

  @override
  State<KebutuhanPantiPage> createState() => _KebutuhanPantiPageState();
}

class _KebutuhanPantiPageState extends State<KebutuhanPantiPage> {
  static const Color _kPink = Color(0xFFF28695);

  List<KebutuhanModel> _items = [];
  bool _loading = true;
  String? _error;

  // IDs currently fading out
  final Set<int> _fadingIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await KebutuhanApi().fetchKebutuhan(widget.pantiId);
      if (mounted) setState(() { _items = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = '$e'; _loading = false; });
    }
  }

  Future<void> _deleteItem(KebutuhanModel item) async {
    // Start fade-out animation
    setState(() => _fadingIds.add(item.id));

    // Wait for fade animation to finish
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    try {
      await KebutuhanApi().deleteKebutuhan(widget.userId, item.id);
      if (mounted) {
        setState(() {
          _fadingIds.remove(item.id);
          _items.removeWhere((e) => e.id == item.id);
        });
      }
    } catch (e) {
      // Revert fade if API call failed
      if (mounted) {
        setState(() => _fadingIds.remove(item.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kebutuhan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF28695)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('Gagal memuat', style: TextStyle(color: Colors.grey.shade400)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _load,
                        child: const Text('Coba lagi', style: TextStyle(color: Color(0xFFF28695))),
                      ),
                    ],
                  ),
                )
              : _items.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada kebutuhan.\nTambahkan kebutuhan pertama!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 28,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _items.length,
                      itemBuilder: (context, i) {
                        final item = _items[i];
                        return AnimatedOpacity(
                          opacity: _fadingIds.contains(item.id) ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: _KebutuhanCard(
                            item: item,
                            onDelete: () => _deleteItem(item),
                          ),
                        );
                      },
                    ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ElevatedButton(
            onPressed: _goToTambah,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPink,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text(
              'Tambahkan Kebutuhan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _goToTambah() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => KebutuhanTambahPantiPage(
          pantiId: widget.pantiId,
          userId: widget.userId,
        ),
      ),
    );
    if (added == true) _load();
  }
}

// ─── Kebutuhan Card ───────────────────────────────────────────────────────────

class _KebutuhanCard extends StatelessWidget {
  final KebutuhanModel item;
  final VoidCallback onDelete;

  const _KebutuhanCard({required this.item, required this.onDelete});

  static const Color _kPinkLight = Color(0xFFFDE8EA);
  static const Color _kPinkBadge = Color(0xFFF28695);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Main card
            Container(
              width: double.infinity,
              height: 148,
              decoration: BoxDecoration(
                color: _kPinkLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(
                  _iconFor(item.nama),
                  size: 72,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            // Checkmark badge (top-right) — tap to delete
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: _kPinkBadge,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          item.nama,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '${item.jumlah} ${item.satuan}',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF555555),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
