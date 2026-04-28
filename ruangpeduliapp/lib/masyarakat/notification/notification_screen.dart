import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/data/donation_api.dart';
import 'package:ruangpeduliapp/masyarakat/home/home_masyarakat_screen.dart';
import 'package:ruangpeduliapp/masyarakat/search/search_screen.dart';
import 'package:ruangpeduliapp/masyarakat/history/riwayat_donasi_screen.dart';
import 'package:ruangpeduliapp/masyarakat/profile/profile_screen.dart';

class NotificationScreen extends StatefulWidget {
  final int? userId;
  const NotificationScreen({super.key, this.userId});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<_NotifItem> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.userId == null) {
      setState(() {
        _items = [_NotifItem.welcome()];
        _loading = false;
      });
      return;
    }
    try {
      final donations = await DonationApi().fetchDonations(widget.userId!);
      final List<_NotifItem> items = [_NotifItem.welcome()];
      for (final d in donations) {
        items.add(_NotifItem(
          pesan: 'Donasi kamu ke ${d.namaPanti} sebesar ${d.formattedJumlah} berhasil! Terima kasih sudah peduli 💛',
          waktu: d.tanggalLabel,
          icon: Icons.volunteer_activism_rounded,
          iconColor: const Color(0xFFF47B8C),
        ));
      }
      if (mounted) setState(() { _items = items; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
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
                      'Notifikasi',
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

            // ── Body ──
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavBar(context),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF47B8C)),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Gagal memuat notifikasi',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() { _loading = true; _error = null; });
                _load();
              },
              child: const Text('Coba lagi',
                  style: TextStyle(color: Color(0xFFF43D5E))),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final item = _items[i];
        return _NotifCard(item: item);
      },
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF47B8C),
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
                onTap: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => HomeMasyarakatScreen(userId: widget.userId)),
                  (route) => false,
                ),
              ),
              _NavItem(
                icon: Icons.search_rounded,
                selected: false,
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) => SearchScreen(userId: widget.userId)),
                ),
              ),
              _NavItem(
                icon: Icons.history_rounded,
                selected: false,
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) => RiwayatDonasiScreen(userId: widget.userId)),
                ),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                selected: false,
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) => ProfileScreen(userId: widget.userId)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Notif Item Model ─────────────────────────────────────────────────────────

class _NotifItem {
  final String pesan;
  final String waktu;
  final IconData icon;
  final Color iconColor;

  const _NotifItem({
    required this.pesan,
    required this.waktu,
    required this.icon,
    required this.iconColor,
  });

  factory _NotifItem.welcome() => const _NotifItem(
        pesan: 'Selamat bergabung! Terima kasih sudah peduli sesama 💛',
        waktu: '',
        icon: Icons.favorite_rounded,
        iconColor: Color(0xFFF47B8C),
      );
}

// ─── Notif Card ───────────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final _NotifItem item;
  const _NotifCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 18, color: item.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.waktu.isNotEmpty) ...[
                  Text(
                    item.waktu,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  item.pesan,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                    height: 1.4,
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

// ─── Nav Item ─────────────────────────────────────────────────────────────────

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
