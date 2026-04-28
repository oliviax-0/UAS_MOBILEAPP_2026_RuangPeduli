import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ruangpeduliapp/data/content_api.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const Color kPink = Color(0xFFF28C9F);

// ─── Screen ───────────────────────────────────────────────────────────────────

class BeritaBaruPanti extends StatefulWidget {
  final int? userId;
  final int? pantiId;
  const BeritaBaruPanti({super.key, this.userId, this.pantiId});

  @override
  State<BeritaBaruPanti> createState() => _BeritaBaruPantiState();
}

class _BeritaBaruPantiState extends State<BeritaBaruPanti> {
  final _judulController = TextEditingController();
  final _isiController   = TextEditingController();
  final _picker          = ImagePicker();

  File?  _thumbnail;
  bool   _submitting = false;

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  // ── Image picker ────────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFDE8EC),
                  child: Icon(Icons.camera_alt_rounded, color: kPink),
                ),
                title: const Text('Ambil Foto', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFDE8EC),
                  child: Icon(Icons.photo_library_rounded, color: kPink),
                ),
                title: const Text('Pilih dari Album', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null || !mounted) return;
    setState(() => _thumbnail = File(picked.path));
  }

  void _removeThumbnail() => setState(() => _thumbnail = null);

  // ── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final title   = _judulController.text.trim();
    final content = _isiController.text.trim();

    if (title.isEmpty) {
      _snack('Judul tidak boleh kosong');
      return;
    }
    if (content.isEmpty) {
      _snack('Isi artikel tidak boleh kosong');
      return;
    }
    if (widget.userId == null) {
      _snack('Sesi tidak valid, silakan login ulang');
      return;
    }

    setState(() => _submitting = true);
    try {
      await ContentApi().createBerita(
        userId:    widget.userId!,
        title:     title,
        content:   content,
        thumbnail: _thumbnail,
      );
      if (!mounted) return;
      _snack('Berita berhasil dibagikan!');
      Navigator.pop(context, true); // true = refresh parent list
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Text(
          'Postingan Baru',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1A1A1A), size: 26),
            onPressed: _submitting ? null : () => Navigator.pop(context),
            padding: const EdgeInsets.only(right: 12),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ─────────────────────────────────────────────────
            _buildThumbnailPicker(),
            const SizedBox(height: 24),

            // ── Judul ─────────────────────────────────────────────────────
            _buildLabel('Judul'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _judulController,
              hint: 'Ketik Judul',
              maxLines: 1,
            ),
            const SizedBox(height: 18),

            // ── Isi Artikel ───────────────────────────────────────────────
            _buildLabel('Isi Artikel'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _isiController,
              hint: 'Ketik Isi Artikel',
              maxLines: 8,
            ),
            const SizedBox(height: 32),

            // ── Bagikan Button ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPink,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: kPink.withValues(alpha: 0.5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Bagikan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Thumbnail picker ─────────────────────────────────────────────────────

  Widget _buildThumbnailPicker() {
    if (_thumbnail != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.file(_thumbnail!, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _removeThumbnail,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_photo_alternate_outlined, size: 48, color: Color(0xFF888888)),
            SizedBox(height: 8),
            Text(
              'Tambah Thumbnail',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Label ────────────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  // ─── Text Field ───────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: !_submitting,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPink, width: 1.5),
        ),
      ),
    );
  }
}
