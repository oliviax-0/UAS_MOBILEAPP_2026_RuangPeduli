import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/data/donation_api.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/masyarakat/transaksi/transaksi_sukses_screen.dart';

class KonfirmasiMetodeScreen extends StatefulWidget {
  final String namaPanti;
  final String terkumpul;
  final String imagePath;
  final String nominal;
  final int? pantiId;
  final int? userId;

  const KonfirmasiMetodeScreen({
    super.key,
    required this.namaPanti,
    required this.terkumpul,
    required this.imagePath,
    required this.nominal,
    this.pantiId,
    this.userId,
  });

  @override
  State<KonfirmasiMetodeScreen> createState() =>
      _KonfirmasiMetodeScreenState();
}

class _KonfirmasiMetodeScreenState extends State<KonfirmasiMetodeScreen> {
  String _selectedMetode = 'GoPay';
  bool _loading = false;

  final List<Map<String, dynamic>> _metodeList = [
    {'nama': 'GoPay', 'color': const Color(0xFF00AED6), 'icon': Icons.account_balance_wallet_rounded},
    {'nama': 'OVO', 'color': const Color(0xFF4C3494), 'icon': Icons.account_balance_wallet_rounded},
    {'nama': 'DANA', 'color': const Color(0xFF118EEA), 'icon': Icons.account_balance_wallet_rounded},
    {'nama': 'Transfer Bank', 'color': const Color(0xFF888888), 'icon': Icons.account_balance_rounded},
  ];

  int get _nominalInt {
    try {
      return int.parse(widget.nominal.replaceAll('.', '').replaceAll(',', ''));
    } catch (_) {
      return 0;
    }
  }

  int get _biayaAdmin => 2500;
  int get _totalPembayaran => _nominalInt + _biayaAdmin;

  String _formatRupiah(int amount) {
    final s = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return 'Rp${buffer.toString()}';
  }

  Future<void> _onKonfirmasi() async {
    if (_loading) return;
    setState(() => _loading = true);
    final noRef = 'REF${DateTime.now().millisecondsSinceEpoch % 100000}';
    String username = '';
    String? profilePicture;

    // Save donation first (must succeed before proceeding)
    try {
      if (widget.userId != null) {
        await DonationApi().createDonation(
          userId: widget.userId!,
          pantiId: widget.pantiId,
          namaPanti: widget.namaPanti,
          jumlah: _nominalInt,
          metodePembayaran: _selectedMetode,
          noReferensi: noRef,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan donasi, coba lagi')),
        );
        setState(() => _loading = false);
      }
      return;
    }

    // Fetch user profile for invoice display (best-effort, don't block)
    if (widget.userId != null) {
      try {
        final profile = await ProfileApi().fetchMasyarakatProfile(widget.userId!);
        if (profile != null) {
          username = profile.username.isNotEmpty ? profile.username : profile.namaPengguna;
          profilePicture = profile.profilePicture;
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _loading = false);
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => TransaksiSuksesScreen(
          namaPanti: widget.namaPanti,
          total: _formatRupiah(_totalPembayaran),
          jumlahDonasi: _nominalInt,
          metodePembayaran: _selectedMetode,
          noReferensi: noRef,
          pantiId: widget.pantiId,
          userId: widget.userId,
          username: username,
          profilePicture: profilePicture,
        ),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
    if (result == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App Bar ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_rounded,
                        size: 22, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Konfirmasi Pembayaran',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilihan Anda',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 10),

                    // ── Panti card ──
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _PantiImage(
                                path: widget.imagePath, width: 80, height: 70),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.namaPanti,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1A1A))),
                                const SizedBox(height: 4),
                                Text(widget.terkumpul,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Rincian biaya ──
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        children: [
                          _BiayaRow(
                              label: 'Jumlah Donasi',
                              value: 'Rp${widget.nominal}'),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          _BiayaRow(
                              label: 'Biaya Admin',
                              value: _formatRupiah(_biayaAdmin)),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          _BiayaRow(
                              label: 'Total Pembayaran',
                              value: _formatRupiah(_totalPembayaran),
                              isBold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Metode pembayaran ──
                    const Text('Metode Pembayaran',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        children: List.generate(_metodeList.length, (i) {
                          final m = _metodeList[i];
                          final isLast = i == _metodeList.length - 1;
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () => setState(
                                    () => _selectedMetode = m['nama']),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      // Radio
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _selectedMetode == m['nama']
                                                ? const Color(0xFF1A1A1A)
                                                : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                        ),
                                        child: _selectedMetode == m['nama']
                                            ? Center(
                                                child: Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFF1A1A1A),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      // Icon
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: (m['color'] as Color)
                                              .withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          m['icon'] as IconData,
                                          size: 18,
                                          color: m['color'] as Color,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(m['nama'],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF1A1A1A))),
                                    ],
                                  ),
                                ),
                              ),
                              if (!isLast)
                                const Divider(
                                    height: 1,
                                    color: Color(0xFFEEEEEE),
                                    indent: 16,
                                    endIndent: 16),
                            ],
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Konfirmasi button ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF47B8C),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        onPressed: _loading ? null : _onKonfirmasi,
                        child: _loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Konfirmasi',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PantiImage extends StatelessWidget {
  final String path;
  final double width;
  final double height;
  const _PantiImage(
      {required this.path, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final isNetwork =
        path.startsWith('http://') || path.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    if (path.isEmpty) return _placeholder();
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        color: const Color(0xFFDDCDD0),
        child: Icon(Icons.home_work_rounded,
            size: 32, color: Colors.grey.shade400),
      );
}

class _BiayaRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _BiayaRow(
      {required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isBold ? FontWeight.w700 : FontWeight.w400,
                  color: const Color(0xFF1A1A1A))),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isBold ? FontWeight.w700 : FontWeight.w400,
                  color: const Color(0xFF1A1A1A))),
        ],
      ),
    );
  }
}