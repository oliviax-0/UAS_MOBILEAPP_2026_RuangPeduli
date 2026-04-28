import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/data/kebutuhan_api.dart';

class KebutuhanTambahPantiPage extends StatefulWidget {
  final int pantiId;
  final int userId;

  const KebutuhanTambahPantiPage({super.key, required this.pantiId, required this.userId});

  @override
  State<KebutuhanTambahPantiPage> createState() => _KebutuhanTambahPantiPageState();
}

class _KebutuhanTambahPantiPageState extends State<KebutuhanTambahPantiPage> {
  static const Color _kPink = Color(0xFFF28695);

  final _namaCtrl   = TextEditingController();
  final _jumlahCtrl = TextEditingController();

  static const List<String> _satuanOptions = [
    'Kg', 'Liter', 'Pcs', 'Lusin', 'Dus', 'Gram', 'ml', 'Paket', 'Set',
  ];
  String? _selectedSatuan;
  bool _saving = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _jumlahCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nama   = _namaCtrl.text.trim();
    final jumlahStr = _jumlahCtrl.text.trim();
    if (nama.isEmpty) {
      _showError('Nama kebutuhan wajib diisi');
      return;
    }
    if (_selectedSatuan == null) {
      _showError('Pilih satuan terlebih dahulu');
      return;
    }
    final jumlah = int.tryParse(jumlahStr);
    if (jumlah == null || jumlah <= 0) {
      _showError('Jumlah harus berupa angka positif');
      return;
    }

    setState(() => _saving = true);
    try {
      await KebutuhanApi().addKebutuhan(widget.userId, nama, _selectedSatuan!, jumlah);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _showError('$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Nama Kebutuhan ──
            const Text(
              'Nama Kebutuhan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 10),
            _InputField(
              controller: _namaCtrl,
              hint: 'Ketik Nama Kebutuhan',
            ),
            const SizedBox(height: 24),

            // ── Satuan ──
            const Text(
              'Satuan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 10),
            _DropdownField(
              value: _selectedSatuan,
              hint: 'Pilih satuan yang digunakan',
              items: _satuanOptions,
              onChanged: (v) => setState(() => _selectedSatuan = v),
            ),
            const SizedBox(height: 24),

            // ── Jumlah ──
            const Text(
              'Jumlah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 10),
            _InputField(
              controller: _jumlahCtrl,
              hint: 'Ketik Jumlah',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPink,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _kPink.withValues(alpha: 0.6),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared input widgets ─────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1A1A1A)),
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
        ),
      ),
    );
  }
}
