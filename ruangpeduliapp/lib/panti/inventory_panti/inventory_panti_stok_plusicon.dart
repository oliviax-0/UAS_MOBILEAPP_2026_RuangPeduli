// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/data/inventory_api.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'inventory_panti_produkbaru.dart' show TambahProdukScreen;

// ─── Constants ───────────────────────────────────────────────────────────────

const Color kPink = Color(0xFFF28C9F);
const Color kPinkLight = Color(0xFFFDE8EC);
const Color kGreen = Color(0xFF2DB34A);
const Color kRed = Color(0xFFE53935);

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN FLOW — Opsi Dialog
// ═══════════════════════════════════════════════════════════════════════════════

/// Call this from inventaris_panti.dart when the + button in Stok is tapped
void showStokOpsiDialog(BuildContext context, {int? pantiId, int? userId}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (_) => _StokOpsiDialog(pantiId: pantiId, userId: userId),
  );
}

class _StokOpsiDialog extends StatelessWidget {
  final int? pantiId;
  final int? userId;
  const _StokOpsiDialog({this.pantiId, this.userId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: kPink,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Opsi lain',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A1A1A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tambahkan Produk
            _OpsiTile(
              icon: Icons.add_box_outlined,
              label: 'Tambahkan Produk',
              onTap: () {
                Navigator.pop(context);
                if (pantiId != null && userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TambahProdukScreen(
                        pantiId: pantiId!,
                        userId: userId!,
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            // Lihat Laporan
            _OpsiTile(
              icon: Icons.description_outlined,
              label: 'Lihat Laporan',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LaporanStokScreen(pantiId: pantiId)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OpsiTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OpsiTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FLOW 2 & 3 — Laporan Stok
// ═══════════════════════════════════════════════════════════════════════════════

const List<LaporanItemModel> _dummyLaporan = [
  LaporanItemModel(categoryName: 'Bahan Pokok', productName: 'Beras Merah',    amount: 5,  unit: 'kg',    isMasuk: true,  tanggal: '2026-04-01'),
  LaporanItemModel(categoryName: 'Minuman',     productName: 'Susu Kedelai',   amount: 3,  unit: 'liter', isMasuk: false, tanggal: '2026-04-01'),
  LaporanItemModel(categoryName: 'Bahan Pokok', productName: 'Minyak Goreng',  amount: 2,  unit: 'liter', isMasuk: true,  tanggal: '2026-04-02'),
  LaporanItemModel(categoryName: 'Bahan Pokok', productName: 'Minyak Goreng',  amount: 1,  unit: 'liter', isMasuk: false, tanggal: '2026-04-02'),
  LaporanItemModel(categoryName: 'Obat-obatan', productName: 'Obat Pilek',     amount: 10, unit: 'pcs',   isMasuk: true,  tanggal: '2026-04-03'),
  LaporanItemModel(categoryName: 'Bahan Pokok', productName: 'Singkong',       amount: 5,  unit: 'kg',    isMasuk: true,  tanggal: '2026-04-04'),
  LaporanItemModel(categoryName: 'Minuman',     productName: 'Teh Kotak',      amount: 12, unit: 'pcs',   isMasuk: false, tanggal: '2026-04-05'),
  LaporanItemModel(categoryName: 'Perlengkapan',productName: 'Sabun Mandi',    amount: 6,  unit: 'pcs',   isMasuk: true,  tanggal: '2026-04-06'),
  LaporanItemModel(categoryName: 'Bahan Pokok', productName: 'Gula Pasir',     amount: 3,  unit: 'kg',    isMasuk: false, tanggal: '2026-04-07'),
  LaporanItemModel(categoryName: 'Obat-obatan', productName: 'Vitamin C',      amount: 20, unit: 'pcs',   isMasuk: true,  tanggal: '2026-04-07'),
  LaporanItemModel(categoryName: 'Perlengkapan',productName: 'Deterjen',       amount: 2,  unit: 'kg',    isMasuk: false, tanggal: '2026-04-08'),
  LaporanItemModel(categoryName: 'Bahan Pokok', productName: 'Tepung Terigu',  amount: 4,  unit: 'kg',    isMasuk: true,  tanggal: '2026-04-09'),
];

class LaporanStokScreen extends StatefulWidget {
  final int? pantiId;
  const LaporanStokScreen({super.key, this.pantiId});

  @override
  State<LaporanStokScreen> createState() => _LaporanStokScreenState();
}

class _LaporanStokScreenState extends State<LaporanStokScreen> {
  String _filterValue = 'Semua';
  String _searchQuery = '';
  final List<String> _filterOptions = ['Semua', 'Stok Masuk', 'Stok Keluar'];
  final _searchController = TextEditingController();

  final _stt = SpeechToText();
  bool _sttReady = false;
  bool _listening = false;

  List<LaporanItemModel> _allData = _dummyLaporan;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
    _stt.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _listening = false);
        }
      },
      onError: (_) { if (mounted) setState(() => _listening = false); },
    ).then((ok) { if (mounted) setState(() => _sttReady = ok); });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    if (!_sttReady) return;
    if (_listening) {
      await _stt.stop();
      setState(() => _listening = false);
      return;
    }
    final locales = await _stt.locales();
    String? localeId;
    for (final l in locales) {
      if (l.localeId.startsWith('id')) { localeId = l.localeId; break; }
    }
    await _stt.listen(
      localeId: localeId,
      onResult: (result) {
        if (result.finalResult && mounted) {
          final text = result.recognizedWords;
          _searchController.text = text;
          setState(() { _searchQuery = text; _listening = false; });
        }
      },
    );
    if (mounted) setState(() => _listening = true);
  }

  Future<void> _fetchLaporan() async {
    if (widget.pantiId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final data = await InventoryApi().fetchLaporan(widget.pantiId!);
      if (mounted) setState(() { _allData = data.isEmpty ? _dummyLaporan : data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _allData = _dummyLaporan; _loading = false; });
    }
  }

  List<LaporanItemModel> get _filtered {
    var list = List<LaporanItemModel>.from(_allData);
    if (_filterValue == 'Stok Masuk') list = list.where((e) => e.isMasuk).toList();
    if (_filterValue == 'Stok Keluar') list = list.where((e) => !e.isMasuk).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((e) =>
        e.categoryName.toLowerCase().contains(q) ||
        e.productName.toLowerCase().contains(q),
      ).toList();
    }
    // Latest first
    list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return list;
  }

  String _formatDateLabel(String tanggal) {
    const months = ['', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
                        'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    try {
      final parts = tanggal.split('-');
      final day   = int.parse(parts[2]).toString().padLeft(2, '0');
      final month = months[int.parse(parts[1])];
      final year  = parts[0];
      return '$day $month $year';
    } catch (_) { return tanggal; }
  }

  List<Object> get _groupedItems {
    final items = _filtered;
    final List<Object> result = [];
    String? lastDate;
    for (final item in items) {
      if (item.tanggal != lastDate) {
        result.add(item.tanggal);
        lastDate = item.tanggal;
      }
      result.add(item);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // ── Fixed top section ──────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar area
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Laporan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.info_outline_rounded, size: 18, color: Colors.grey[400]),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                            color: _listening ? kPink : Colors.grey[400],
                            size: 20,
                          ),
                          onPressed: _toggleMic,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Draggable sheet ────────────────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.72,
            maxChildSize: 1.0,
            snap: true,
            snapSizes: const [0.72, 1.0],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: kPink,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 6),
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Filter row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _filterValue,
                                isDense: true,
                                icon: const Icon(Icons.tune_rounded, size: 18, color: Color(0xFF1A1A1A)),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                                items: _filterOptions
                                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (v) => setState(() => _filterValue = v ?? 'Semua'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // List
                    Expanded(
                      child: _loading
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : _error != null
                              ? Center(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : _filtered.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Tidak ada data laporan.',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  : Builder(builder: (context) {
                                      final grouped = _groupedItems;
                                      return ListView.builder(
                                        controller: scrollController,
                                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                                        itemCount: grouped.length,
                                        itemBuilder: (context, index) {
                                          final item = grouped[index];
                                          if (item is String) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 12, bottom: 6),
                                              child: Text(
                                                _formatDateLabel(item),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white70,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            );
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: _LaporanTile(item: item as LaporanItemModel),
                                          );
                                        },
                                      );
                                    }),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Laporan Tile ─────────────────────────────────────────────────────────────

class _LaporanTile extends StatelessWidget {
  final LaporanItemModel item;
  const _LaporanTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.isMasuk ? kGreen : kRed;
    final icon = item.isMasuk ? Icons.add : Icons.remove;
    final arrow = item.isMasuk ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Container(width: 1.5, height: 36, color: Colors.grey[200]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.categoryName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 2),
                Text(item.productName, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.formattedAmount,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 2),
              Icon(arrow, color: color, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}