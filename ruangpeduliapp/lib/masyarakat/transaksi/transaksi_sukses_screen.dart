import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/masyarakat/profile/profile_screen.dart';

class TransaksiSuksesScreen extends StatefulWidget {
  final String namaPanti;
  final String total;
  final int jumlahDonasi;
  final String metodePembayaran;
  final String noReferensi;
  final int? pantiId;
  final int? userId;
  final String username;
  final String? profilePicture;

  const TransaksiSuksesScreen({
    super.key,
    required this.namaPanti,
    required this.total,
    required this.jumlahDonasi,
    required this.metodePembayaran,
    required this.noReferensi,
    this.pantiId,
    this.userId,
    this.username = '',
    this.profilePicture,
  });

  @override
  State<TransaksiSuksesScreen> createState() =>
      _TransaksiSuksesScreenState();
}

class _TransaksiSuksesScreenState extends State<TransaksiSuksesScreen>
    with TickerProviderStateMixin {
  // Phase 1: centang animasi dari kanan ke tengah
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeInAnim;

  // Phase 2: sukses page fade in
  bool _showSukses = false;
  late String _username;
  late String? _profilePicture;

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    _profilePicture = widget.profilePicture;

    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _slideAnim = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeInAnim =
        CurvedAnimation(parent: _slideController, curve: Curves.easeIn);

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Centang slide masuk dari kanan
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _slideController.forward();

    // Tampil 2 detik lalu ganti ke sukses page
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    setState(() => _showSukses = true);
  }

  void _onSelesai() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => ProfileScreen(userId: widget.userId)),
      (route) => route.isFirst,
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSukses) {
      return _buildSuksesPage();
    }
    return _buildCheckmarkPage();
  }

  // ── Halaman centang hitam ──
  Widget _buildCheckmarkPage() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _slideController,
          builder: (_, __) {
            return SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeInAnim,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 90,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Halaman transaksi berhasil ──
  Widget _buildSuksesPage() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Checkmark hitam
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 70,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Transaksi Anda Berhasil',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              const Divider(color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),

              // ── Info user ──
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: _profilePicture != null && _profilePicture!.isNotEmpty
                          ? Image.network(
                              _profilePicture!,
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _avatarInitial(),
                            )
                          : _avatarInitial(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _username.isNotEmpty ? '@$_username' : '...',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total nominal
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Nominal',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Text(widget.total,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A))),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),

              // ── Detail transaksi ──
              _DetailRow(
                label: 'Tanggal Transaksi',
                value: _formatTanggal(),
              ),
              const SizedBox(height: 12),
              _DetailRow(
                label: 'No. Referensi',
                value: 'REF${DateTime.now().millisecondsSinceEpoch % 100000}',
              ),
              const SizedBox(height: 12),
              _DetailRow(
                label: 'Waktu Transfer',
                value:
                    '${TimeOfDay.now().hour.toString().padLeft(2, '0')}.${TimeOfDay.now().minute.toString().padLeft(2, '0')} WIB',
              ),

              const SizedBox(height: 40),

              // ── Selesai button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF47B8C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  onPressed: _onSelesai,
                  child: const Text('Selesai',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarInitial() {
    return Container(
      width: 42,
      height: 42,
      color: Colors.grey.shade300,
      child: Center(
        child: Text(
          _username.isNotEmpty ? _username[0].toUpperCase() : '?',
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A)),
        ),
      ),
    );
  }

  String _formatTanggal() {
    final now = DateTime.now();
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${now.day} ${bulan[now.month]} ${now.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(value,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF1A1A1A))),
      ],
    );
  }
}