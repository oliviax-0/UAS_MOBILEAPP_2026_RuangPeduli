import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/data/inventory_api.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const Color kPink = Color(0xFFF28C9F);

// ═══════════════════════════════════════════════════════════════════════════════
// TAMBAH PRODUK SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class TambahProdukScreen extends StatefulWidget {
  final int pantiId;
  final int userId;

  const TambahProdukScreen({
    super.key,
    required this.pantiId,
    required this.userId,
  });

  @override
  State<TambahProdukScreen> createState() => _TambahProdukScreenState();
}

class _TambahProdukScreenState extends State<TambahProdukScreen> {
  final _namaController        = TextEditingController();
  final _pemakaianController   = TextEditingController();
  final _waktuTungguController = TextEditingController();

  // Categories loaded from API
  List<CategoryModel> _categories   = [];
  bool _loadingCategories            = true;
  CategoryModel? _selectedCategory;

  String? _selectedSatuan;
  String? _selectedSatuanWaktu;
  bool _saving       = false;
  bool _predictingAI = false;

  // AI suggestions
  List<({double dailyUsage, String reasoning})> _suggestions = [];
  bool _showAllSuggestions = false;

  final List<String> _satuanOptions = [
    'kg', 'liter', 'pcs', 'box', 'pack', 'butir', 'lusin',
  ];
  final List<String> _satuanWaktuOptions = ['Hari', 'Minggu', 'Bulan'];

  static const _satuanToDays = {'Hari': 1, 'Minggu': 7, 'Bulan': 30};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _pemakaianController.dispose();
    _waktuTungguController.dispose();
    super.dispose();
  }

  // ── Load categories ────────────────────────────────────────────────────────

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final cats = await InventoryApi().fetchCategories(widget.pantiId);
      if (mounted) setState(() { _categories = cats; _loadingCategories = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  // ── Add new category dialog ────────────────────────────────────────────────

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (_) => _AddCategoryDialog(
        onAdd: (name) async {
          // Duplicate check
          final dup = _categories.any((c) => c.name.toLowerCase() == name.toLowerCase());
          if (dup) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kategori "$name" sudah ada.'),
                backgroundColor: Colors.orange.shade700,
              ),
            );
            return;
          }

          final newCat = await InventoryApi().addCategory(widget.userId, name);
          if (!mounted) return;
          setState(() {
            _categories.add(newCat);
            _selectedCategory = newCat;
          });
        },
      ),
    );
  }

  // ── AI Prediction ──────────────────────────────────────────────────────────

  Future<void> _predictPhrr() async {
    final nama   = _namaController.text.trim();
    final satuan = _selectedSatuan ?? 'pcs';
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi nama produk terlebih dahulu.')),
      );
      return;
    }
    setState(() {
      _predictingAI       = true;
      _suggestions        = [];
      _showAllSuggestions = false;
    });
    try {
      final results = await InventoryApi().predictPhrr(widget.pantiId, nama, satuan);
      if (!mounted) return;
      setState(() { _suggestions = results; _predictingAI = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _predictingAI = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
    }
  }

  void _pickSuggestion(({double dailyUsage, String reasoning}) s) {
    setState(() {
      _pemakaianController.text = _formatUsage(s.dailyUsage);
      _suggestions        = [];
      _showAllSuggestions = false;
    });
  }

  String _formatUsage(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toString();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _onTambahkan() async {
    final nama = _namaController.text.trim();
    if (_selectedCategory == null || nama.isEmpty || _selectedSatuan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi kategori, nama produk, dan satuan.')),
      );
      return;
    }

    final double? dailyUsage = double.tryParse(_pemakaianController.text.trim());

    int? leadTimeDays;
    final wtVal = int.tryParse(_waktuTungguController.text.trim());
    if (wtVal != null && _selectedSatuanWaktu != null) {
      leadTimeDays = wtVal * (_satuanToDays[_selectedSatuanWaktu!] ?? 1);
    }

    setState(() => _saving = true);
    try {
      await InventoryApi().addItem(
        widget.userId, _selectedCategory!.id, nama, 0, _selectedSatuan!,
        dailyUsage:   dailyUsage,
        leadTimeDays: leadTimeDays,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
              'Tambahkan Produk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(width: 6),
            Tooltip(
              message: 'Isi detail produk untuk ditambahkan ke inventaris panti',
              child: Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Kategori Produk ───────────────────────────────────
                  _buildLabel('Kategori Produk'),
                  const SizedBox(height: 8),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showAddCategoryDialog,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_circle_outline_rounded, size: 16, color: kPink),
                        const SizedBox(width: 4),
                        Text(
                          'Tambah Kategori',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kPink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Nama Produk ───────────────────────────────────────
                  _buildLabel('Nama Produk'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: _namaController, hint: 'Ketik Nama Produk'),
                  const SizedBox(height: 18),

                  // ── Satuan ────────────────────────────────────────────
                  _buildLabel('Satuan'),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    hint: 'Pilih satuan yang digunakan',
                    value: _selectedSatuan,
                    items: _satuanOptions,
                    onChanged: (v) => setState(() => _selectedSatuan = v),
                  ),
                  const SizedBox(height: 18),

                  // ── Pemakaian Harian Rata-Rata (AI) ───────────────────
                  Row(children: [
                    _buildLabel('Pemakaian Harian Rata-Rata'),
                    const SizedBox(width: 6),
                    Tooltip(
                      message: 'AI memprediksi berdasarkan jenis produk, jumlah penghuni & pekerja panti',
                      child: Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey[400]),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _buildAIField(),
                  if (_suggestions.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildSuggestionPanel(),
                  ],
                  const SizedBox(height: 18),

                  // ── Waktu Tunggu Produk ───────────────────────────────
                  Row(children: [
                    _buildLabel('Waktu Tunggu Produk'),
                    const SizedBox(width: 6),
                    Tooltip(
                      message: 'Berapa lama waktu dari pemesanan sampai produk tiba',
                      child: Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey[400]),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _waktuTungguController,
                          hint: 'Ketik Angka',
                          inputType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDropdown(
                          hint: 'Satuan Waktu',
                          value: _selectedSatuanWaktu,
                          items: _satuanWaktuOptions,
                          onChanged: (v) => setState(() => _selectedSatuanWaktu = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Tambahkan Button ──────────────────────────────────────────
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _onTambahkan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Tambahkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Category dropdown (existing categories only) ─────────────────────────

  Widget _buildCategoryDropdown() {
    if (_loadingCategories) {
      return Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(30)),
        child: const Center(child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: kPink))),
      );
    }

    if (_categories.isEmpty) {
      return Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(30)),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Belum ada kategori — tambahkan di bawah', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(30)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Pilih Kategori Produk', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
          value: _selectedCategory?.id.toString(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1A1A1A)),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
          items: _categories.map(
            (c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.name)),
          ).toList(),
          onChanged: (v) {
            final cat = _categories.firstWhere((c) => c.id.toString() == v);
            setState(() => _selectedCategory = cat);
          },
        ),
      ),
    );
  }

  // ─── AI field ─────────────────────────────────────────────────────────────

  Widget _buildAIField() {
    return TextField(
      controller: _pemakaianController,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      onTap: () {
        if (_suggestions.isNotEmpty) setState(() => _suggestions = []);
      },
      decoration: InputDecoration(
        hintText: 'Ketik atau gunakan Rekomendasi AI',
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: GestureDetector(
          onTap: _predictingAI ? null : _predictPhrr,
          child: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _predictingAI
                ? const SizedBox(
                    width: 20, height: 20,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: kPink)))
                : const Icon(Icons.auto_fix_high_rounded, color: kPink, size: 22),
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: kPink, width: 1.5),
        ),
      ),
    );
  }

  // ─── Suggestion panel ─────────────────────────────────────────────────────

  Widget _buildSuggestionPanel() {
    final satuan  = _selectedSatuan ?? 'pcs';
    final visible = _showAllSuggestions ? _suggestions : _suggestions.take(2).toList();
    final hasMore = !_showAllSuggestions && _suggestions.length > 2;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ...visible.asMap().entries.map((entry) {
            final i    = entry.key;
            final s    = entry.value;
            final isLast = i == visible.length - 1 && !hasMore;
            return Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _pickSuggestion(s),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_fix_high_rounded, color: Color(0xFF555555), size: 18),
                        const SizedBox(width: 12),
                        Text(
                          '${_formatUsage(s.dailyUsage)} $satuan per Hari',
                          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFDDDDDD)),
              ],
            );
          }),
          if (hasMore) ...[
            const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFDDDDDD)),
            InkWell(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              onTap: () => setState(() => _showAllSuggestions = true),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.apps_rounded, color: Color(0xFF888888), size: 18),
                    SizedBox(width: 12),
                    Text('Load More...', style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: kPink, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(30)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1A1A1A)),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── Add Category Dialog ──────────────────────────────────────────────────────

class _AddCategoryDialog extends StatefulWidget {
  final Future<void> Function(String name) onAdd;
  const _AddCategoryDialog({required this.onAdd});

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nama Kategori Produk',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
              decoration: InputDecoration(
                hintText: 'Ketik Nama Kategori',
                hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: kPink, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _saving
                    ? null
                    : () async {
                        final name = _controller.text.trim();
                        if (name.isEmpty) return;
                        setState(() => _saving = true);
                        final nav = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await widget.onAdd(name);
                        } catch (e) {
                          if (!mounted) return;
                          setState(() => _saving = false);
                          messenger.showSnackBar(
                            SnackBar(content: Text('$e'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        if (!mounted) return;
                        nav.pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Tambahkan', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
