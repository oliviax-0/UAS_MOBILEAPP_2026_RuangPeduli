import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ruangpeduliapp/data/finance_api.dart';
import 'package:ruangpeduliapp/data/inventory_api.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const Color _kPink = Color(0xFFF28C9F);
const Color _kPinkLight = Color(0xFFFCEBED);

// Sentinel id used to represent the "add new" dropdown option
const int _kAddNewJenisId = -1;

// ─── Thousand-separator formatter ────────────────────────────────────────────

class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip all dots to get the raw digits
    final digits = newValue.text.replaceAll('.', '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    // Only allow digits
    if (!RegExp(r'^\d+$').hasMatch(digits)) return oldValue;

    // Insert dots every 3 digits from the right
    final formatted = digits.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ─── InputTransaksiPage ───────────────────────────────────────────────────────

class InputTransaksiPage extends StatefulWidget {
  final int userId;
  final int pantiId;
  final VoidCallback? onSaved;

  const InputTransaksiPage({
    super.key,
    required this.userId,
    required this.pantiId,
    this.onSaved,
  });

  @override
  State<InputTransaksiPage> createState() => _InputTransaksiPageState();
}

class _InputTransaksiPageState extends State<InputTransaksiPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onSaved() {
    widget.onSaved?.call();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Input Transaksi',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _TabBar(controller: _tabController),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PemasukanForm(userId: widget.userId, onSaved: _onSaved),
          _PengeluaranView(
              userId: widget.userId,
              pantiId: widget.pantiId,
              onSaved: _onSaved),
        ],
      ),
    );
  }
}

// ─── Custom Tab Bar ───────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final selected = controller.index;
    return Row(
      children: [
        Expanded(
            child: _TabChip(
                label: 'Pemasukan',
                selected: selected == 0,
                onTap: () => controller.animateTo(0))),
        const SizedBox(width: 8),
        Expanded(
            child: _TabChip(
                label: 'Pengeluaran',
                selected: selected == 1,
                onTap: () => controller.animateTo(1))),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? Colors.white : _kPink,
          borderRadius: BorderRadius.circular(30),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.black87 : Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─── Pemasukan Form ───────────────────────────────────────────────────────────

class _PemasukanForm extends StatefulWidget {
  final int userId;
  final VoidCallback onSaved;
  const _PemasukanForm({required this.userId, required this.onSaved});

  @override
  State<_PemasukanForm> createState() => _PemasukanFormState();
}

class _PemasukanFormState extends State<_PemasukanForm> {
  final _jumlahController = TextEditingController();
  final _catatanController = TextEditingController();

  List<JenisPemasukanModel> _jenisList = [];
  JenisPemasukanModel? _selectedJenis;
  bool _loadingJenis = true;
  bool _saving = false;

  // Sentinel item shown as last dropdown option
  static final _addNewItem =
      JenisPemasukanModel(id: _kAddNewJenisId, nama: '+ Jenis Pemasukan Baru...');

  @override
  void initState() {
    super.initState();
    _loadJenis();
  }

  Future<void> _loadJenis() async {
    setState(() => _loadingJenis = true);
    try {
      final list = await FinanceApi().fetchJenisPemasukan(widget.userId);
      if (mounted) {
        setState(() {
          _jenisList = list;
          if (list.isNotEmpty) _selectedJenis = list.first;
          _loadingJenis = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingJenis = false);
    }
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _promptAddNew() async {
    final ctrl = TextEditingController();
    final nama = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Jenis Pemasukan Baru',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nama jenis pemasukan',
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _kPink,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            onPressed: () => Navigator.pop(dialogCtx, ctrl.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    // Defer dispose so the dismissal animation can finish before controller is freed
    WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.dispose());
    if (nama == null || nama.isEmpty) return;

    try {
      final created = await FinanceApi().addJenisPemasukan(widget.userId, nama);
      if (mounted) {
        setState(() {
          _jenisList.add(created);
          _selectedJenis = created;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _save() async {
    final jumlah = double.tryParse(_jumlahController.text.replaceAll('.', '').trim());
    if (_selectedJenis == null || jumlah == null || jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lengkapi jenis dan jumlah pemasukan.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      await FinanceApi().addPemasukan(
        widget.userId,
        _selectedJenis!.id,
        jumlah,
        _catatanController.text.trim(),
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      );
      if (mounted) widget.onSaved();
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
    // Build dropdown items: real jenis + sentinel "add new"
    final dropdownItems = [
      ..._jenisList.map((e) => DropdownMenuItem<JenisPemasukanModel>(
            value: e,
            child: Text(e.nama),
          )),
      DropdownMenuItem<JenisPemasukanModel>(
        value: _addNewItem,
        child: Row(
          children: const [
            Icon(Icons.add, size: 16, color: _kPink),
            SizedBox(width: 6),
            Text('Jenis Pemasukan Baru...',
                style: TextStyle(color: _kPink, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Jenis Pemasukan ──────────────────────────────────────
                _FieldLabel('Jenis Pemasukan'),
                const SizedBox(height: 10),
                _loadingJenis
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: _kPink))
                    : _RoundedContainer(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<JenisPemasukanModel>(
                            isExpanded: true,
                            value: _selectedJenis,
                            hint: const Text(
                              'Pilih Jenis Pemasukan',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFAAAAAA)),
                            ),
                            icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF888888)),
                            items: dropdownItems,
                            onChanged: (v) async {
                              if (v?.id == _kAddNewJenisId) {
                                await _promptAddNew();
                                if (mounted) setState(() {});
                              } else {
                                setState(() => _selectedJenis = v);
                              }
                            },
                          ),
                        ),
                      ),

                const SizedBox(height: 24),

                // ── Jumlah Pemasukan ─────────────────────────────────────
                _FieldLabel('Jumlah Pemasukan'),
                const SizedBox(height: 10),
                _RoundedContainer(
                  child: Row(
                    children: [
                      const Text(
                        'Rp',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87),
                      ),
                      Container(
                        width: 1,
                        height: 22,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: const Color(0xFFCCCCCC),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _jumlahController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [_ThousandSeparatorFormatter()],
                          decoration: const InputDecoration(
                            hintText: 'Ketik Jumlah Pemasukan',
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFAAAAAA)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Catatan ──────────────────────────────────────────────
                _FieldLabel('Catatan'),
                const SizedBox(height: 10),
                _RoundedContainer(
                  child: TextField(
                    controller: _catatanController,
                    decoration: const InputDecoration(
                      hintText: 'Ketik Catatan',
                      hintStyle: TextStyle(
                          fontSize: 14, color: Color(0xFFAAAAAA)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _SaveButton(saving: _saving, onPressed: _save),
      ],
    );
  }
}

// ─── Pengeluaran View ─────────────────────────────────────────────────────────

class _PengeluaranView extends StatefulWidget {
  final int userId;
  final int pantiId;
  final VoidCallback onSaved;
  const _PengeluaranView(
      {required this.userId,
      required this.pantiId,
      required this.onSaved});

  @override
  State<_PengeluaranView> createState() => _PengeluaranViewState();
}

class _PengeluaranViewState extends State<_PengeluaranView> {
  List<CategoryModel> _categories = [];
  bool _loading = true;
  String? _error;
  bool _showAI = true;
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cats = await InventoryApi().fetchCategories(widget.pantiId);
      if (mounted) setState(() { _categories = cats; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<CategoryModel> get _displayedCategories {
    if (_showAI) {
      final sorted = List<CategoryModel>.from(_categories)
        ..sort((a, b) => b.itemCount.compareTo(a.itemCount));
      return sorted.take(5).toList();
    }
    return _categories;
  }

  Future<void> _onCategoryTap(CategoryModel category) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PengeluaranFormSheet(
        userId: widget.userId,
        category: category,
      ),
    );
    // Only call onSaved after the sheet is fully dismissed (animation complete)
    if (saved == true) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSettings) {
      return _PengaturanKategoriView(
        userId: widget.userId,
        categories: _categories,
        onBack: () => setState(() => _showSettings = false),
        onDeleted: (id) => setState(() {
          _categories.removeWhere((c) => c.id == id);
        }),
        onAdded: (cat) => setState(() {
          _categories.add(cat);
        }),
      );
    }

    return Column(
      children: [
        // ── Filter Chips ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              _FilterChip(
                label: 'Rekomendasi AI',
                selected: _showAI,
                onTap: () => setState(() => _showAI = true),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Semua Kategori',
                selected: !_showAI,
                onTap: () => setState(() => _showAI = false),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showSettings = true),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.settings_outlined,
                      size: 20, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),

        // ── AI Card ──────────────────────────────────────────────────────
        if (_showAI)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: _kPink, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Saya telah menyusun rangkuman mengenai kategori yang paling sering Anda pilih.',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // ── Category List ─────────────────────────────────────────────────
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: _kPink))
              : _error != null
                  ? Center(
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center))
                  : _displayedCategories.isEmpty
                      ? const Center(
                          child: Text('Belum ada kategori.',
                              style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: _displayedCategories.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  'Kategori: ${_displayedCategories.length}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }
                            final cat =
                                _displayedCategories[index - 1];
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 12),
                              child: _CategoryCard(
                                  category: cat,
                                  onTap: () => _onCategoryTap(cat)),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

// ─── Pengaturan Kategori View ─────────────────────────────────────────────────

class _PengaturanKategoriView extends StatefulWidget {
  final int userId;
  final List<CategoryModel> categories;
  final VoidCallback onBack;
  final void Function(int deletedId) onDeleted;
  final void Function(CategoryModel added) onAdded;

  const _PengaturanKategoriView({
    required this.userId,
    required this.categories,
    required this.onBack,
    required this.onDeleted,
    required this.onAdded,
  });

  @override
  State<_PengaturanKategoriView> createState() =>
      _PengaturanKategoriViewState();
}

class _PengaturanKategoriViewState extends State<_PengaturanKategoriView> {
  final Set<int> _deleting = {};

  Future<void> _delete(CategoryModel cat) async {
    setState(() => _deleting.add(cat.id));
    try {
      await InventoryApi().deleteCategory(widget.userId, cat.id);
      if (mounted) {
        widget.onDeleted(cat.id);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _deleting.remove(cat.id));
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _promptAdd() {
    showDialog(
      context: context,
      builder: (_) => _AddKategoriDialog(
        onAdd: (nama) async {
          final created = await InventoryApi().addCategory(widget.userId, nama);
          if (mounted) widget.onAdded(created);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: GestureDetector(
            onTap: widget.onBack,
            child: Row(
              children: const [
                Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  'Pengaturan Kategori',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
              ],
            ),
          ),
        ),

        // ── Category List ─────────────────────────────────────────────────
        Expanded(
          child: widget.categories.isEmpty
              ? const Center(
                  child: Text('Belum ada kategori.',
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: widget.categories.length,
                  itemBuilder: (context, index) {
                    final cat = widget.categories[index];
                    final isDeleting = _deleting.contains(cat.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: _kPinkLight,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                cat.name,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87),
                              ),
                            ),
                            isDeleting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black45))
                                : GestureDetector(
                                    onTap: () => _delete(cat),
                                    child: const Icon(Icons.remove,
                                        size: 20,
                                        color: Colors.black54),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // ── Tambah Kategori ───────────────────────────────────────────────
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _promptAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Tambah Kategori',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _kPink : Colors.transparent,
          border: Border.all(
              color: selected ? _kPink : const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

// ─── Category Card ────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _kPinkLight,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.name,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              '${category.itemCount} Jenis',
              style: const TextStyle(
                  fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pengeluaran Form Sheet ───────────────────────────────────────────────────

class _PengeluaranFormSheet extends StatefulWidget {
  final int userId;
  final CategoryModel category;
  const _PengeluaranFormSheet(
      {required this.userId,
      required this.category});

  @override
  State<_PengeluaranFormSheet> createState() =>
      _PengeluaranFormSheetState();
}

class _PengeluaranFormSheetState extends State<_PengeluaranFormSheet> {
  final _jumlahController = TextEditingController();
  final _catatanController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final jumlah = double.tryParse(_jumlahController.text.replaceAll('.', '').trim());
    if (jumlah == null || jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan jumlah pengeluaran.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final dashboard = await FinanceApi().fetchDashboard(widget.userId);
      if (jumlah > dashboard.saldo) {
        if (mounted) {
          Navigator.pop(context, false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saldo tidak mencukupi')),
          );
        }
        return;
      }
      final now = DateTime.now();
      await FinanceApi().addPengeluaran(
        widget.userId,
        widget.category.id,
        jumlah,
        _catatanController.text.trim(),
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
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
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            widget.category.name,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.category.itemCount} jenis tersedia',
            style: const TextStyle(fontSize: 13, color: Colors.black45),
          ),

          const SizedBox(height: 20),

          // ── Jumlah ────────────────────────────────────────────────────
          _FieldLabel('Jumlah Pengeluaran'),
          const SizedBox(height: 10),
          _RoundedContainer(
            child: Row(
              children: [
                const Text(
                  'Rp',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
                Container(
                  width: 1,
                  height: 22,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12),
                  color: const Color(0xFFCCCCCC),
                ),
                Expanded(
                  child: TextField(
                    controller: _jumlahController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    inputFormatters: [_ThousandSeparatorFormatter()],
                    decoration: const InputDecoration(
                      hintText: 'Ketik Jumlah Pengeluaran',
                      hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFAAAAAA)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Catatan ───────────────────────────────────────────────────
          _FieldLabel('Catatan'),
          const SizedBox(height: 10),
          _RoundedContainer(
            child: TextField(
              controller: _catatanController,
              decoration: const InputDecoration(
                hintText: 'Ketik Catatan',
                hintStyle: TextStyle(
                    fontSize: 14, color: Color(0xFFAAAAAA)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Simpan — pink for consistency ─────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPink,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Simpan',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Kategori Dialog ──────────────────────────────────────────────────────

class _AddKategoriDialog extends StatefulWidget {
  final Future<void> Function(String nama) onAdd;
  const _AddKategoriDialog({required this.onAdd});

  @override
  State<_AddKategoriDialog> createState() => _AddKategoriDialogState();
}

class _AddKategoriDialogState extends State<_AddKategoriDialog> {
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Kategori',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Nama kategori',
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kPink, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          final nama = _controller.text.trim();
                          if (nama.isEmpty) return;
                          setState(() => _saving = true);
                          final nav = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await widget.onAdd(nama);
                            if (!mounted) return;
                            nav.pop();
                          } catch (e) {
                            if (!mounted) return;
                            setState(() => _saving = false);
                            messenger.showSnackBar(
                              SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _saving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black87),
    );
  }
}

class _RoundedContainer extends StatelessWidget {
  final Widget child;
  const _RoundedContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool saving;
  final VoidCallback onPressed;
  const _SaveButton({required this.saving, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: saving ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPink,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Simpan',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}
