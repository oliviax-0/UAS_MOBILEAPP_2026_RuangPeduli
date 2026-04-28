import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/data/donation_api.dart';
import 'package:ruangpeduliapp/masyarakat/search/search_screen.dart';
import 'package:ruangpeduliapp/masyarakat/profile/profile_screen.dart';

// ─────────────────────────────────────────────────────────────
//  RIWAYAT DONASI SCREEN
// ─────────────────────────────────────────────────────────────
class RiwayatDonasiScreen extends StatefulWidget {
  final int? userId;
  const RiwayatDonasiScreen({super.key, this.userId});

  @override
  State<RiwayatDonasiScreen> createState() => _RiwayatDonasiScreenState();
}

class _RiwayatDonasiScreenState extends State<RiwayatDonasiScreen> {
  // ── Color palette dari Figma ──
  static const Color bgPink = Color(0xFFF1BFB4);
  static const Color primaryPink = Color(0xFFF28695);
  static const Color navPink = Color(0xFFF47B8C);
  static const Color darkText = Color(0xFF1A1A1A);

  // ── Filter state ──
  DateTime? _filterDate;

  // ── Data state ──
  List<DonasiModel> _allRiwayat = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.userId == null) {
      setState(() { _isLoading = false; });
      return;
    }
    try {
      final data = await DonationApi().fetchDonations(widget.userId!);
      if (mounted) setState(() { _allRiwayat = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = '$e'; _isLoading = false; });
    }
  }

  List<DonasiModel> get _filtered {
    if (_filterDate == null) return _allRiwayat;
    return _allRiwayat.where((r) {
      final d = r.tanggalDateTime;
      return d.year == _filterDate!.year &&
          d.month == _filterDate!.month &&
          d.day == _filterDate!.day;
    }).toList();
  }

  // ── Buka bottom sheet Filter ──
  void _showFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FilterSheet(
        initialDate: _filterDate,
        onSimpan: (date) {
          setState(() => _filterDate = date);
          Navigator.pop(context);
        },
      ),
    );
  }

  String _filterLabel() {
    if (_filterDate == null) return '';
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${_filterDate!.day} ${bulan[_filterDate!.month]} ${_filterDate!.year}';
  }

  void _onNavTap(int index) {
    if (index == 2) return; // already here
    if (index == 0) {
      Navigator.of(context).pop();
    } else if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SearchScreen(userId: widget.userId)),
      );
    } else if (index == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ProfileScreen(userId: widget.userId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Header pink ──
          Container(
            width: double.infinity,
            color: bgPink,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: const Text(
                  'Riwayat Donasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
              ),
            ),
          ),

          // ── Body ──
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // ── Filter row ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_filterDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _filterDate = null),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryPink.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _filterLabel(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: darkText,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.close_rounded,
                                      size: 14, color: darkText),
                                ],
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: _showFilter,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFFDDDDDD)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('Filter',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: darkText)),
                                SizedBox(width: 6),
                                Icon(Icons.filter_list_rounded,
                                    size: 18, color: darkText),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── List ──
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFF47B8C)),
                          )
                        : _error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline_rounded,
                                        size: 48, color: Colors.grey.shade300),
                                    const SizedBox(height: 12),
                                    Text('Gagal memuat data',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade400)),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isLoading = true;
                                          _error = null;
                                        });
                                        _loadData();
                                      },
                                      child: const Text('Coba lagi',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: primaryPink,
                                            decoration:
                                                TextDecoration.underline,
                                          )),
                                    ),
                                  ],
                                ),
                              )
                            : items.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.history_rounded,
                                            size: 60,
                                            color: Colors.grey.shade300),
                                        const SizedBox(height: 12),
                                        Text(
                                          _filterDate != null
                                              ? 'Tidak ada riwayat pada tanggal ini'
                                              : 'Belum ada riwayat donasi',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade400),
                                        ),
                                        if (_filterDate != null) ...[
                                          const SizedBox(height: 8),
                                          GestureDetector(
                                            onTap: () => setState(
                                                () => _filterDate = null),
                                            child: const Text(
                                              'Lihat semua riwayat',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: primaryPink,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    itemCount: items.length,
                                    itemBuilder: (context, i) =>
                                        _RiwayatCard(donasi: items[i]),
                                  ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: navPink,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_rounded,
                  selected: false,
                  onTap: () => _onNavTap(0)),
              _NavItem(
                  icon: Icons.search_rounded,
                  selected: false,
                  onTap: () => _onNavTap(1)),
              _NavItem(
                  icon: Icons.history_rounded,
                  selected: true,
                  onTap: () => _onNavTap(2)),
              _NavItem(
                  icon: Icons.person_rounded,
                  selected: false,
                  onTap: () => _onNavTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  RIWAYAT CARD
// ─────────────────────────────────────────────────────────────
class _RiwayatCard extends StatelessWidget {
  final DonasiModel donasi;
  const _RiwayatCard({required this.donasi});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1BFB4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Foto panti bulat
          ClipOval(
            child: donasi.pantiImage != null && donasi.pantiImage!.isNotEmpty
                ? Image.network(
                    donasi.pantiImage!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donasi.namaPanti,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  donasi.tanggalLabel,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF5A5A5A)),
                ),
                const SizedBox(height: 6),
                // Badge metode
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF28695),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    donasi.metodePembayaran,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Nominal
          Text(
            donasi.formattedJumlah,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 64,
      height: 64,
      color: const Color(0xFFDDCDD0),
      child: Icon(Icons.home_work_rounded, size: 28, color: Colors.grey.shade400),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FILTER BOTTOM SHEET
// ─────────────────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final DateTime? initialDate;
  final void Function(DateTime?) onSimpan;

  const _FilterSheet({required this.initialDate, required this.onSimpan});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  String _formatTanggal(DateTime d) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${d.day} ${bulan[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Pilih Tanggal',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 4),
            Text(
              'Filter riwayat donasi berdasarkan tanggal',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),

            // Selected label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8EA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined,
                      size: 18, color: Color(0xFFF28695)),
                  const SizedBox(width: 8),
                  Text(
                    _formatTanggal(_selectedDate),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Calendar always shown
            _InlineCalendar(
              selectedDate: _selectedDate,
              onDateSelected: (d) => setState(() => _selectedDate = d),
            ),
            const SizedBox(height: 20),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF28695),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                onPressed: () => widget.onSimpan(_selectedDate),
                child: const Text('Terapkan Filter',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  INLINE CALENDAR WIDGET
// ─────────────────────────────────────────────────────────────
class _InlineCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;

  const _InlineCalendar({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<_InlineCalendar> createState() => _InlineCalendarState();
}

class _InlineCalendarState extends State<_InlineCalendar> {
  late int _viewMonth;
  late int _viewYear;
  late int _selectedDay;

  final List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  bool _showMonthPicker = false;
  bool _showYearPicker = false;

  @override
  void initState() {
    super.initState();
    _viewMonth = widget.selectedDate.month;
    _viewYear = widget.selectedDate.year;
    _selectedDay = widget.selectedDate.day;
  }

  int get _daysInMonth => DateTime(_viewYear, _viewMonth + 1, 0).day;
  int get _firstWeekday => DateTime(_viewYear, _viewMonth, 1).weekday % 7; // 0=Sun

  void _prevMonth() {
    setState(() {
      if (_viewMonth == 1) {
        _viewMonth = 12;
        _viewYear--;
      } else {
        _viewMonth--;
      }
      _selectedDay = 1;
    });
  }

  void _nextMonth() {
    setState(() {
      if (_viewMonth == 12) {
        _viewMonth = 1;
        _viewYear++;
      } else {
        _viewMonth++;
      }
      _selectedDay = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Header row ──
          Row(
            children: [
              GestureDetector(
                onTap: _prevMonth,
                child: const Icon(Icons.chevron_left_rounded,
                    size: 26, color: Color(0xFF1A1A1A)),
              ),
              const Spacer(),

              // Month dropdown
              GestureDetector(
                onTap: () => setState(() {
                  _showMonthPicker = !_showMonthPicker;
                  _showYearPicker = false;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _monthNames[_viewMonth - 1],
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A)),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: Color(0xFF1A1A1A)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Year dropdown
              GestureDetector(
                onTap: () => setState(() {
                  _showYearPicker = !_showYearPicker;
                  _showMonthPicker = false;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_viewYear',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A)),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: Color(0xFF1A1A1A)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _nextMonth,
                child: const Icon(Icons.chevron_right_rounded,
                    size: 26, color: Color(0xFF1A1A1A)),
              ),
            ],
          ),

          // ── Month picker ──
          if (_showMonthPicker) ...[
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              childAspectRatio: 2.2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(12, (i) {
                final isSelected = (i + 1) == _viewMonth;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _viewMonth = i + 1;
                      _selectedDay = 1;
                      _showMonthPicker = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1A1A1A)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _monthNames[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],

          // ── Year picker ──
          if (_showYearPicker) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                childAspectRatio: 2.0,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                children: List.generate(12, (i) {
                  final year = DateTime.now().year - 2 + i;
                  final isSelected = year == _viewYear;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _viewYear = year;
                        _selectedDay = 1;
                        _showYearPicker = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1A1A1A)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$year',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],

          if (!_showMonthPicker && !_showYearPicker) ...[
            const SizedBox(height: 12),

            // ── Day headers ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                  .map((d) => SizedBox(
                        width: 36,
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),

            // ── Days grid ──
            _buildDaysGrid(),
          ],
        ],
      ),
    );
  }

  Widget _buildDaysGrid() {
    final totalCells = _firstWeekday + _daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (col) {
            final cellIndex = row * 7 + col;
            final day = cellIndex - _firstWeekday + 1;

            if (day < 1 || day > _daysInMonth) {
              // Hari dari bulan lain — tampil abu
              final prevOrNext = day < 1
                  ? DateTime(_viewYear, _viewMonth, 0).day + day
                  : day - _daysInMonth;
              return SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: Text(
                    '$prevOrNext',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade300),
                  ),
                ),
              );
            }

            final isSelected = day == _selectedDay;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedDay = day);
                widget.onDateSelected(DateTime(_viewYear, _viewMonth, day));
              },
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1A1A1A)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  NAV ITEM WIDGET
// ─────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem(
      {required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 28,
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.60)),
            if (selected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}