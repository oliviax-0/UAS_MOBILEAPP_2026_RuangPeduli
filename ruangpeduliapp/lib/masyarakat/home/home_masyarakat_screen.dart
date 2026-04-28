import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:ruangpeduliapp/masyarakat/notification/notification_screen.dart';
import 'package:ruangpeduliapp/data/content_api.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/masyarakat/home/berita_detail_screen.dart';
import 'package:ruangpeduliapp/masyarakat/home/panti_detail_screen.dart';
import 'package:ruangpeduliapp/masyarakat/search/search_screen.dart';
import 'package:ruangpeduliapp/masyarakat/profile/profile_screen.dart';
import 'package:ruangpeduliapp/masyarakat/history/riwayat_donasi_screen.dart';
import 'package:ruangpeduliapp/masyarakat/chatbot/chatbot_masyarakat_screen.dart';

// ─────────────────────────────────────────────
//  HOME MASYARAKAT SCREEN
// ─────────────────────────────────────────────
class HomeMasyarakatScreen extends StatefulWidget {
  final int? userId;
  const HomeMasyarakatScreen({super.key, this.userId});

  @override
  State<HomeMasyarakatScreen> createState() => _HomeMasyarakatScreenState();
}

class _HomeMasyarakatScreenState extends State<HomeMasyarakatScreen> {
  int _selectedIndex = 0;

  List<BeritaModel> _beritas = [];
  List<VideoModel> _videos = [];
  List<PantiUploadedVideo> _pantiVideos = [];
  bool _isLoading = true;
  String? _profilePictureUrl;

  final _stt = SpeechToText();
  bool _sttReady = false;
  bool _listening = false;
  String? _sttLocale;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initStt();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (widget.userId == null) return;
    final profile = await ProfileApi().fetchMasyarakatProfile(widget.userId!);
    if (mounted) setState(() => _profilePictureUrl = profile?.profilePicture);
  }

  Future<void> _initStt() async {
    final ok = await _stt.initialize(
      onStatus: (s) {
        if ((s == 'done' || s == 'notListening') && mounted) {
          setState(() => _listening = false);
        }
      },
      onError: (e) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (!mounted) return;
    if (ok) {
      final locales = await _stt.locales();
      final idLocale = locales.firstWhere(
        (l) => l.localeId.startsWith('id'),
        orElse: () => locales.first,
      );
      setState(() { _sttReady = true; _sttLocale = idLocale.localeId; });
    } else {
      setState(() => _sttReady = false);
    }
  }

  @override
  void dispose() {
    _stt.cancel();
    super.dispose();
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
    setState(() => _listening = true);
    await _stt.listen(
      localeId: _sttLocale,
      onResult: (r) async {
        if (r.finalResult && mounted) {
          setState(() => _listening = false);
          final query = r.recognizedWords;
          if (query.isNotEmpty) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchScreen(userId: widget.userId, initialQuery: query),
              ),
            );
          }
          if (mounted) setState(() => _selectedIndex = 0);
        }
      },
      listenOptions: SpeechListenOptions(
        partialResults: false,
        cancelOnError: true,
        listenMode: ListenMode.search,
      ),
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final contentApi = ContentApi();
    final profileApi = ProfileApi();
    final results = await Future.wait([
      contentApi.fetchBeritas(),
      contentApi.fetchVideos(),
      profileApi.fetchAllPantiVideos(),
    ]);
    if (mounted) {
      setState(() {
        _beritas = results[0] as List<BeritaModel>;
        _videos = results[1] as List<VideoModel>;
        _pantiVideos = results[2] as List<PantiUploadedVideo>;
        _isLoading = false;
      });
    }
  }

  Future<void> _openPantiDetail(int pantiId) async {
    try {
      final api = ProfileApi();
      final results = await Future.wait([
        api.fetchPantiProfile(pantiId),
        api.fetchPantiMedia(pantiId),
      ]);
      if (!mounted) return;
      final profile = results[0] as PantiProfileModel;
      final media = results[1] as List<PantiMediaModel>;
      final mediaUrls = media
          .where((m) => m.file != null && m.file!.isNotEmpty)
          .map((m) => m.file!)
          .toList();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PantiDetailScreen(
            pantiId: pantiId,
            namaPanti: profile.namaPanti,
            username: '@${profile.username}',
            nomorPanti: profile.nomorPanti,
            alamatPanti: profile.alamatPanti,
            description: profile.description,
            profilePicture: profile.profilePicture,
            terkumpul: profile.formattedTotalTerkumpul,
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
    }
  }

  void _onNavTap(int index) {
    if (index == 0) return;
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(userId: widget.userId)))
          .then((_) { if (mounted) setState(() => _selectedIndex = 0); });
      return;
    }
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => RiwayatDonasiScreen(userId: widget.userId)))
          .then((_) { if (mounted) setState(() => _selectedIndex = 0); });
      return;
    }
    if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: widget.userId)))
          .then((_) { if (mounted) setState(() => _selectedIndex = 0); });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: const Color(0xFFF43D5E),
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildTopBar(),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Berita', onTap: () {}),
                    const SizedBox(height: 12),
                    _buildBeritaList(),
                    const SizedBox(height: 28),
                    _buildSectionHeader('Video Terbaru', onTap: () {}),
                    const SizedBox(height: 12),
                    _buildVideoList(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // ── Chatbot FAB ──
            Positioned(
              bottom: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatbotMasyarakatScreen(userId: widget.userId),
                  ),
                ),
                child: Image.asset(
                  'assets/images/chatbot_ai.png',
                  width: 56,
                  height: 56,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF43D5E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  // ── Top bar ──
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen(userId: widget.userId)),
            ).then((_) => _loadUserProfile()),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF43D5E), width: 2),
                color: Colors.grey.shade200,
              ),
              child: ClipOval(
                child: _profilePictureUrl != null && _profilePictureUrl!.isNotEmpty
                    ? Image.network(
                        _profilePictureUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.person_rounded, size: 28, color: Colors.grey.shade500),
                      )
                    : Icon(Icons.person_rounded, size: 28, color: Colors.grey.shade500),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchScreen(userId: widget.userId)),
              ).then((_) { if (mounted) setState(() => _selectedIndex = 0); }),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleMic,
                      child: Icon(
                        _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        size: 18,
                        color: _listening ? const Color(0xFFF47B8C) : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _listening ? 'Mendengarkan...' : 'Search',
                      style: TextStyle(
                        fontSize: 14,
                        color: _listening ? const Color(0xFFF47B8C) : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationScreen(userId: widget.userId),
              ),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 28,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ──
  Widget _buildSectionHeader(String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right_rounded, size: 26, color: Color(0xFF1A1A1A)),
          ],
        ),
      ),
    );
  }

  // ── Berita list ──
  Widget _buildBeritaList() {
    if (_isLoading) {
      return const SizedBox(
        height: 235,
        child: Center(child: CircularProgressIndicator(color: Color(0xFFF43D5E))),
      );
    }
    if (_beritas.isEmpty) {
      return SizedBox(
        height: 235,
        child: Center(
          child: Text('Belum ada berita', style: TextStyle(color: Colors.grey.shade400)),
        ),
      );
    }

    return SizedBox(
      height: 235,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _beritas.length,
        itemBuilder: (context, i) {
          final item = _beritas[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BeritaDetailScreen(berita: item, userId: widget.userId)),
            ),
            child: Container(
              width: 215,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: item.thumbnail != null && item.thumbnail!.isNotEmpty
                        ? Image.network(
                            item.thumbnail!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(150),
                          )
                        : _imagePlaceholder(150),
                  ),
                  // Title + date
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.formattedDate,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Video list (content videos + panti uploaded videos combined) ──
  Widget _buildVideoList() {
    if (_isLoading) {
      return const SizedBox(
        height: 215,
        child: Center(child: CircularProgressIndicator(color: Color(0xFFF43D5E))),
      );
    }
    final totalCount = _videos.length + _pantiVideos.length;
    if (totalCount == 0) {
      return SizedBox(
        height: 215,
        child: Center(
          child: Text('Belum ada video', style: TextStyle(color: Colors.grey.shade400)),
        ),
      );
    }

    return SizedBox(
      height: 215,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: totalCount,
        itemBuilder: (context, i) {
          // First show content videos, then panti videos
          if (i < _videos.length) {
            final video = _videos[i];
            final videoId = RegExp(r'(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)([a-zA-Z0-9_-]{11})').firstMatch(video.videoUrl)?.group(1);
            final ytThumb = videoId != null
                ? 'https://img.youtube.com/vi/$videoId/mqdefault.jpg'
                : null;
            return GestureDetector(
              onTap: video.pantiId != null ? () => _openPantiDetail(video.pantiId!) : null,
              child: _videoCard(
                thumbnail: _videoThumbnail(video.thumbnail, ytThumb),
                label: video.pantiName,
              ),
            );
          } else {
            final video = _pantiVideos[i - _videos.length];
            final videoId = RegExp(r'(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)([a-zA-Z0-9_-]{11})').firstMatch(video.videoUrl)?.group(1);
            final ytThumb = videoId != null
                ? 'https://img.youtube.com/vi/$videoId/mqdefault.jpg'
                : null;
            return GestureDetector(
              onTap: () => _openPantiDetail(video.pantiId),
              child: _videoCard(
                thumbnail: _videoThumbnail(null, ytThumb),
                label: video.title.isNotEmpty ? video.title : video.pantiName,
                sublabel: video.title.isNotEmpty ? video.pantiName : null,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _videoCard({
    required Widget thumbnail,
    required String label,
    String? sublabel,
  }) {
    return Container(
      width: 178,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Stack(
              children: [
                thumbnail,
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Color(0xFFF43D5E), size: 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43D5E).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_circle_outline_rounded, size: 15, color: Color(0xFFF43D5E)),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (sublabel != null) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(
                      sublabel,
                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoThumbnail(String? customThumb, String? ytThumb) {
    if (customThumb != null && customThumb.isNotEmpty) {
      return Image.network(
        customThumb,
        height: 145,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _videoThumbnail(null, ytThumb),
      );
    }
    if (ytThumb != null) {
      return Image.network(
        ytThumb,
        height: 145,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(145, color: const Color(0xFFBFB0B3)),
      );
    }
    return Container(
      height: 145,
      width: double.infinity,
      color: const Color(0xFF1A1A2E),
      child: const Center(
        child: Icon(Icons.videocam_rounded, color: Colors.white24, size: 40),
      ),
    );
  }

  Widget _imagePlaceholder(double height, {Color color = const Color(0xFFCFBFC2)}) {
    return Container(
      height: height,
      width: double.infinity,
      color: color,
      child: Center(
        child: Icon(Icons.image_rounded, size: 44, color: Colors.grey.shade300),
      ),
    );
  }

  // ── Bottom nav bar ──
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
              _NavItem(icon: Icons.home_rounded, selected: _selectedIndex == 0, onTap: () => _onNavTap(0)),
              _NavItem(icon: Icons.search_rounded, selected: _selectedIndex == 1, onTap: () => _onNavTap(1)),
              _NavItem(icon: Icons.history_rounded, selected: _selectedIndex == 2, onTap: () => _onNavTap(2)),
              _NavItem(icon: Icons.person_rounded, selected: _selectedIndex == 3, onTap: () => _onNavTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NAV ITEM WIDGET
// ─────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: selected ? Colors.white : Colors.white.withValues(alpha: 0.60),
            ),
            if (selected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}

