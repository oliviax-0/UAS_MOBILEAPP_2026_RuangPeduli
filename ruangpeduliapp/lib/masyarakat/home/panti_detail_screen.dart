import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ruangpeduliapp/data/content_api.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/masyarakat/home/berita_detail_screen.dart';
import 'package:ruangpeduliapp/masyarakat/home/kebutuhan_screen.dart';
import 'package:ruangpeduliapp/masyarakat/transaksi/konfirmasi_pembayaran_screen.dart';

class PantiDetailScreen extends StatefulWidget {
  final int? pantiId;
  final String namaPanti;
  final String username;
  final String nomorPanti;
  final String alamatPanti;
  final String description;
  final String? profilePicture;
  final String terkumpul;
  final int? userId;
  final bool showNavBar;
  final List<String> mediaUrls;
  final bool isPantiViewer;

  const PantiDetailScreen({
    super.key,
    this.pantiId,
    required this.namaPanti,
    required this.username,
    required this.nomorPanti,
    required this.alamatPanti,
    required this.description,
    this.profilePicture,
    required this.terkumpul,
    this.userId,
    this.showNavBar = true,
    this.mediaUrls = const [],
    this.isPantiViewer = false,
  });

  @override
  State<PantiDetailScreen> createState() => _PantiDetailScreenState();
}

class _PantiDetailScreenState extends State<PantiDetailScreen> {
  List<BeritaModel> _beritas = [];
  List<PantiMediaModel> _fotos = [];
  List<PantiMediaModel> _pantiVideos = [];   // uploaded via profile media
  List<VideoModel> _contentVideos = [];       // posted via content/video
  bool _loading = true;
  late String _terkumpul;

  @override
  void initState() {
    super.initState();
    _terkumpul = widget.terkumpul;
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    if (widget.pantiId == null) {
      setState(() => _loading = false);
      return;
    }
    final results = await Future.wait([
      ContentApi().fetchBeritas(pantiId: widget.pantiId).catchError((_) => <BeritaModel>[]),
      ContentApi().fetchVideos(pantiId: widget.pantiId).catchError((_) => <VideoModel>[]),
      ProfileApi().fetchPantiMedia(widget.pantiId!).catchError((_) => <PantiMediaModel>[]),
    ]);
    if (!mounted) return;
    final allMedia = results[2] as List<PantiMediaModel>;
    setState(() {
      _beritas       = results[0] as List<BeritaModel>;
      _contentVideos = results[1] as List<VideoModel>;
      _fotos         = allMedia.where((m) => !m.isVideo).toList();
      _pantiVideos   = allMedia.where((m) => m.isVideo).toList();
      _loading       = false;
    });
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text('Profil',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFF43D5E), width: 2),
                              color: Colors.grey.shade100,
                            ),
                            child: ClipOval(
                              child: widget.profilePicture != null
                                  ? Image.network(widget.profilePicture!, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _avatarFallback())
                                  : _avatarFallback(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.namaPanti,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                                const SizedBox(height: 2),
                                Text(widget.username,
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                                const SizedBox(height: 2),
                                Text(widget.nomorPanti,
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Buttons ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _PinkButton(
                            label: 'Kebutuhan',
                            onPressed: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => KebutuhanScreen(
                                pantiId: widget.pantiId,
                                namaPanti: widget.namaPanti,
                                username: widget.username,
                                profilePicture: widget.profilePicture,
                                userId: widget.userId,
                              ),
                            )),
                          ),
                          if (!widget.isPantiViewer) ...[
                            const SizedBox(height: 10),
                            _PinkButton(
                              label: 'Donasi',
                              onPressed: () async {
                                final result = await Navigator.push<bool>(context, MaterialPageRoute(
                                  builder: (_) => KonfirmasiPembayaranScreen(
                                    namaPanti: widget.namaPanti,
                                    terkumpul: _terkumpul,
                                    imagePath: widget.profilePicture ?? '',
                                    pantiId: widget.pantiId,
                                    userId: widget.userId,
                                  ),
                                ));
                                if (result == true && mounted) {
                                  if (widget.pantiId != null) {
                                    try {
                                      final updated = await ProfileApi().fetchPantiProfile(widget.pantiId!);
                                      if (mounted) setState(() => _terkumpul = updated.formattedTotalTerkumpul);
                                    } catch (_) {}
                                  }
                                  _fetchContent();
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 16),

                    // ── Alamat ──
                    _SectionLabel('Alamat'),
                    const SizedBox(height: 8),
                    _GreyBox(child: Text(widget.alamatPanti,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A), height: 1.5))),
                    const SizedBox(height: 20),

                    // ── Foto ──
                    _SectionLabel('Foto'),
                    const SizedBox(height: 10),
                    _buildFoto(),
                    const SizedBox(height: 20),

                    // ── Deskripsi ──
                    _SectionLabel('Deskripsi'),
                    const SizedBox(height: 8),
                    _GreyBox(child: Text(
                      widget.description.isEmpty ? 'Belum ada deskripsi.' : widget.description,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A), height: 1.6),
                    )),
                    const SizedBox(height: 20),

                    // ── Postingan ──
                    _SectionLabel('Postingan'),
                    const SizedBox(height: 10),
                    _buildPostingan(),
                    const SizedBox(height: 20),

                    // ── Video ──
                    _SectionLabel('Video'),
                    const SizedBox(height: 10),
                    _buildVideos(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Foto ──────────────────────────────────────────────────────────────────

  Widget _buildFoto() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_fotos.isEmpty) {
      return _GreyBox(child: Text('Belum ada foto.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500)));
    }
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _fotos.length,
        itemBuilder: (_, i) {
          final m = _fotos[i];
          return Container(
            width: 90, height: 90,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFDDCDD0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: m.file != null && m.file!.isNotEmpty
                  ? Image.network(m.file!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.image_rounded, color: Colors.grey.shade400))
                  : Icon(Icons.image_rounded, color: Colors.grey.shade400),
            ),
          );
        },
      ),
    );
  }

  // ── Postingan ──────────────────────────────────────────────────────────────

  Widget _buildPostingan() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_beritas.isEmpty) {
      return _GreyBox(child: Text('Belum ada postingan.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500)));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _beritas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final b = _beritas[i];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => BeritaDetailScreen(berita: b, userId: widget.userId),
          )),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  child: b.thumbnail != null && b.thumbnail!.isNotEmpty
                      ? Image.network(b.thumbnail!, width: 90, height: 90, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _thumbFallback())
                      : _thumbFallback(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 6),
                        Text(b.formattedDate,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Video ──────────────────────────────────────────────────────────────────

  Widget _buildVideos() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final totalCount = _contentVideos.length + _pantiVideos.length;
    if (totalCount == 0) {
      return _GreyBox(child: Text('Belum ada video.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500)));
    }

    // Build unified list: content videos first, then panti media videos
    final items = <Widget>[
      for (final v in _contentVideos)
        _VideoRow(
          thumbnail: _ytThumb(v.videoUrl),
          title: v.title,
          description: v.description,
          onTap: () async {
            final uri = Uri.parse(v.videoUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        ),
      for (final v in _pantiVideos)
        _VideoRow(
          thumbnail: null,
          title: v.title,
          description: v.description,
          onTap: () async {
            final url = v.file ?? (v.videoUrl.isNotEmpty ? v.videoUrl : null);
            if (url == null) return;
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        ),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => items[i],
    );
  }

  String? _ytThumb(String videoUrl) {
    final videoId = RegExp(r'(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)([a-zA-Z0-9_-]{11})')
        .firstMatch(videoUrl)?.group(1);
    return videoId != null ? 'https://img.youtube.com/vi/$videoId/mqdefault.jpg' : null;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _avatarFallback() => Container(
        color: Colors.grey.shade200,
        child: Icon(Icons.business_rounded, size: 36, color: Colors.grey.shade400),
      );

  Widget _thumbFallback() => Container(
        width: 90, height: 90,
        color: const Color(0xFFDDCDD0),
        child: Icon(Icons.newspaper_rounded, size: 28, color: Colors.grey.shade400),
      );
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _PinkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PinkButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF28695),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
    );
  }
}

class _VideoRow extends StatelessWidget {
  final String? thumbnail;
  final String title;
  final String description;
  final VoidCallback onTap;
  const _VideoRow({
    this.thumbnail,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  child: thumbnail != null
                      ? Image.network(thumbnail!, width: 90, height: 90, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _darkPlaceholder())
                      : _darkPlaceholder(),
                ),
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty)
                      Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(description, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _darkPlaceholder() => Container(
    width: 90, height: 90,
    color: const Color(0xFF1A1A2E),
    child: const Icon(Icons.videocam_rounded, color: Colors.white24, size: 32),
  );
}

class _GreyBox extends StatelessWidget {
  final Widget child;
  const _GreyBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}
