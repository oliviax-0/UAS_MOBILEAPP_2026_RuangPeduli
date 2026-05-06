// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ruangpeduliapp/data/residents_api.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const Color kPink = Color(0xFFF28C9F);
const Color kPinkLight = Color(0xFFFDE8EC);
const Color kCardPink = Color(0xFFFAE8EC);
const Color kRed = Color(0xFFE53935);

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

Widget _buildLabel(String text) => Text(
      text,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
    );

Widget _buildInputField({
  required TextEditingController controller,
  required String hint,
  TextInputType inputType = TextInputType.text,
  int? maxLength,
}) {
  return TextField(
    controller: controller,
    keyboardType: inputType,
    maxLength: maxLength,
    inputFormatters: maxLength != null
        ? [LengthLimitingTextInputFormatter(maxLength)]
        : null,
    style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: kPink, width: 1.5),
      ),
    ),
  );
}

Widget _buildSearchBarWidget(
    TextEditingController controller, VoidCallback onChanged) {
  return Container(
    height: 44,
    decoration: BoxDecoration(
      color: const Color(0xFFF2F2F2),
      borderRadius: BorderRadius.circular(30),
    ),
    child: TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// FLOW 1 — DAFTAR PEGAWAI
// ═══════════════════════════════════════════════════════════════════════════════

class DaftarPegawaiScreen extends StatefulWidget {
  final int? userId;
  const DaftarPegawaiScreen({super.key, required this.userId});

  @override
  State<DaftarPegawaiScreen> createState() => _DaftarPegawaiScreenState();
}

class _DaftarPegawaiScreenState extends State<DaftarPegawaiScreen> {
  List<PekerjaModel> _pegawaiData = [];
  bool _loading = true;
  String? _error;
  String? _filterValue;
  final _searchController = TextEditingController();

  List<String> get _filterOptions {
    final divisis = _pegawaiData.map((e) => e.divisi).toSet().toList()..sort();
    return ['Semua', ...divisis];
  }

  List<PekerjaModel> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    var list = _pegawaiData;
    if (_filterValue != null && _filterValue != 'Semua') {
      list = list.where((e) => e.divisi == _filterValue).toList();
    }
    if (query.isEmpty) return list;
    return list
        .where((e) =>
            e.nama.toLowerCase().contains(query) ||
            e.divisi.toLowerCase().contains(query) ||
            e.posisi.toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchPekerja();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPekerja() async {
    // ✅ dummy/test mode: kalau userId null, jangan panggil API
    if (widget.userId == null) {
      if (!mounted) return;
      setState(() {
        _pegawaiData = [];
        _loading = false;
        _error = null;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await ResidentsApi().fetchPekerja(widget.userId!);
      if (mounted) {
        setState(() {
          _pegawaiData = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _showTambahPegawaiDialog() async {
    if (widget.userId == null) return;
    final added = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => _TambahPegawaiDialog(userId: widget.userId!),
    );
    if (added == true) _fetchPekerja();
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
        title: const Text(
          'Pegawai',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A)),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search + Filter row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                    child: _buildSearchBarWidget(
                        _searchController, () => setState(() {}))),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterOptions.contains(_filterValue ?? 'Semua')
                          ? (_filterValue ?? 'Semua')
                          : 'Semua',
                      isDense: true,
                      icon: const Icon(Icons.tune_rounded,
                          size: 18, color: Color(0xFF1A1A1A)),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A)),
                      items: _filterOptions
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _filterValue = v),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Jumlah: ${_filtered.length}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A)),
            ),
          ),
          const SizedBox(height: 10),

          // List
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(kPink)))
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center))
                    : _filtered.isEmpty
                        ? const Center(
                            child: Text('Belum ada pegawai.',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, index) => _PegawaiCard(
                              item: _filtered[index],
                              userId: widget.userId!,
                              onChanged: _fetchPekerja,
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTambahPegawaiDialog,
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Color(0xFFE5728A), size: 28),
      ),
    );
  }
}

class _PegawaiCard extends StatelessWidget {
  final PekerjaModel item;
  final int userId;
  final VoidCallback onChanged;
  const _PegawaiCard(
      {required this.item, required this.userId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final changed = await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withOpacity(0.35),
          builder: (_) => _EditPegawaiDialog(item: item, userId: userId),
        );
        if (changed == true) onChanged();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kCardPink,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Nama', item.nama),
            const SizedBox(height: 4),
            _infoRow('Divisi', item.divisi),
            const SizedBox(height: 4),
            _infoRow('Posisi/jabatan', item.posisi),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
        ),
        Text(': ',
            style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A)),
          ),
        ),
      ],
    );
  }
}

// ─── Tambah Pegawai Dialog ────────────────────────────────────────────────────

class _TambahPegawaiDialog extends StatefulWidget {
  final int userId;
  const _TambahPegawaiDialog({required this.userId});

  @override
  State<_TambahPegawaiDialog> createState() => _TambahPegawaiDialogState();
}

class _TambahPegawaiDialogState extends State<_TambahPegawaiDialog> {
  final _namaController = TextEditingController();
  final _divisiController = TextEditingController();
  final _jabatanController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _namaController.dispose();
    _divisiController.dispose();
    _jabatanController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nama = _namaController.text.trim();
    final divisi = _divisiController.text.trim();
    final jabatan = _jabatanController.text.trim();
    if (nama.isEmpty || divisi.isEmpty || jabatan.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ResidentsApi().addPekerja(widget.userId, nama, divisi, jabatan);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Nama Lengkap'),
            const SizedBox(height: 8),
            _buildInputField(
                controller: _namaController, hint: 'Ketik Nama Staf'),
            const SizedBox(height: 14),
            _buildLabel('Divisi'),
            const SizedBox(height: 8),
            _buildInputField(
                controller: _divisiController, hint: 'Ketik Divisi'),
            const SizedBox(height: 14),
            _buildLabel('Jabatan'),
            const SizedBox(height: 8),
            _buildInputField(
                controller: _jabatanController, hint: 'Ketik Jabatan'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1A1A),
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Batal',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Unggah',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Edit Pegawai Dialog ──────────────────────────────────────────────────────

class _EditPegawaiDialog extends StatefulWidget {
  final PekerjaModel item;
  final int userId;
  const _EditPegawaiDialog({required this.item, required this.userId});

  @override
  State<_EditPegawaiDialog> createState() => _EditPegawaiDialogState();
}

class _EditPegawaiDialogState extends State<_EditPegawaiDialog> {
  late final TextEditingController _namaController;
  late final TextEditingController _divisiController;
  late final TextEditingController _jabatanController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.item.nama);
    _divisiController = TextEditingController(text: widget.item.divisi);
    _jabatanController = TextEditingController(text: widget.item.posisi);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _divisiController.dispose();
    _jabatanController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nama = _namaController.text.trim();
    final divisi = _divisiController.text.trim();
    final jabatan = _jabatanController.text.trim();
    if (nama.isEmpty || divisi.isEmpty || jabatan.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ResidentsApi()
          .updatePekerja(widget.userId, widget.item.id, nama, divisi, jabatan);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pegawai tersebut?',
          style: TextStyle(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFDDDDDD)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text('Ya', style: TextStyle(color: Color(0xFF1A1A1A))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8848A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text('Tidak'),
          ),
        ],
      ),
    );
    if (confirmed == true) _delete();
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    try {
      await ResidentsApi().deletePekerja(widget.userId, widget.item.id);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.edit_outlined, size: 20, color: Color(0xFF1A1A1A)),
                SizedBox(width: 8),
                Text(
                  'Edit Pegawai',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildLabel('Nama Lengkap'),
            const SizedBox(height: 8),
            _buildInputField(controller: _namaController, hint: 'Nama Lengkap'),
            const SizedBox(height: 14),
            _buildLabel('Divisi'),
            const SizedBox(height: 8),
            _buildInputField(controller: _divisiController, hint: 'Divisi'),
            const SizedBox(height: 14),
            _buildLabel('Jabatan'),
            const SizedBox(height: 8),
            _buildInputField(controller: _jabatanController, hint: 'Jabatan'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1A1A),
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Batal',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Simpan',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _saving ? null : _confirmAndDelete,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: kRed, size: 22),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tambah Penghuni Dialog ───────────────────────────────────────────────────

class _TambahPenghuniDialog extends StatefulWidget {
  final int userId;
  const _TambahPenghuniDialog({required this.userId});

  @override
  State<_TambahPenghuniDialog> createState() => _TambahPenghuniDialogState();
}

class _TambahPenghuniDialogState extends State<_TambahPenghuniDialog> {
  final _namaController = TextEditingController();
  final _tahunLahirController = TextEditingController();
  String? _jenisKelamin;
  bool _saving = false;

  @override
  void dispose() {
    _namaController.dispose();
    _tahunLahirController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nama = _namaController.text.trim();
    final tahun = int.tryParse(_tahunLahirController.text.trim());
    final currentYear = DateTime.now().year;
    if (nama.isEmpty || tahun == null || _jenisKelamin == null) return;
    if (tahun > currentYear || tahun < 1900) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tahun lahir tidak valid (1900–$currentYear)')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ResidentsApi()
          .addPenghuni(widget.userId, nama, tahun, _jenisKelamin!);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Nama Lengkap'),
            const SizedBox(height: 8),
            _buildInputField(
                controller: _namaController, hint: 'Ketik Nama Penghuni'),
            const SizedBox(height: 14),
            _buildLabel('Tahun Lahir'),
            const SizedBox(height: 8),
            _buildInputField(
                controller: _tahunLahirController,
                hint: 'Ketik Tahun Lahir',
                inputType: TextInputType.number,
                maxLength: 4),
            const SizedBox(height: 14),
            _buildLabel('Jenis Kelamin'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(30)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _jenisKelamin,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF1A1A1A)),
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                  items: [
                    ('laki-laki', 'Laki-laki'),
                    ('perempuan', 'Perempuan')
                  ]
                      .map((e) =>
                          DropdownMenuItem(value: e.$1, child: Text(e.$2)))
                      .toList(),
                  onChanged: (v) => setState(() => _jenisKelamin = v),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1A1A),
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Batal',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Unggah',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FLOW 2 — DAFTAR PENGHUNI
// ═══════════════════════════════════════════════════════════════════════════════

class DaftarPenghuniScreen extends StatefulWidget {
  final int? userId;
  const DaftarPenghuniScreen({super.key, required this.userId});

  @override
  State<DaftarPenghuniScreen> createState() => _DaftarPenghuniScreenState();
}

class _DaftarPenghuniScreenState extends State<DaftarPenghuniScreen> {
  List<PenghuniModel> _penghuniData = [];
  bool _loading = true;
  String? _error;
  String? _filterValue;
  final _searchController = TextEditingController();

  final List<String> _filterOptions = ['Semua', 'laki-laki', 'perempuan'];

  List<PenghuniModel> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    var list = _penghuniData;
    if (_filterValue != null && _filterValue != 'Semua') {
      list = list
          .where((e) =>
              e.jenisKelamin.toLowerCase() == _filterValue!.toLowerCase())
          .toList();
    }
    if (query.isEmpty) return list;
    return list.where((e) => e.nama.toLowerCase().contains(query)).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchPenghuni();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPenghuni() async {
    // ✅ dummy/test mode: kalau userId null, jangan panggil API
    if (widget.userId == null) {
      if (!mounted) return;
      setState(() {
        _penghuniData = [];
        _loading = false;
        _error = null;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await ResidentsApi().fetchPenghuni(widget.userId!);
      if (mounted) {
        setState(() {
          _penghuniData = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _showTambahPenghuniDialog() async {
    if (widget.userId == null) return;
    final added = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => _TambahPenghuniDialog(userId: widget.userId!),
    );
    if (added == true) _fetchPenghuni();
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
        title: const Text(
          'Penghuni',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A)),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                    child: _buildSearchBarWidget(
                        _searchController, () => setState(() {}))),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterValue ?? 'Semua',
                      isDense: true,
                      icon: const Icon(Icons.tune_rounded,
                          size: 18, color: Color(0xFF1A1A1A)),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A)),
                      items: _filterOptions
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e == 'laki-laki'
                                  ? 'Laki-laki'
                                  : e == 'perempuan'
                                      ? 'Perempuan'
                                      : e)))
                          .toList(),
                      onChanged: (v) => setState(() => _filterValue = v),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Jumlah: ${_filtered.length}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A)),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(kPink)))
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center))
                    : _filtered.isEmpty
                        ? const Center(
                            child: Text('Belum ada penghuni.',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, index) => _PenghuniCard(
                              item: _filtered[index],
                              userId: widget.userId!,
                              onChanged: _fetchPenghuni,
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTambahPenghuniDialog,
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Color(0xFFE5728A), size: 28),
      ),
    );
  }
}

class _PenghuniCard extends StatelessWidget {
  final PenghuniModel item;
  final int userId;
  final VoidCallback onChanged;
  const _PenghuniCard(
      {required this.item, required this.userId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final changed = await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withOpacity(0.35),
          builder: (_) => _EditPenghuniDialog(item: item, userId: userId),
        );
        if (changed == true) onChanged();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kCardPink,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Nama', item.nama),
            const SizedBox(height: 4),
            _infoRow('Tahun Lahir', item.tahunLahir.toString()),
            const SizedBox(height: 4),
            _infoRow('Jenis Kelamin', item.jenisKelamin),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
        ),
        const Text(': ',
            style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A)),
          ),
        ),
      ],
    );
  }
}

// ─── Edit Penghuni Dialog ─────────────────────────────────────────────────────

class _EditPenghuniDialog extends StatefulWidget {
  final PenghuniModel item;
  final int userId;
  const _EditPenghuniDialog({required this.item, required this.userId});

  @override
  State<_EditPenghuniDialog> createState() => _EditPenghuniDialogState();
}

class _EditPenghuniDialogState extends State<_EditPenghuniDialog> {
  late final TextEditingController _namaController;
  late final TextEditingController _tahunLahirController;
  late String? _jenisKelamin;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.item.nama);
    _tahunLahirController =
        TextEditingController(text: widget.item.tahunLahir.toString());
    _jenisKelamin = widget.item.jenisKelamin;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tahunLahirController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nama = _namaController.text.trim();
    final tahun = int.tryParse(_tahunLahirController.text.trim());
    final currentYear = DateTime.now().year;
    if (nama.isEmpty || tahun == null || _jenisKelamin == null) return;
    if (tahun > currentYear || tahun < 1900) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tahun lahir tidak valid (1900–$currentYear)')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ResidentsApi().updatePenghuni(
          widget.userId, widget.item.id, nama, tahun, _jenisKelamin!);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Text(
          'Apakah Anda yakin ingin menghapus penghuni tersebut?',
          style: TextStyle(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFDDDDDD)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text('Ya', style: TextStyle(color: Color(0xFF1A1A1A))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8848A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text('Tidak'),
          ),
        ],
      ),
    );
    if (confirmed == true) _delete();
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    try {
      await ResidentsApi().deletePenghuni(widget.userId, widget.item.id);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.edit_outlined, size: 20, color: Color(0xFF1A1A1A)),
                SizedBox(width: 8),
                Text(
                  'Edit Penghuni',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildLabel('Nama Lengkap'),
            const SizedBox(height: 8),
            _buildInputField(controller: _namaController, hint: 'Nama Lengkap'),
            const SizedBox(height: 14),
            _buildLabel('Tahun Lahir'),
            const SizedBox(height: 8),
            _buildInputField(
                controller: _tahunLahirController,
                hint: 'Tahun Lahir',
                inputType: TextInputType.number,
                maxLength: 4),
            const SizedBox(height: 14),
            _buildLabel('Jenis Kelamin'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(30)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _jenisKelamin,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF1A1A1A)),
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                  items: [
                    ('laki-laki', 'Laki-laki'),
                    ('perempuan', 'Perempuan')
                  ]
                      .map((e) =>
                          DropdownMenuItem(value: e.$1, child: Text(e.$2)))
                      .toList(),
                  onChanged: (v) => setState(() => _jenisKelamin = v),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1A1A),
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Batal',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Simpan',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _saving ? null : _confirmAndDelete,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: kRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: kRed, size: 22),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
