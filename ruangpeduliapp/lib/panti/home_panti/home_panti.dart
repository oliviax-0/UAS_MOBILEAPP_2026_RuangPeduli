import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_panti.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_plus.dart';
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti.dart';
import 'package:ruangpeduliapp/panti/profile_panti/profile_panti.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_berita_panti.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_beritabaru.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_ai.dart';
import 'package:ruangpeduliapp/data/content_api.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panti App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF28C9F)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const HomePanti(userId: null, pantiId: null),
    );
  }
}

// ─── Constants ───────────────────────────────────────────────────────────────

const Color kPink = Color(0xFFF28C9F);
const Color kPinkDark = Color(0xFFE5728A);
const Color kCardBg = Colors.white;
const double kRadius = 20.0;

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _icons = [
    Icons.home_rounded,
    Icons.account_balance_wallet_outlined,
    Icons.inventory_2_outlined,
    Icons.person_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kPink,
        boxShadow: [
          BoxShadow(
            color: Color(0x30F28C9F),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_icons.length, (index) {
              final selected = index == currentIndex;
              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Icon(
                        _icons[index],
                        color: selected ? Colors.black : Colors.white.withValues(alpha: 0.65),
                        size: 26,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 3,
                      width: selected ? 24 : 0,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}


// ─── Main Page ───────────────────────────────────────────────────────────────

class HomePanti extends StatefulWidget {
  final int? userId;
  final int? pantiId;

  const HomePanti({super.key, required this.userId, required this.pantiId});

  @override
  State<HomePanti> createState() => _HomePantiState();
}

class _HomePantiState extends State<HomePanti> {
  int _selectedIndex = 0;
  int _keuanganRefreshTrigger = 0;
  final TextEditingController _searchController = TextEditingController();
  String? _profilePictureUrl;

  List<BeritaModel> _beritas = [];
  bool _loading = true;
  String? _error;
  Timer? _debounce;

  final SpeechToText _stt = SpeechToText();
  bool _sttReady = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _fetchBeritas();
    _searchController.addListener(_onSearchChanged);
    _stt.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _listening = false);
        }
      },
      onError: (error) {
        if (mounted) setState(() => _listening = false);
      },
    ).then((ok) { if (mounted) setState(() => _sttReady = ok); });
    if (widget.pantiId != null) {
      ProfileApi().fetchPantiProfile(widget.pantiId!).then((profile) {
        if (mounted) setState(() => _profilePictureUrl = profile.profilePicture);
      }).catchError((_) {});
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchBeritas(search: _searchController.text.trim());
    });
  }

  Future<void> _fetchBeritas({String? search}) async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ContentApi().fetchBeritas(
        search: search?.isNotEmpty == true ? search : null,
      );
      if (mounted) setState(() { _beritas = result; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _toggleMic() async {
    if (!_sttReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mikrofon tidak tersedia di perangkat ini')),
      );
      return;
    }
    if (_listening) {
      await _stt.stop();
      setState(() => _listening = false);
      return;
    }

    // Pick best available locale (prefer id_ID, fall back to device default)
    final locales = await _stt.locales();
    String? localeId;
    for (final l in locales) {
      if (l.localeId.startsWith('id')) { localeId = l.localeId; break; }
    }

    setState(() { _listening = true; _searchController.clear(); });
    await _stt.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() => _searchController.text = result.recognizedWords);
        if (result.finalResult) {
          setState(() => _listening = false);
          _fetchBeritas(search: result.recognizedWords.trim());
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: localeId,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _stt.stop();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App Bar (only for home) ──────────────────────────────────────
            if (_selectedIndex == 0) _buildAppBar(),
            // ── Content based on selected tab ────────────────────────────────
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: _selectedIndex == 2 ? null : _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ── Bottom Nav ───────────────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── Content Builder based on selected index ─────────────────────────────

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildNewsFeed();
      case 1:
        return KeuanganPanti(userId: widget.userId, refreshTrigger: _keuanganRefreshTrigger);
      case 2:
        return InventarisPanti(userId: widget.userId, pantiId: widget.pantiId);
      case 3:
        return ProfilePanti(pantiId: widget.pantiId, userId: widget.userId);
      default:
        return _buildNewsFeed();
    }
  }

  // ─── App Bar ─────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Profile avatar
          GestureDetector(
            onTap: () => setState(() => _selectedIndex = 3),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kPink, width: 2),
                color: Colors.grey[200],
                image: _profilePictureUrl != null
                    ? DecorationImage(
                        image: NetworkImage(_profilePictureUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _profilePictureUrl == null
                  ? const Icon(Icons.home_work_rounded, color: Colors.grey, size: 24)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Search bar
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15,
                  ),
                  prefixIcon: IconButton(
                    onPressed: _toggleMic,
                    icon: Icon(
                      _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: _listening ? kPink : Colors.grey[400],
                      size: 22,
                    ),
                    splashRadius: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── News Feed ───────────────────────────────────────────────────────────

  Widget _buildNewsFeed() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(kPink)),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
      );
    }
    if (_beritas.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.trim().isNotEmpty
              ? 'Tidak ada berita untuk "${_searchController.text.trim()}".'
              : 'Belum ada berita.',
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    return RefreshIndicator(
      color: kPink,
      onRefresh: _fetchBeritas,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: _beritas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) =>
            _NewsCard(
              item: _beritas[index],
              userId: widget.userId,
              viewerPantiId: widget.pantiId,
              onGoToOwnProfile: () => setState(() => _selectedIndex = 3),
            ),
      ),
    );
  }

  // ─── FAB ─────────────────────────────────────────────────────────────────

  Widget _buildFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () async {
            if (_selectedIndex == 3) {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => BeritaBaruPanti(userId: widget.userId, pantiId: widget.pantiId),
                ),
              );
              if (created == true) _fetchBeritas();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeAIPanti(userId: widget.userId, pantiId: widget.pantiId),
                ),
              );
            }
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 246, 243, 243),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPink.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _selectedIndex == 3
                  ? const Icon(Icons.add, color: kPink, size: 26)
                  : Image.asset(
                      'assets/images/chatbot_logo.png',
                      width: 28,
                      height: 28,
                    ),
            ),
          ),
        ),
        if (_selectedIndex == 0 || _selectedIndex == 1) ...[
        const SizedBox(height: 12),

        // Main + FAB
        FloatingActionButton(
          onPressed: () async {
            if (_selectedIndex == 1 &&
                widget.userId != null &&
                widget.pantiId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InputTransaksiPage(
                    userId: widget.userId!,
                    pantiId: widget.pantiId!,
                    onSaved: () => setState(() => _keuanganRefreshTrigger++),
                  ),
                ),
              );
            } else {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => BeritaBaruPanti(userId: widget.userId, pantiId: widget.pantiId),
                ),
              );
              if (created == true) _fetchBeritas();
            }
          },
          backgroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: kPinkDark, size: 28),
        ),
        ],
      ],
    );
  }

  // ─── Bottom Navigation Bar ───────────────────────────────────────────────

  Widget _buildBottomNav() {
    return BottomNav(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
    );
  }
}

// ─── News Card ────────────────────────────────────────────────────────────────

class _NewsCard extends StatelessWidget {
  final BeritaModel item;
  final int? userId;
  final int? viewerPantiId;
  final VoidCallback? onGoToOwnProfile;

  const _NewsCard({required this.item, required this.userId, this.viewerPantiId, this.onGoToOwnProfile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BeritaDetailPanti(
              beritaId: item.id,
              userId: userId,
              pantiId: item.pantiId,
              viewerPantiId: viewerPantiId,
              onGoToOwnProfile: onGoToOwnProfile,
              title: item.title,
              thumbnail: item.thumbnail,
              pantiProfilePicture: item.pantiProfilePicture,
              date: item.formattedDate,
              authorName: item.authorName,
              pantiName: item.pantiName,
              body: item.content,
              upvoteCount: item.upvoteCount,
              downvoteCount: item.downvoteCount,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(kRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Card Image ────────────────────────────────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: item.thumbnail != null
                  ? Image.network(
                      item.thumbnail!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(kPink),
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image_outlined,
                            color: Colors.grey, size: 40),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.newspaper_rounded,
                          color: Colors.grey, size: 40),
                    ),
            ),

            // ── Card Text Area ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
