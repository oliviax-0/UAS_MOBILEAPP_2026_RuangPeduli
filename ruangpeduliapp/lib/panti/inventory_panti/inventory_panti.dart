import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/data/finance_api.dart';
import 'package:ruangpeduliapp/data/residents_api.dart';
import 'package:ruangpeduliapp/services/inventory_notification_service.dart';
import 'inventory_panti_anggota.dart';
import 'inventory_panti_stokmasuk.dart';
import 'inventory_panti_stokkeluar.dart';
import 'inventory_panti_notifikasi.dart';
import 'inventory_panti_stok_plusicon.dart' show showStokOpsiDialog;

// ─── Constants ───────────────────────────────────────────────────────────────

const Color kPink = Color(0xFFF28C9F);
const Color kPinkLight = Color(0xFFFDE8EC);
const Color kSalmon = Color(0xFFF2C4BC);
const Color kGreen = Color(0xFF2DB34A);
const Color kRed = Color(0xFFE53935);

// ─── Shared Widgets ──────────────────────────────────────────────────────────

class HeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback onNotifTap;
  final int notifCount;

  const HeaderWidget({
    super.key,
    required this.title,
    required this.onNotifTap,
    this.notifCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
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
              child: Icon(Icons.inventory_2_rounded, color: kPink, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
          ),
          GestureDetector(
            onTap: onNotifTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.notifications_rounded,
                      color: Color(0xFF1A1A1A), size: 20),
                ),
                if (notifCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: const BoxDecoration(
                          color: kRed, shape: BoxShape.circle),
                      child: Text(
                        notifCount > 99 ? '99+' : '$notifCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Main Page ───────────────────────────────────────────────────────────────

class InventarisPanti extends StatefulWidget {
  final int? userId;
  final int? pantiId;
  const InventarisPanti({super.key, this.userId, this.pantiId});

  @override
  State<InventarisPanti> createState() => _InventarisPantiState();
}

class _InventarisPantiState extends State<InventarisPanti> {
  int? _pegawaiCount;
  int? _penghuniCount;
  int _lowStockCount = 0;
  Timer? _countsTimer;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
    _checkLowStock();
    _checkFinance();
    _countsTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _fetchCounts();
    });
  }

  @override
  void dispose() {
    _countsTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchCounts() async {
    if (widget.userId == null) return;
    try {
      final results = await Future.wait([
        ResidentsApi().fetchPekerja(widget.userId!),
        ResidentsApi().fetchPenghuni(widget.userId!),
      ]);
      if (mounted) {
        setState(() {
          _pegawaiCount = results[0].length;
          _penghuniCount = results[1].length;
        });
      }
    } catch (_) {}
  }

  Future<void> _checkLowStock() async {
    if (widget.pantiId == null) return;
    try {
      final items =
          await InventoryNotificationService.checkAndNotify(widget.pantiId!);
      if (mounted) setState(() => _lowStockCount = items.length);
    } catch (_) {}
  }

  Future<void> _checkFinance() async {
    if (widget.userId == null) return;
    try {
      final dashboard = await FinanceApi().fetchDashboard(widget.userId!);
      InventoryNotificationService.checkFinanceAndNotify(dashboard.saldo);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildStokSection(),
          const SizedBox(height: 16),
          _buildAnggotaSection(),
        ],
      ),
    );
  }
  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return HeaderWidget(
      title: 'Inventaris',
      notifCount: _lowStockCount,
      onNotifTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  InventarisNotifikasiScreen(pantiId: widget.pantiId)),
        );
        _checkLowStock();
      },
    );
  }

  // ─── Stok Section ────────────────────────────────────────────────────────

  Widget _buildStokSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: kPinkLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SquareCard(
                  label: 'Stok Masuk',
                  icon: _BoxArrowIcon(arrowColor: kGreen, arrowUp: true),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => StokMasukScreen(
                            userId: widget.userId, pantiId: widget.pantiId)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SquareCard(
                  label: 'Stok Keluar',
                  icon: _BoxArrowIcon(arrowColor: kRed, arrowUp: false),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => StokKeluarScreen(
                            userId: widget.userId, pantiId: widget.pantiId)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => showStokOpsiDialog(context,
                  pantiId: widget.pantiId, userId: widget.userId),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Anggota Section ─────────────────────────────────────────────────────

  Widget _buildAnggotaSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: kPinkLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Anggota',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 14),

          // Summary row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: kSalmon,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Pegawai count
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Pegawai ',
                          style:
                              TextStyle(fontSize: 14, color: Color(0xFF5A2828)),
                        ),
                        Text(
                          _pegawaiCount?.toString() ?? '—',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    width: 1.5,
                    color: const Color(0xFFD49090),
                  ),
                  // Penghuni count
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Penghuni ',
                          style:
                              TextStyle(fontSize: 14, color: Color(0xFF5A2828)),
                        ),
                        Text(
                          _penghuniCount?.toString() ?? '—',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Grid cards
          Row(
            children: [
              Expanded(
                child: _SquareCard(
                  label: 'Pegawai',
                  icon: const Icon(Icons.work_rounded,
                      size: 42, color: Color(0xFF1A1A1A)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            DaftarPegawaiScreen(userId: widget.userId)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SquareCard(
                  label: 'Penghuni',
                  icon: const Icon(Icons.groups_rounded,
                      size: 42, color: Color(0xFF1A1A1A)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            DaftarPenghuniScreen(userId: widget.userId)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Square Card ─────────────────────────────────────────────────────────────

class _SquareCard extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const _SquareCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Box + Arrow Icon (custom painted) ───────────────────────────────────────

class _BoxArrowIcon extends StatelessWidget {
  final Color arrowColor;
  final bool arrowUp;

  const _BoxArrowIcon({required this.arrowColor, required this.arrowUp});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Box icon
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: const Color(0xFF1A1A1A),
          ),
          // Arrow overlay (top center of the box)
          Positioned(
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                arrowUp
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 20,
                color: arrowColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
