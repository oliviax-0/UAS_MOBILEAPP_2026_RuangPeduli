import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/data/content_api.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/masyarakat/home/panti_detail_screen.dart';

class BeritaDetailScreen extends StatefulWidget {
  final BeritaModel berita;
  final int? userId;

  const BeritaDetailScreen({super.key, required this.berita, this.userId});

  @override
  State<BeritaDetailScreen> createState() => _BeritaDetailScreenState();
}

class _BeritaDetailScreenState extends State<BeritaDetailScreen> {
  bool _loadingProfile = false;

  Future<void> _onLihatProfil() async {
    if (widget.berita.pantiId == null) return;
    setState(() => _loadingProfile = true);
    try {
      final api = ProfileApi();
      final results = await Future.wait([
        api.fetchPantiProfile(widget.berita.pantiId!),
        api.fetchPantiMedia(widget.berita.pantiId!),
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
            pantiId: widget.berita.pantiId,
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
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Berita',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ──
            _buildThumbnail(),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title ──
                  Text(
                    widget.berita.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Panti row ──
                  Row(
                    children: [
                      _pantiAvatar(),
                      const SizedBox(width: 10),
                      Text(
                        widget.berita.pantiName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Content ──
                  Text(
                    widget.berita.content,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Action button ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (widget.berita.pantiId == null || _loadingProfile)
                          ? null
                          : _onLihatProfil,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8848A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: _loadingProfile
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Lihat Profil', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (widget.berita.thumbnail != null && widget.berita.thumbnail!.isNotEmpty) {
      return Image.network(
        widget.berita.thumbnail!,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderThumbnail(),
      );
    }
    return _placeholderThumbnail();
  }

  Widget _placeholderThumbnail() {
    return Container(
      width: double.infinity,
      height: 220,
      color: const Color(0xFFCFBFC2),
      child: const Center(
        child: Icon(Icons.image_rounded, size: 56, color: Colors.white54),
      ),
    );
  }

  Widget _pantiAvatar() {
    if (widget.berita.pantiProfilePicture != null &&
        widget.berita.pantiProfilePicture!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          widget.berita.pantiProfilePicture!,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultPantiIcon(),
        ),
      );
    }
    return _defaultPantiIcon();
  }

  Widget _defaultPantiIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF43D5E).withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.home_work_rounded,
        size: 20,
        color: Color(0xFFF43D5E),
      ),
    );
  }
}
