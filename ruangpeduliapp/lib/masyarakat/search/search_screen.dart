import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/masyarakat/transaksi/lokasi_screen.dart';
import 'package:ruangpeduliapp/masyarakat/home/panti_detail_screen.dart';
import 'package:ruangpeduliapp/masyarakat/history/riwayat_donasi_screen.dart';
import 'package:ruangpeduliapp/masyarakat/profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  final int? userId;
  final String initialQuery;
  final ProfileApi? profileApi;
  final bool enableLocationFetch;
  const SearchScreen({
    super.key,
    this.userId,
    this.initialQuery = '',
    this.profileApi,
    this.enableLocationFetch = true,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final ProfileApi _profileApi;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _selectedIndex = 1;

  final _stt = SpeechToText();
  bool _sttReady = false;
  bool _listening = false;
  String? _sttLocale;

  Position? _userPosition;
  bool _loadingLocation = true;

  List<PantiProfileModel> _pantiList = [];
  bool _loadingPanti = true;
  String? _errorPanti;
  double _distanceTo(PantiProfileModel panti) {
    if (_userPosition == null || panti.lat == null || panti.lng == null) {
      return double.infinity;
    }
    return Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      panti.lat!,
      panti.lng!,
    );
  }

  String _formatDistance(double meters) {
    if (meters.isInfinite) return '';
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  List<PantiProfileModel> get _filtered {
    final q = _searchController.text.toLowerCase();
    var list = _pantiList.where((p) {
      return q.isEmpty ||
          p.namaPanti.toLowerCase().contains(q) ||
          p.alamatPanti.toLowerCase().contains(q);
    }).toList();
    list.sort((a, b) => _distanceTo(a).compareTo(_distanceTo(b)));
    return list;
  }

  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _loadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      // Show rationale dialog only when permission hasn't been asked yet
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        final agreed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const _LocationRationaleDialog(),
        );
        if (agreed != true) {
          if (mounted) setState(() => _loadingLocation = false);
          return;
        }
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _loadingLocation = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (mounted)
        setState(() {
          _userPosition = pos;
          _loadingLocation = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _fetchPanti() async {
    try {
      final list = await _profileApi.fetchAllPanti();
      if (mounted)
        setState(() {
          _pantiList = list;
          _loadingPanti = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _errorPanti = e.toString();
          _loadingPanti = false;
        });
    }
  }

  // Loading state per-panti id while fetching media
  final Set<int> _loadingPantiId = {};

  Future<void> _openPantiDetail(PantiProfileModel panti) async {
    setState(() => _loadingPantiId.add(panti.id));
    try {
      final media = await _profileApi.fetchPantiMedia(panti.id);
      if (!mounted) return;
      final mediaUrls = media
          .where((m) => m.file != null && m.file!.isNotEmpty)
          .map((m) => m.file!)
          .toList();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PantiDetailScreen(
            pantiId: panti.id,
            namaPanti: panti.namaPanti,
            username: '@${panti.username}',
            nomorPanti: panti.nomorPanti,
            alamatPanti: panti.fullAddress.isNotEmpty
                ? panti.fullAddress
                : panti.alamatPanti,
            description: panti.description,
            profilePicture: panti.profilePicture,
            terkumpul: panti.formattedTotalTerkumpul,
            userId: widget.userId,
            mediaUrls: mediaUrls,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat profil panti')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingPantiId.remove(panti.id));
    }
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) {
      Navigator.of(context).pop();
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => RiwayatDonasiScreen(userId: widget.userId)),
      );
    } else if (index == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ProfileScreen(userId: widget.userId)),
      );
    }
    setState(() => _selectedIndex = index);
  }

  Future<void> _toggleMic() async {
    if (!_sttReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mikrofon tidak tersedia. Periksa izin aplikasi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_listening) {
      await _stt.stop();
      setState(() => _listening = false);
      return;
    }
    // Dismiss keyboard so it doesn't interfere with STT
    _focusNode.unfocus();
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    setState(() => _listening = true);
    await _stt.listen(
      localeId: _sttLocale,
      onResult: (r) {
        if (!mounted) return;
        if (r.recognizedWords.isNotEmpty) {
          _searchController.value = TextEditingValue(
            text: r.recognizedWords,
            selection:
                TextSelection.collapsed(offset: r.recognizedWords.length),
          );
        }
        if (r.finalResult) {
          setState(() => _listening = false);
        }
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.search,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _profileApi = widget.profileApi ?? ProfileApi();
    if (widget.initialQuery.isNotEmpty) {
      _searchController.text = widget.initialQuery;
    }
    if (widget.enableLocationFetch) {
      _fetchLocation();
    } else {
      _loadingLocation = false;
    }
    _fetchPanti();
    // Only auto-focus keyboard when opened without a pre-filled query
    if (widget.initialQuery.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focusNode.requestFocus();
      });
    }
    _searchController.addListener(() => setState(() {}));
    _stt.initialize(
      onStatus: (s) {
        if ((s == 'done' || s == 'notListening') && mounted) {
          setState(() => _listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    ).then((ok) async {
      if (!mounted) return;
      if (ok) {
        final locales = await _stt.locales();
        final idLocale = locales.firstWhere(
          (l) => l.localeId.startsWith('id'),
          orElse: () => locales.first,
        );
        if (mounted)
          setState(() {
            _sttReady = true;
            _sttLocale = idLocale.localeId;
          });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _stt.cancel();
    super.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_rounded,
                        size: 24, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(width: 12),
                  const Text('Search',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A))),
                ],
              ),
            ),

            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: _toggleMic,
                      child: Icon(
                        _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        size: 20,
                        color: _listening
                            ? const Color(0xFFF47B8C)
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                              fontSize: 15, color: Colors.grey.shade400),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 11),
                        ),
                        style: const TextStyle(
                            fontSize: 15, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () => _searchController.clear(),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Icon(Icons.close_rounded,
                              size: 18, color: Colors.grey.shade500),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),

            // ── Location status row ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  if (_loadingLocation) ...[
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: const Color(0xFFF47B8C)),
                    ),
                    const SizedBox(width: 6),
                    Text('Mendeteksi lokasi Anda...',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ] else if (_userPosition != null) ...[
                    const Icon(Icons.my_location_rounded,
                        size: 13, color: Color(0xFFF43D5E)),
                    const SizedBox(width: 6),
                    Text('Diurutkan dari yang terdekat',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ] else ...[
                    Icon(Icons.location_off_rounded,
                        size: 13, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Text('Lokasi tidak tersedia',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade400)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Results list ──
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildBody() {
    if (_loadingPanti) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF47B8C)),
      );
    }
    if (_errorPanti != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Gagal memuat data',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _loadingPanti = true;
                  _errorPanti = null;
                });
                _fetchPanti();
              },
              child: const Text('Coba lagi',
                  style: TextStyle(color: Color(0xFFF43D5E))),
            ),
          ],
        ),
      );
    }

    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Tidak ada hasil',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final panti = items[i];
        final distM = _distanceTo(panti);
        return _PantiCard(
          panti: panti,
          distanceLabel: _formatDistance(distM),
          isNearest: i == 0 && _userPosition != null && distM.isFinite,
          isLoading: _loadingPantiId.contains(panti.id),
          onTap: () => _openPantiDetail(panti),
          onLocationTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LokasiScreen(
                namaPanti: panti.namaPanti,
                alamat: panti.alamatPanti,
                lat: panti.lat ?? 0,
                lng: panti.lng ?? 0,
                distanceMeters: distM.isFinite ? distM : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavBar() {
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

// ── Panti Card ──
class _PantiCard extends StatelessWidget {
  final PantiProfileModel panti;
  final String distanceLabel;
  final bool isNearest;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onLocationTap;

  const _PantiCard({
    required this.panti,
    required this.distanceLabel,
    required this.isNearest,
    required this.onTap,
    required this.onLocationTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final address =
        panti.fullAddress.isNotEmpty ? panti.fullAddress : panti.alamatPanti;

    return GestureDetector(
      onTap: onLocationTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE8EA),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Nama + "Kunjungi Profil" ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    panti.namaPanti,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A)),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: isLoading ? null : onTap,
                  child: isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFF47B8C),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF28695),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Kunjungi Profil',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ],
            ),
            if (isNearest) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF43D5E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Terdekat',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ),
            ],
            const SizedBox(height: 12),

            // ── Alamat ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(Icons.location_on_rounded,
                      size: 15, color: Color(0xFFE03050)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF1A1A1A), height: 1.55),
                  ),
                ),
                if (distanceLabel.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.near_me_rounded,
                          size: 12, color: Color(0xFFF47B8C)),
                      const SizedBox(width: 3),
                      Text(distanceLabel,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFF47B8C),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),

            // ── Telepon ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(Icons.phone_rounded,
                      size: 15, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${panti.nomorPanti} (hubungi untuk jam kunjungan)',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600, height: 1.4),
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

// ── Location Rationale Dialog ──
class _LocationRationaleDialog extends StatelessWidget {
  const _LocationRationaleDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8EA),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on_rounded,
                  size: 32, color: Color(0xFFF43D5E)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Izinkan Akses Lokasi',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'RuangPeduli membutuhkan lokasi Anda untuk menampilkan panti asuhan terdekat dan mengurutkan berdasarkan jarak.',
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade600, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF43D5E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Izinkan',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Nanti saja',
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nav Item ──
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
