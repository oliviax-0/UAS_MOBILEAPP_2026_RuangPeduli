import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/auth/role_selection_screen.dart';
import 'package:ruangpeduliapp/data/donation_api.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/masyarakat/profile/edit_profil_screen.dart';
import 'package:ruangpeduliapp/masyarakat/transaksi/konfirmasi_pembayaran_screen.dart';
import 'package:ruangpeduliapp/masyarakat/home/home_masyarakat_screen.dart';
import 'package:ruangpeduliapp/masyarakat/search/search_screen.dart';
import 'package:ruangpeduliapp/masyarakat/history/riwayat_donasi_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;
  List<PantiProfileModel> _pantiList = [];
  bool _isLoading = true;
  SocietyProfileModel? _userProfile;
  int _totalDonasi = 0;

  @override
  void initState() {
    super.initState();
    _loadPanti();
    if (widget.userId != null) {
      _loadUserProfile();
      _loadTotalDonasi();
    }
  }

  Future<void> _loadUserProfile() async {
    final profile = await ProfileApi().fetchMasyarakatProfile(widget.userId!);
    if (mounted) setState(() => _userProfile = profile);
  }

  Future<void> _loadTotalDonasi() async {
    try {
      final list = await DonationApi().fetchDonations(widget.userId!);
      final total = list.fold<int>(0, (sum, d) => sum + d.jumlah);
      if (mounted) setState(() => _totalDonasi = total);
    } catch (_) {}
  }

  String get _formattedTotalDonasi {
    if (_totalDonasi == 0) return 'Rp0';
    final s = _totalDonasi.toString();
    final buffer = StringBuffer('Rp');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  Future<void> _loadPanti() async {
    try {
      final list = await ProfileApi().fetchAllPanti();
      if (mounted) setState(() { _pantiList = list; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (_) => false,
              );
            },
            child: const Text('Keluar',
                style: TextStyle(
                    color: Color(0xFFF43D5E),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeMasyarakatScreen(userId: widget.userId)),
      );
    } else if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SearchScreen(userId: widget.userId)),
      );
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RiwayatDonasiScreen(userId: widget.userId)),
      );
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Center(
                child: Text(
                  'Profil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile header ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFFF43D5E), width: 2),
                              color: Colors.grey.shade200,
                            ),
                            child: ClipOval(
                              child: _userProfile?.profilePicture != null
                                  ? Image.network(
                                      _userProfile!.profilePicture!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                          Icons.person_rounded,
                                          size: 40,
                                          color: Colors.grey.shade400),
                                    )
                                  : Icon(
                                      Icons.person_rounded,
                                      size: 40,
                                      color: Colors.grey.shade400),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Name + username + edit button
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _userProfile?.namaPengguna.isNotEmpty == true
                                            ? _userProfile!.namaPengguna
                                            : (_userProfile?.username ?? 'Pengguna'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _confirmLogout(),
                                      child: const Icon(
                                        Icons.logout_rounded,
                                        size: 20,
                                        color: Color(0xFFF43D5E),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _userProfile != null
                                      ? '@${_userProfile!.username}'
                                      : '',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () async {
                                    final updated = await Navigator.push<SocietyProfileModel>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditProfilScreen(
                                          profile: _userProfile,
                                          userId: widget.userId,
                                        ),
                                      ),
                                    );
                                    if (updated != null && mounted) {
                                      setState(() => _userProfile = updated);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF47B8C),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Edit Profil',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 16),

                    // ── Aktivitas Anda ──
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Aktivitas Anda',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Total Donasi card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // Heart icon circle
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.favorite_rounded,
                                  color: Color(0xFFF47B8C), size: 28),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Donasi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formattedTotalDonasi,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 16),

                    // ── Pilih Panti Untuk Donasi Lagi ──
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Pilih Panti Untuk Donasi Lagi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Panti list
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFFF43D5E))),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _pantiList.length,
                        itemBuilder: (context, i) {
                          final panti = _pantiList[i];
                          return _PantiDonasCard(
                            nama: panti.namaPanti,
                            terkumpul: panti.formattedTotalTerkumpul,
                            profilePicture: panti.profilePicture,
                            onDonasi: () async {
                              final result = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => KonfirmasiPembayaranScreen(
                                    namaPanti: panti.namaPanti,
                                    terkumpul: panti.formattedTotalTerkumpul,
                                    imagePath: panti.profilePicture ?? '',
                                    pantiId: panti.id,
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                              if (result == true && mounted) {
                                _loadTotalDonasi();
                                _loadPanti();
                              }
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF47B8C),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, -3)),
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
                  selected: _selectedIndex == 0,
                  onTap: () => _onNavTap(0)),
              _NavItem(
                  icon: Icons.search_rounded,
                  selected: _selectedIndex == 1,
                  onTap: () => _onNavTap(1)),
              _NavItem(
                  icon: Icons.history_rounded,
                  selected: _selectedIndex == 2,
                  onTap: () => _onNavTap(2)),
              _NavItem(
                  icon: Icons.person_rounded,
                  selected: _selectedIndex == 3,
                  onTap: () => _onNavTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Panti Donasi Card ──
class _PantiDonasCard extends StatelessWidget {
  final String nama;
  final String terkumpul;
  final String? profilePicture;
  final VoidCallback onDonasi;

  const _PantiDonasCard({
    required this.nama,
    required this.terkumpul,
    required this.profilePicture,
    required this.onDonasi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: profilePicture != null && profilePicture!.isNotEmpty
                ? Image.network(
                    profilePicture!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 4),
                Text(
                  terkumpul,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onDonasi,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF47B8C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Donasi',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
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

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      color: const Color(0xFFDDCDD0),
      child: Icon(Icons.home_work_rounded, size: 32, color: Colors.grey.shade400),
    );
  }
}

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
                    : Colors.white.withOpacity(0.60)),
            if (selected)
              Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }
}