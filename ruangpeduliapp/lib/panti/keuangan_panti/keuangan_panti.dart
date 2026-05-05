// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/data/finance_api.dart';
import 'package:ruangpeduliapp/data/inventory_api.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const Color kPink = Color(0xFFF28C9F);
const Color kPinkDark = Color(0xFFE5728A);
const Color kSalmon = Color(0xFFF2C4BC);
const Color kGreen = Color(0xFF2DB34A);
const Color kRed = Color(0xFFE53935);

// ─── Main Page ───────────────────────────────────────────────────────────────

class KeuanganPanti extends StatefulWidget {
  final int? userId;
  final int? pantiId;
  final int refreshTrigger;
  const KeuanganPanti({super.key, this.userId, this.pantiId, this.refreshTrigger = 0});

  @override
  State<KeuanganPanti> createState() => _KeuanganPantiState();
}

class _KeuanganPantiState extends State<KeuanganPanti> {
  bool _balanceVisible = true;

  FinanceDashboard? _dashboard;
  List<TransactionModel> _transactions = [];
  bool _loading = true;
  String? _error;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _fetchData(silent: true);
    });
  }

  @override
  void didUpdateWidget(KeuanganPanti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTrigger != widget.refreshTrigger) {
      _fetchData();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData({bool silent = false}) async {
    if (widget.userId == null) return;
    if (!silent) setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        FinanceApi().fetchDashboard(widget.userId!),
        FinanceApi().fetchTransactions(widget.userId!),
      ]);
      if (mounted) {
        setState(() {
          _dashboard = results[0] as FinanceDashboard;
          _transactions = results[1] as List<TransactionModel>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  Future<void> _deleteTransaction(TransactionModel tx) async {
    if (widget.userId == null) return;
    try {
      if (tx.isIncome) {
        await FinanceApi().deletePemasukan(widget.userId!, tx.id);
      } else {
        await FinanceApi().deletePengeluaran(widget.userId!, tx.id);
      }
      _fetchData();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  String _formatRp(double amount) {
    final formatted = amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  String _formatDateLabel(String tanggal) {
    const months = [
      '', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    try {
      final parts = tanggal.split('-');
      final day = int.parse(parts[2]).toString().padLeft(2, '0');
      final month = months[int.parse(parts[1])];
      final year = parts[0];
      return '$day $month $year';
    } catch (_) {
      return tanggal;
    }
  }

  // Returns a flat list of items: either a String (date header) or TransactionModel
  List<Object> _buildGroupedItems() {
    final List<Object> items = [];
    String? lastDate;
    for (final tx in _transactions) {
      if (tx.tanggal != lastDate) {
        items.add(tx.tanggal); // date header marker
        lastDate = tx.tanggal;
      }
      items.add(tx);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildDashboardCard(),
            ),
          ],
        ),
        _buildTransactionSection(),
      ],
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: kPink.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.account_balance_wallet_outlined,
                  color: kPink, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Keuangan',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dashboard Card ───────────────────────────────────────────────────────

  Widget _buildDashboardCard() {
    final pemasukan =
        _dashboard != null ? _formatRp(_dashboard!.totalPemasukan) : 'Rp ——';
    final pengeluaran =
        _dashboard != null ? _formatRp(_dashboard!.totalPengeluaran) : 'Rp ——';
    final saldo = _dashboard != null ? _formatRp(_dashboard!.saldo.clamp(0, double.infinity)) : 'Rp ——';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSalmon,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPink.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dasbor',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7A4040)),
              ),
              GestureDetector(
                onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                child: Icon(
                  _balanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF7A4040),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pemasukan',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF7A4040))),
                      const SizedBox(height: 4),
                      Text(
                        _balanceVisible ? pemasukan : 'Rp ••••••',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A)),
                      ),
                    ],
                  ),
                ),
                Container(
                    width: 1,
                    color: const Color(0xFFD49090),
                    margin: const EdgeInsets.symmetric(horizontal: 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pengeluaran',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF7A4040))),
                      const SizedBox(height: 4),
                      Text(
                        _balanceVisible ? pengeluaran : 'Rp ••••••',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saldo',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  _balanceVisible ? saldo : 'Rp ••••••••',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Transaction Section ─────────────────────────────────────────────────

  Widget _buildTransactionSection() {
    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.35,
      maxChildSize: 1.0,
      snap: true,
      snapSizes: const [1.0],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: kPink,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // ── Header row ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
                child: const Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : _error != null
                        ? Center(
                            child: Text(_error!,
                                style: const TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center))
                        : _transactions.isEmpty
                            ? const Center(
                                child: Text('Belum ada transaksi.',
                                    style: TextStyle(color: Colors.white70)))
                            : RefreshIndicator(
                                onRefresh: () => _fetchData(),
                                color: kPink,
                                child: Builder(builder: (context) {
                                  final grouped = _buildGroupedItems();
                                  return ListView.builder(
                                    controller: scrollController,
                                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                                    itemCount: grouped.length,
                                    itemBuilder: (context, index) {
                                      final item = grouped[index];
                                      if (item is String) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 12, bottom: 6),
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
                                      final tx = item as TransactionModel;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Dismissible(
                                          key: ValueKey('${tx.isIncome}-${tx.id}'),
                                          direction: DismissDirection.endToStart,
                                          background: Container(
                                            alignment: Alignment.centerRight,
                                            padding: const EdgeInsets.only(right: 20),
                                            decoration: BoxDecoration(
                                              color: kRed,
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.white),
                                          ),
                                          onDismissed: (_) => _deleteTransaction(tx),
                                          child: _TransactionTile(item: tx),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Transaction Tile ─────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final TransactionModel item;
  const _TransactionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isIncome = item.isIncome;
    final typeColor = isIncome ? kGreen : kRed;
    final typeIcon = isIncome ? Icons.add : Icons.remove;
    final arrowIcon =
        isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(typeIcon, color: typeColor, size: 18),
          ),
          const SizedBox(width: 10),
          Container(width: 1.5, height: 36, color: Colors.grey[200]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subLabel,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.formattedAmount,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 2),
              Icon(arrowIcon, color: typeColor, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Choice Button ────────────────────────────────────────────────────────────

// ─── Tambah Pemasukan Dialog ──────────────────────────────────────────────────

class TrxTile extends StatelessWidget {
  final int id;
  final String kategori;
  final double nominal;
  final String tanggal;
  final String tipe;
  final VoidCallback onDelete;

  const TrxTile({
    super.key,
    required this.id,
    required this.kategori,
    required this.nominal,
    required this.tanggal,
    required this.tipe,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDelete,
      child: _TransactionTile(
        item: TransactionModel(
          id: id,
          category: kategori,
          subLabel: tanggal,
          jumlah: nominal,
          isIncome: tipe == 'pemasukan',
          tanggal: tanggal,
          createdAt: tanggal,
        ),
      ),
    );
  }
}

class _TambahPemasukanDialog extends StatefulWidget {
  final int userId;
  final VoidCallback onSaved;
  const _TambahPemasukanDialog({required this.userId, required this.onSaved});

  @override
  State<_TambahPemasukanDialog> createState() => _TambahPemasukanDialogState();
}

class _TambahPemasukanDialogState extends State<_TambahPemasukanDialog> {
  final _jumlahController = TextEditingController();
  final _catatanController = TextEditingController();
  List<JenisPemasukanModel> _jenisList = [];
  JenisPemasukanModel? _selectedJenis;
  DateTime _tanggal = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    FinanceApi().fetchJenisPemasukan(widget.userId).then((list) {
      if (mounted)
        setState(() {
          _jenisList = list;
          if (list.isNotEmpty) _selectedJenis = list.first;
        });
    });
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final jumlah = double.tryParse(_jumlahController.text.trim());
    if (_selectedJenis == null || jumlah == null) return;
    setState(() => _saving = true);
    try {
      await FinanceApi().addPemasukan(
        widget.userId,
        _selectedJenis!.id,
        jumlah,
        _catatanController.text.trim(),
        '${_tanggal.year}-${_tanggal.month.toString().padLeft(2, '0')}-${_tanggal.day.toString().padLeft(2, '0')}',
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah Pemasukan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            const Text('Jenis',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(30)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<JenisPemasukanModel>(
                  isExpanded: true,
                  value: _selectedJenis,
                  hint: const Text('Pilih jenis',
                      style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA))),
                  items: _jenisList
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e.nama)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedJenis = v),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Jumlah (Rp)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Catatan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _catatanController,
              decoration: InputDecoration(
                hintText: 'Opsional',
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _tanggal,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _tanggal = picked);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(30)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: Color(0xFF888888)),
                    const SizedBox(width: 8),
                    Text(
                      '${_tanggal.day}/${_tanggal.month}/${_tanggal.year}',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF1A1A1A)),
                    ),
                  ],
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
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tambah Pengeluaran Dialog ────────────────────────────────────────────────

class _TambahPengeluaranDialog extends StatefulWidget {
  final int userId;
  final VoidCallback onSaved;
  const _TambahPengeluaranDialog({required this.userId, required this.onSaved});

  @override
  State<_TambahPengeluaranDialog> createState() =>
      _TambahPengeluaranDialogState();
}

class _TambahPengeluaranDialogState extends State<_TambahPengeluaranDialog> {
  final _jumlahController = TextEditingController();
  final _catatanController = TextEditingController();
  final List<CategoryModel> _kategoriList = [];
  CategoryModel? _selectedKategori;
  DateTime _tanggal = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final jumlah = double.tryParse(_jumlahController.text.trim());
    if (_selectedKategori == null || jumlah == null) return;
    setState(() => _saving = true);
    try {
      await FinanceApi().addPengeluaran(
        widget.userId,
        _selectedKategori!.id,
        jumlah,
        _catatanController.text.trim(),
        '${_tanggal.year}-${_tanggal.month.toString().padLeft(2, '0')}-${_tanggal.day.toString().padLeft(2, '0')}',
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah Pengeluaran',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            const Text('Kategori',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(30)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CategoryModel>(
                  isExpanded: true,
                  value: _selectedKategori,
                  hint: const Text('Pilih kategori',
                      style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA))),
                  items: _kategoriList
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedKategori = v),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Jumlah (Rp)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Catatan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _catatanController,
              decoration: InputDecoration(
                hintText: 'Opsional',
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _tanggal,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _tanggal = picked);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(30)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: Color(0xFF888888)),
                    const SizedBox(width: 8),
                    Text(
                      '${_tanggal.day}/${_tanggal.month}/${_tanggal.year}',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF1A1A1A)),
                    ),
                  ],
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
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
