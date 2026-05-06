import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/data/inventory_api.dart';
import 'package:ruangpeduliapp/services/inventory_notification_service.dart';
import 'inventory_panti_produkbaru.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const Color kPink = Color(0xFFF28C9F);
const Color kPinkDark = Color(0xFFE5728A);
const Color kPinkLight = Color(0xFFFAE8EC);
const Color kRed = Color(0xFFE53935);
const Color kGreen = Color(0xFF2DB34A);

const List<double> _greyscaleMatrix = [
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
];

// ═══════════════════════════════════════════════════════════════════════════════
// STOK MASUK MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class StokMasukScreen extends StatelessWidget {
  final int? userId;
  final int? pantiId;

  const StokMasukScreen({super.key, this.userId, this.pantiId});

  @override
  Widget build(BuildContext context) => StokDetailScreen(
        title: 'Stok Masuk',
        userId: userId,
        pantiId: pantiId,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED STOK DETAIL SCREEN (used by both Stok Masuk and Stok Keluar)
// ═══════════════════════════════════════════════════════════════════════════════

class StokDetailScreen extends StatefulWidget {
  final String title;
  final int? userId;
  final int? pantiId;
  final bool isKeluar;

  const StokDetailScreen({
    super.key,
    required this.title,
    this.userId,
    this.pantiId,
    this.isKeluar = false,
  });

  @override
  State<StokDetailScreen> createState() => _StokDetailScreenState();
}

class _StokDetailScreenState extends State<StokDetailScreen> {
  bool _isEditMode = false;
  List<CategoryModel> _categories = [];
  bool _loading = true;
  String? _error;
  final _searchController = TextEditingController();
  Timer? _refreshTimer;

  List<CategoryModel> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _categories;
    return _categories
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _fetchCategoriesSilent();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategoriesSilent() async {
    if (widget.pantiId == null) return;
    try {
      final cats = await InventoryApi().fetchCategories(widget.pantiId!);
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  Future<void> _fetchCategories() async {
    if (widget.pantiId == null) {
      if (mounted)
        setState(() {
          _loading = false;
        });
      return;
    }
    if (mounted)
      setState(() {
        _loading = true;
        _error = null;
      });
    try {
      final cats = await InventoryApi().fetchCategories(widget.pantiId!);
      if (mounted)
        setState(() {
          _categories = cats;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  void _toggleEditMode() => setState(() => _isEditMode = !_isEditMode);

  void _confirmDelete(int categoryId) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => _ConfirmDeleteDialog(
        message: 'Apakah Anda yakin ingin menghapus kategori tersebut?',
        onHapus: () async {
          Navigator.pop(context);
          if (widget.userId == null) return;
          try {
            await InventoryApi().deleteCategory(widget.userId!, categoryId);
            _fetchCategories();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          }
        },
        onBatal: () => Navigator.pop(context),
      ),
    );
  }

  void _showTambahKategoriDialog() {
    showDialog(
      context: context,
      builder: (_) => _TambahKategoriDialog(
        onAdd: (nama) async {
          if (widget.userId == null) return;
          try {
            await InventoryApi().addCategory(widget.userId!, nama);
            _fetchCategories();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          }
        },
      ),
    );
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
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _buildSearchBar(_searchController, () => setState(() {})),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                text: 'Kategori: ',
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                children: [
                  TextSpan(
                    text: _loading ? '...' : '${_filtered.length}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(kPink),
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada kategori.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final cat = _filtered[index];
                              if (_isEditMode) {
                                return ColorFiltered(
                                  colorFilter: const ColorFilter.matrix(
                                      _greyscaleMatrix),
                                  child: _KategoriTile(
                                    nama: cat.name,
                                    jumlahJenis: cat.itemCount,
                                    hasAlert: cat.hasAlert,
                                    isEditMode: true,
                                    onDelete: () => _confirmDelete(cat.id),
                                    onTap: null,
                                  ),
                                );
                              }
                              return _KategoriTile(
                                nama: cat.name,
                                jumlahJenis: cat.itemCount,
                                hasAlert: cat.hasAlert,
                                isEditMode: false,
                                onDelete: () => _confirmDelete(cat.id),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StokDetailKategoriScreen(
                                      categoryId: cat.id,
                                      categoryName: cat.name,
                                      hasAlert: cat.hasAlert,
                                      userId: widget.userId,
                                      pantiId: widget.pantiId,
                                      isKeluar: widget.isKeluar,
                                    ),
                                  ),
                                ).then((_) => _fetchCategories()),
                              );
                            },
                          ),
          ),
          if (!_isEditMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _showTambahKategoriDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Tambahkan Kategori',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleEditMode,
        backgroundColor: Colors.white,
        elevation: _isEditMode ? 2 : 4,
        shape: const CircleBorder(),
        child: Icon(
          Icons.edit_outlined,
          color: _isEditMode ? kPinkDark : kPink,
          size: 22,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DETAIL KATEGORI SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class StokDetailKategoriScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final bool hasAlert;
  final int? userId;
  final int? pantiId;
  final bool isKeluar;

  const StokDetailKategoriScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.hasAlert,
    this.userId,
    this.pantiId,
    this.isKeluar = false,
  });

  @override
  State<StokDetailKategoriScreen> createState() =>
      _StokDetailKategoriScreenState();
}

class _StokDetailKategoriScreenState extends State<StokDetailKategoriScreen> {
  List<InventoryItemModel> _items = [];
  bool _loading = true;
  String? _error;
  bool _isEditMode = false;
  final _searchController = TextEditingController();
  Timer? _refreshTimer;

  List<InventoryItemModel> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _items;
    return _items.where((i) => i.name.toLowerCase().contains(query)).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _fetchItemsSilent();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchItemsSilent() async {
    try {
      final items = await InventoryApi().fetchItems(widget.categoryId);
      if (mounted) setState(() => _items = items);
      // Also re-check notifications silently
      if (widget.pantiId != null) {
        InventoryNotificationService.checkAndNotify(widget.pantiId!);
      }
    } catch (_) {}
  }

  Future<void> _fetchItems() async {
    if (mounted)
      setState(() {
        _loading = true;
        _error = null;
      });
    try {
      final items = await InventoryApi().fetchItems(widget.categoryId);
      if (mounted)
        setState(() {
          _items = items;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  void _confirmDeleteItem(int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => _ConfirmDeleteDialog(
        message: 'Apakah Anda yakin ingin menghapus produk ini?',
        onHapus: () async {
          Navigator.pop(context);
          if (widget.userId == null) return;
          try {
            await InventoryApi().deleteItem(widget.userId!, _items[index].id);
            _fetchItems();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          }
        },
        onBatal: () => Navigator.pop(context),
      ),
    );
  }

  void _showEditItemDialog(InventoryItemModel item) {
    showDialog(
      context: context,
      builder: (_) => _EditItemDialog(
        item: item,
        onSave: (qty, description, dailyUsage, leadTimeDays) async {
          if (widget.userId == null) return;
          try {
            await InventoryApi().updateItem(
              widget.userId!,
              item.id,
              quantity: qty,
              description: description.isEmpty ? null : description,
              dailyUsage: dailyUsage,
              leadTimeDays: leadTimeDays,
            );
            _fetchItems();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          }
        },
      ),
    );
  }

  void _showStokMasukSheet(InventoryItemModel item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (_) => _StokInputSheet(
        item: item,
        isKeluar: widget.isKeluar,
        onSave: (qty) async {
          if (widget.userId == null) return;
          try {
            final newQty = widget.isKeluar
                ? (item.quantity - qty).clamp(0, item.quantity)
                : item.quantity + qty;
            await InventoryApi()
                .updateItem(widget.userId!, item.id, quantity: newQty);
            await InventoryApi()
                .addLaporan(widget.userId!, item.id, qty, !widget.isKeluar);
            if (mounted) _fetchItems();
            // Check low stock after every stock change and notify if needed
            if (widget.pantiId != null) {
              InventoryNotificationService.checkAndNotify(widget.pantiId!);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(e.toString())));
            }
          }
        },
      ),
    );
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
          children: [
            Text(
              widget.categoryName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            if (widget.hasAlert) ...[
              const SizedBox(width: 6),
              const Icon(Icons.error_rounded, color: kRed, size: 20),
            ],
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
            icon: Icon(
              Icons.edit_outlined,
              color: _isEditMode ? kPinkDark : kPink,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _buildSearchBar(_searchController, () => setState(() {})),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                text: 'Jenis: ',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888888)),
                children: [
                  TextSpan(
                    text: _loading ? '...' : '${_filtered.length}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Color(0xFF888888)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(kPink),
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada produk.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 220,
                            ),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final item = _filtered[index];
                              return _ItemGridCard(
                                item: item,
                                isEditMode: _isEditMode,
                                onDelete: () =>
                                    _confirmDeleteItem(_items.indexOf(item)),
                                onEdit: () => _showEditItemDialog(item),
                                onTap: () => _showStokMasukSheet(item),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (widget.pantiId == null || widget.userId == null) return;
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => TambahProdukScreen(
                pantiId: widget.pantiId!,
                userId: widget.userId!,
              ),
            ),
          );
          if (added == true) _fetchItems();
        },
        backgroundColor: kPink,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 22),
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

Widget _buildSearchBar(
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

// ─── Kategori Tile ────────────────────────────────────────────────────────────

/// Public wrapper for the category tile UI.
///
/// This exists so other files (including widget tests) can render the tile
/// without depending on the library-private implementation.
class CategoryTile extends StatelessWidget {
  final String nama;
  final int jumlah;
  final bool hasAlert;
  final bool isEditMode;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CategoryTile({
    super.key,
    required this.nama,
    required this.jumlah,
    this.hasAlert = false,
    this.isEditMode = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _KategoriTile(
      nama: nama,
      jumlahJenis: jumlah,
      hasAlert: hasAlert,
      isEditMode: isEditMode,
      onTap: onTap,
      onDelete: onDelete ?? () {},
    );
  }
}

class _KategoriTile extends StatelessWidget {
  final String nama;
  final int jumlahJenis;
  final bool hasAlert;
  final bool isEditMode;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  const _KategoriTile({
    required this.nama,
    required this.jumlahJenis,
    required this.hasAlert,
    required this.isEditMode,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isEditMode ? const Color(0xFFF5F5F5) : kPinkLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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
                        nama,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      if (hasAlert) ...[
                        const SizedBox(width: 6),
                        Icon(
                          isEditMode ? Icons.info_rounded : Icons.error_rounded,
                          color: isEditMode ? Colors.grey[500] : kRed,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$jumlahJenis Jenis',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isEditMode)
              GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, color: Colors.grey[600], size: 22),
                ),
              )
            else
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Item Grid Card ───────────────────────────────────────────────────────────

class _ItemGridCard extends StatelessWidget {
  final InventoryItemModel item;
  final bool isEditMode;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const _ItemGridCard({
    required this.item,
    required this.isEditMode,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditMode ? null : onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: isEditMode ? const Color(0xFFF5F5F5) : kPinkLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                // Quantity + unit
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        item.unit,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Name
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Description
                if (item.description != null &&
                    item.description!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.description!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            // Edit/delete + out-of-stock badge
            if (isEditMode)
              Positioned(
                top: 0,
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onEdit,
                      behavior: HitTestBehavior.opaque,
                      child: Icon(Icons.edit_outlined,
                          color: Colors.grey[500], size: 18),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onDelete,
                      behavior: HitTestBehavior.opaque,
                      child:
                          Icon(Icons.close, color: Colors.grey[500], size: 18),
                    ),
                  ],
                ),
              )
            else if (item.isOutOfStock)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.error_rounded, color: kRed, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Confirm Delete Dialog ────────────────────────────────────────────────────

// ─── Stok Input Bottom Sheet ──────────────────────────────────────────────────

class _StokInputSheet extends StatefulWidget {
  final InventoryItemModel item;
  final bool isKeluar;
  final Future<void> Function(int qty) onSave;

  const _StokInputSheet(
      {required this.item, required this.isKeluar, required this.onSave});

  @override
  State<_StokInputSheet> createState() => _StokInputSheetState();
}

class _StokInputSheetState extends State<_StokInputSheet> {
  int _qty = 0;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 22),

          // Product name
          Text(
            item.name,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A)),
            textAlign: TextAlign.center,
          ),

          // Info lines (read-only)
          if (item.dailyUsage != null) ...[
            const SizedBox(height: 6),
            Text(
              'Pemakaian Harian Rata-Rata: ${item.dailyUsage} ${item.unit}/hari',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
          if (item.leadTimeDays > 1) ...[
            const SizedBox(height: 2),
            Text(
              'Waktu Tunggu: ${item.leadTimeDays} hari',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              item.description!,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 32),

          // Stepper
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (_qty > 0) setState(() => _qty--);
                },
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                      color: Colors.grey[400], shape: BoxShape.circle),
                  child:
                      const Icon(Icons.remove, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 18),
              Container(
                width: 100,
                height: 90,
                decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.center,
                child: Text('$_qty',
                    style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A))),
              ),
              const SizedBox(width: 18),
              GestureDetector(
                onTap: () {
                  final max = widget.isKeluar ? item.quantity : null;
                  if (max == null || _qty < max) setState(() => _qty++);
                },
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                      color: Colors.grey[400], shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(item.unit,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400])),
          const SizedBox(height: 28),

          // Save button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _saving
                  ? null
                  : () async {
                      if (_qty == 0) return;
                      setState(() => _saving = true);
                      final nav = Navigator.of(context);
                      await widget.onSave(_qty);
                      if (!mounted) return;
                      nav.pop();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPink,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Confirm Delete Dialog ────────────────────────────────────────────────────

class _ConfirmDeleteDialog extends StatelessWidget {
  final String message;
  final VoidCallback onHapus;
  final VoidCallback onBatal;

  const _ConfirmDeleteDialog({
    required this.message,
    required this.onHapus,
    required this.onBatal,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onBatal,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A1A1A),
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Tidak'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: onHapus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Ya',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tambah Kategori Dialog ───────────────────────────────────────────────────

class _TambahKategoriDialog extends StatefulWidget {
  final Function(String) onAdd;
  const _TambahKategoriDialog({required this.onAdd});

  @override
  State<_TambahKategoriDialog> createState() => _TambahKategoriDialogState();
}

class _TambahKategoriDialogState extends State<_TambahKategoriDialog> {
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
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ketik Nama Kategori',
                hintStyle:
                    const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
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
                        if (_controller.text.trim().isEmpty) return;
                        setState(() => _saving = true);
                        final nav = Navigator.of(context);
                        await widget.onAdd(_controller.text.trim());
                        if (!mounted) return;
                        nav.pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Tambahkan',
                        style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tambah Item Dialog ───────────────────────────────────────────────────────

class _TambahItemDialog extends StatefulWidget {
  final Future<void> Function(
      String name, int qty, String unit, String description) onAdd;
  const _TambahItemDialog({required this.onAdd});

  @override
  State<_TambahItemDialog> createState() => _TambahItemDialogState();
}

class _TambahItemDialogState extends State<_TambahItemDialog> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _unitController = TextEditingController();
  final _descController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _unitController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Widget _inputField(
    TextEditingController ctrl,
    String hint, {
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: inputType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: kPink, width: 1.5),
        ),
      ),
    );
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
              'Tambah Produk',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 10),
            _inputField(_nameController, 'Nama Produk'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _inputField(
                    _qtyController,
                    'Jumlah',
                    inputType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _inputField(_unitController, 'Satuan (pcs, kg...)'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _inputField(_descController, 'Deskripsi (opsional)'),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _saving
                    ? null
                    : () async {
                        final name = _nameController.text.trim();
                        final qty =
                            int.tryParse(_qtyController.text.trim()) ?? 0;
                        final unit = _unitController.text.trim();
                        final desc = _descController.text.trim();
                        if (name.isEmpty) return;
                        setState(() => _saving = true);
                        final nav = Navigator.of(context);
                        await widget.onAdd(
                            name, qty, unit.isEmpty ? 'pcs' : unit, desc);
                        if (!mounted) return;
                        nav.pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Tambahkan',
                        style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Edit Item Dialog ─────────────────────────────────────────────────────────

class _EditItemDialog extends StatefulWidget {
  final InventoryItemModel item;
  final Future<void> Function(
          int qty, String description, double? dailyUsage, int? leadTimeDays)
      onSave;

  const _EditItemDialog({required this.item, required this.onSave});

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  late final TextEditingController _qtyController;
  late final TextEditingController _descController;
  late final TextEditingController _phrrController;
  late final TextEditingController _leadTimeController;

  static const _satuanWaktuOptions = ['Hari', 'Minggu', 'Bulan'];
  static const _satuanToDays = {'Hari': 1, 'Minggu': 7, 'Bulan': 30};

  String? _selectedSatuanWaktu;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _qtyController =
        TextEditingController(text: widget.item.quantity.toString());
    _descController =
        TextEditingController(text: widget.item.description ?? '');
    _phrrController = TextEditingController(
      text: widget.item.dailyUsage != null
          ? _formatUsage(widget.item.dailyUsage!)
          : '',
    );
    // Pre-fill lead time as days; default satuan = Hari
    final lt = widget.item.leadTimeDays;
    _leadTimeController =
        TextEditingController(text: lt > 1 ? lt.toString() : '');
    _selectedSatuanWaktu = 'Hari';
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _descController.dispose();
    _phrrController.dispose();
    _leadTimeController.dispose();
    super.dispose();
  }

  String _formatUsage(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  Widget _inputField(TextEditingController ctrl, String hint,
      {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: inputType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: kPink, width: 1.5),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555))),
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit: ${widget.item.name}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 4),
            Text('Satuan: ${widget.item.unit}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 12),

            // Jumlah
            _label('Jumlah'),
            _inputField(_qtyController, 'Jumlah',
                inputType: TextInputType.number),
            const SizedBox(height: 10),

            // PHRR
            _label('Pemakaian Harian Rata-Rata (PHRR)'),
            _inputField(
                _phrrController, '${widget.item.unit} per hari (opsional)',
                inputType: TextInputType.number),
            const SizedBox(height: 10),

            // Waktu Tunggu
            _label('Waktu Tunggu Produk'),
            Row(
              children: [
                Expanded(
                  child: _inputField(_leadTimeController, 'Angka (opsional)',
                      inputType: TextInputType.number),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedSatuanWaktu,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 18),
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF1A1A1A)),
                        items: _satuanWaktuOptions
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedSatuanWaktu = v),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Deskripsi
            _label('Deskripsi (opsional)'),
            _inputField(_descController, 'Deskripsi'),
            const SizedBox(height: 14),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _saving
                    ? null
                    : () async {
                        final qty = int.tryParse(_qtyController.text.trim());
                        if (qty == null) return;
                        final phrr =
                            double.tryParse(_phrrController.text.trim());
                        final ltVal =
                            int.tryParse(_leadTimeController.text.trim());
                        final leadTimeDays =
                            ltVal != null && _selectedSatuanWaktu != null
                                ? ltVal *
                                    (_satuanToDays[_selectedSatuanWaktu!] ?? 1)
                                : null;
                        setState(() => _saving = true);
                        final nav = Navigator.of(context);
                        await widget.onSave(qty, _descController.text.trim(),
                            phrr, leadTimeDays);
                        if (!mounted) return;
                        nav.pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan',
                        style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
