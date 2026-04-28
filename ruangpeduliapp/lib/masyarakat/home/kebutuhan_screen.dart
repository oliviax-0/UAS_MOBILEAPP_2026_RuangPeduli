import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/data/kebutuhan_api.dart';

// ─────────────────────────────────────────────────────────────
//  KEBUTUHAN SCREEN
//  Dipanggil dari: PantiDetailScreen → tombol Kebutuhan
// ─────────────────────────────────────────────────────────────
class KebutuhanScreen extends StatefulWidget {
  final int? pantiId;
  final String namaPanti;
  final String username;
  final String? profilePicture;
  final int? userId;

  const KebutuhanScreen({
    super.key,
    this.pantiId,
    required this.namaPanti,
    required this.username,
    this.profilePicture,
    this.userId,
  });

  @override
  State<KebutuhanScreen> createState() => _KebutuhanScreenState();
}

class _KebutuhanScreenState extends State<KebutuhanScreen> {
  List<KebutuhanModel> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.pantiId == null) {
      setState(() { _loading = false; });
      return;
    }
    try {
      final data = await KebutuhanApi().fetchKebutuhan(widget.pantiId!);
      if (mounted) setState(() { _items = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = '$e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_rounded,
                        size: 24, color: Color(0xFF1A1A1A)),
                  ),
                  const Expanded(
                    child: Text(
                      'Kebutuhan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // ── Header panti ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF43D5E), width: 1.5),
                      color: Colors.grey.shade100,
                    ),
                    child: ClipOval(
                      child: widget.profilePicture != null
                          ? Image.network(
                              widget.profilePicture!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _avatarFallback(),
                            )
                          : _avatarFallback(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.namaPanti,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.username,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),

            // ── Grid ──
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFF47B8C)));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Gagal memuat kebutuhan',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _load,
              child: const Text('Coba lagi',
                  style: TextStyle(color: Color(0xFFF47B8C))),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Belum ada kebutuhan terdaftar',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        mainAxisExtent: 200,
      ),
      itemCount: _items.length,
      itemBuilder: (context, i) => _KebutuhanCard(item: _items[i]),
    );
  }

  Widget _avatarFallback() => Container(
        color: Colors.grey.shade200,
        child: Icon(Icons.business_rounded, size: 28, color: Colors.grey.shade400),
      );
}

// ─────────────────────────────────────────────────────────────
//  KEBUTUHAN CARD
// ─────────────────────────────────────────────────────────────
class _KebutuhanCard extends StatelessWidget {
  final KebutuhanModel item;
  const _KebutuhanCard({required this.item});

  static const Color _kPinkLight = Color(0xFFFDE8EA);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _kPinkLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(_iconFor(item.nama), size: 64, color: const Color(0xFF1A1A1A)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.nama,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '${item.jumlah} ${item.satuan}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ─── Icon auto-mapping (same as panti side) ──────────────────────────────────
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
