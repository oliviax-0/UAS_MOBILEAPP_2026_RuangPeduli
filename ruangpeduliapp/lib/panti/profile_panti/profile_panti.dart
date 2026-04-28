import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunchUrl, launchUrl, LaunchMode;
import 'package:ruangpeduliapp/panti/profile_panti/edit_profile_panti.dart';
import 'package:ruangpeduliapp/panti/profile_panti/popup_panti.dart';
import 'package:ruangpeduliapp/panti/profile_panti/kebutuhan_panti.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/data/content_api.dart';
import 'package:ruangpeduliapp/auth/role_selection_screen.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_beritabaru.dart';
import 'package:ruangpeduliapp/panti/profile_panti/video_baru_panti.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const Color kPink = Color(0xFFF28C9F);
const Color kPinkDark = Color(0xFFE5728A);
const Color kGrey = Color(0xFFF0F0F0);

// ─── Main Page ───────────────────────────────────────────────────────────────

class ProfilePanti extends StatefulWidget {
  final int? pantiId;
  final int? userId;
  const ProfilePanti({super.key, this.pantiId, this.userId});

  @override
  State<ProfilePanti> createState() => _ProfilePantiState();
}

class _ProfilePantiState extends State<ProfilePanti> {
  PantiProfileModel? _profile;
  List<PantiMediaModel> _fotos = [];
  List<PantiMediaModel> _videos = [];
  List<BeritaModel> _beritas = [];

  @override
  void initState() {
    super.initState();
    if (widget.pantiId != null) {
      _loadAll(widget.pantiId!);
    }
  }

  Future<void> _loadAll(int pantiId) async {
    final api = ProfileApi();
    final profileFuture = api.fetchPantiProfile(pantiId).catchError((_) => PantiProfileModel(
      id: pantiId, username: '', email: '', namaPanti: '', alamatPanti: '', nomorPanti: '', description: '',
    ));
    final mediaFuture   = api.fetchPantiMedia(pantiId).catchError((_) => <PantiMediaModel>[]);
    final beritaFuture  = ContentApi().fetchBeritas(pantiId: pantiId).catchError((_) => <BeritaModel>[]);

    final results = await Future.wait([profileFuture, mediaFuture, beritaFuture]);
    if (!mounted) return;
    final allMedia = results[1] as List<PantiMediaModel>;
    setState(() {
      _profile = results[0] as PantiProfileModel;
      _fotos   = allMedia.where((m) => !m.isVideo).toList();
      _videos  = allMedia.where((m) => m.isVideo).toList();
      _beritas = results[2] as List<BeritaModel>;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ──────────────────────────────────────────────────────────────
        _buildFixedHeader(),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        Expanded(
          child: _buildScrollableBody(),
        ),
      ],
    );
  }

  // ─── Fixed Header ─────────────────────────────────────────────────────────

  Widget _buildFixedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          // Title
          const Text(
            'Profil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),

          // Profile row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kPink, width: 2.5),
                  color: Colors.grey[200],
                  image: _profile?.profilePicture != null
                      ? DecorationImage(
                          image: NetworkImage(_profile!.profilePicture!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _profile?.profilePicture == null
                    ? const Icon(Icons.home_work_rounded, color: Colors.grey, size: 32)
                    : null,
              ),
              const SizedBox(width: 14),

              // Name + username + button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _profile?.namaPanti ?? '...',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _logout,
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
                      _profile != null ? '@${_profile!.username}' : '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _profile == null || widget.pantiId == null
                            ? null
                            : _openEditProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPink,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Edit Profil',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<PantiProfileModel>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePanti(
          pantiId: widget.pantiId!,
          userId: widget.userId ?? 0,
          initialProfile: _profile!,
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _profile = updated);
    }
  }

  // ─── Scrollable Body ──────────────────────────────────────────────────────

  Widget _buildScrollableBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kebutuhan button
          if (widget.pantiId != null && widget.userId != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KebutuhanPantiPage(
                      pantiId: widget.pantiId!,
                      userId: widget.userId!,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  'Kebutuhan',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Alamat
          _SectionHeader(
            title: 'Alamat',
            onAdd: widget.pantiId == null ? null : () => _editAlamat(),
          ),
          const SizedBox(height: 8),
          _GreyContainer(child: Text(_profile?.alamatPanti ?? '...', style: _bodyStyle())),

          const SizedBox(height: 20),

          // Foto
          _SectionHeader(
            title: 'Foto',
            onAdd: widget.pantiId == null ? null : () => _editFoto(),
          ),
          const SizedBox(height: 8),
          _buildFotoGallery(),

          const SizedBox(height: 20),

          // Deskripsi
          _SectionHeader(
            title: 'Deskripsi',
            onAdd: widget.pantiId == null ? null : () => _editDeskripsi(),
          ),
          const SizedBox(height: 8),
          _GreyContainer(child: Text(_profile?.description ?? '...', style: _bodyStyle())),

          const SizedBox(height: 20),

          // Video
          _SectionHeader(
            title: 'Video',
            onAdd: widget.pantiId == null ? null : () => _editVideo(),
          ),
          const SizedBox(height: 8),
          _buildVideoGallery(),

          const SizedBox(height: 20),

          // Postingan
          _SectionHeader(
            title: 'Postingan',
            onAdd: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BeritaBaruPanti(userId: widget.userId, pantiId: widget.pantiId),
              ),
            ).then((_) {
              if (widget.pantiId != null) _loadAll(widget.pantiId!);
            }),
          ),
          const SizedBox(height: 12),
          _buildPostFeed(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _editAlamat() async {
    final newValue = await showAlamatPopup(
      context,
      pantiId: widget.pantiId!,
      initialValue: _profile?.alamatPanti ?? '',
    );
    if (newValue != null && mounted) {
      setState(() => _profile = _profile?.copyWith(alamatPanti: newValue));
    }
  }

  Future<void> _editDeskripsi() async {
    final newValue = await showDeskripsiPopup(
      context,
      pantiId: widget.pantiId!,
      initialValue: _profile?.description ?? '',
    );
    if (newValue != null && mounted) {
      setState(() => _profile = _profile?.copyWith(description: newValue));
    }
  }

  Future<void> _editFoto() async {
    final updated = await showFotoPopup(
      context,
      pantiId: widget.pantiId!,
      media: _fotos,
    );
    if (updated != null && mounted) setState(() => _fotos = updated);
  }

  Future<void> _editVideo() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => VideoBaruPanti(pantiId: widget.pantiId!),
      ),
    );
    if (added == true && mounted) _loadAll(widget.pantiId!);
  }

  // ─── Foto Gallery ─────────────────────────────────────────────────────────

  Widget _buildFotoGallery() {
    if (_fotos.isEmpty) {
      return _GreyContainer(child: Text('Belum ada foto.', style: _bodyStyle()));
    }
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _fotos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final item = _fotos[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.file != null
                ? Image.network(
                    item.file!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            width: 100, height: 100, color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(kPink))),
                          ),
                    errorBuilder: (_, __, ___) => Container(
                      width: 100, height: 100, color: Colors.grey[200],
                      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                    ),
                  )
                : Container(width: 100, height: 100, color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey)),
          );
        },
      ),
    );
  }

  // ─── Video Gallery ────────────────────────────────────────────────────────

  Widget _buildVideoGallery() {
    if (_videos.isEmpty) {
      return _GreyContainer(child: Text('Belum ada video.', style: _bodyStyle()));
    }
    return Column(
      children: _videos.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _VideoCard(item: item, onDelete: () => _deleteVideo(item)),
        );
      }).toList(),
    );
  }

  // ─── Post Feed ────────────────────────────────────────────────────────────

  Widget _buildPostFeed() {
    if (_beritas.isEmpty) {
      return _GreyContainer(
        child: Text('Belum ada postingan.', style: _bodyStyle()),
      );
    }
    return Column(
      children: _beritas.map((berita) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _PostCard(
            berita: berita,
            onDelete: () => _deleteBerita(berita),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _deleteBerita(BeritaModel berita) async {
    final confirm = await _confirmDelete(context, 'postingan ini');
    if (!confirm || !mounted) return;
    try {
      await ContentApi().deleteBerita(berita.id, widget.userId ?? 0);
      if (!mounted) return;
      setState(() => _beritas.removeWhere((b) => b.id == berita.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan berhasil dihapus'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _deleteVideo(PantiMediaModel video) async {
    final confirm = await _confirmDelete(context, 'video ini');
    if (!confirm || !mounted) return;
    try {
      await ProfileApi().deletePantiMedia(widget.pantiId!, video.id);
      if (!mounted) return;
      setState(() => _videos.removeWhere((v) => v.id == video.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video berhasil dihapus'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<bool> _confirmDelete(BuildContext ctx, String target) async {
    return await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          'Apakah Anda yakin ingin menghapus $target?',
          style: const TextStyle(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFDDDDDD)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text('Ya', style: TextStyle(color: Color(0xFF1A1A1A))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8848A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text('Tidak'),
          ),
        ],
      ),
    ) ?? false;
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

TextStyle _bodyStyle() => const TextStyle(
      fontSize: 13.5,
      color: Color(0xFF444444),
      height: 1.55,
    );

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAdd;

  const _SectionHeader({required this.title, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        if (onAdd != null) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onAdd,
            child: const Icon(Icons.add_circle_outline_rounded, size: 20, color: Color(0xFF1A1A1A)),
          ),
        ],
      ],
    );
  }
}

// ─── Grey Container ───────────────────────────────────────────────────────────

class _GreyContainer extends StatelessWidget {
  final Widget child;
  const _GreyContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

// ─── Video Card ───────────────────────────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  final PantiMediaModel item;
  final VoidCallback onDelete;
  const _VideoCard({required this.item, required this.onDelete});

  Future<void> _open() async {
    final url = item.file ?? (item.videoUrl.isNotEmpty ? item.videoUrl : null);
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            // Thumbnail area
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: const Color(0xFF1A1A2E),
                    child: const Center(
                      child: Icon(Icons.videocam_rounded, color: Colors.white24, size: 48),
                    ),
                  ),
                  const Center(
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
            ),
            // Title + description + delete
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.title.isNotEmpty)
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              color: Color(0xFF1A1A1A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (item.title.isNotEmpty && item.description.isNotEmpty)
                          const SizedBox(height: 6),
                        if (item.description.isNotEmpty)
                          Text(
                            item.description,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.45),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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

// ─── Post Card ────────────────────────────────────────────────────────────────

class _PostCard extends StatelessWidget {
  final BeritaModel berita;
  final VoidCallback onDelete;
  const _PostCard({required this.berita, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          AspectRatio(
            aspectRatio: 16 / 9,
            child: berita.thumbnail != null
                ? Image.network(
                    berita.thumbnail!,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(kPink),
                              ),
                            ),
                          ),
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image_outlined,
                          color: Colors.grey, size: 40),
                    ),
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: Colors.grey, size: 40),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        berita.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        berita.formattedDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
