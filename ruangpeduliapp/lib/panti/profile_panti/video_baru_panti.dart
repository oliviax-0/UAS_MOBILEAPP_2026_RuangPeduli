import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';

const Color kPink = Color(0xFFF28C9F);

class VideoBaruPanti extends StatefulWidget {
  final int pantiId;
  const VideoBaruPanti({super.key, required this.pantiId});

  @override
  State<VideoBaruPanti> createState() => _VideoBaruPantiState();
}

class _VideoBaruPantiState extends State<VideoBaruPanti> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _urlCtrl   = TextEditingController();
  final _picker    = ImagePicker();

  bool _useUrl    = false;
  File? _videoFile;
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() => _videoFile = File(picked.path));
  }

  void _removeVideo() => setState(() => _videoFile = null);

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final desc  = _descCtrl.text.trim();

    if (_useUrl) {
      final url = _urlCtrl.text.trim();
      if (url.isEmpty) { _snack('Masukkan URL video terlebih dahulu'); return; }
      setState(() => _submitting = true);
      try {
        await ProfileApi().uploadPantiMedia(
          widget.pantiId,
          videoUrl: url,
          mediaType: 'video',
          title: title,
          description: desc,
        );
        if (!mounted) return;
        _snack('Video berhasil ditambahkan!');
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        _snack(e.toString().replaceFirst('Exception: ', ''));
      } finally {
        if (mounted) setState(() => _submitting = false);
      }
    } else {
      if (_videoFile == null) { _snack('Pilih file video terlebih dahulu'); return; }
      setState(() => _submitting = true);
      try {
        await ProfileApi().uploadPantiMedia(
          widget.pantiId,
          file: _videoFile,
          mediaType: 'video',
          title: title,
          description: desc,
        );
        if (!mounted) return;
        _snack('Video berhasil diunggah!');
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        _snack(e.toString().replaceFirst('Exception: ', ''));
      } finally {
        if (mounted) setState(() => _submitting = false);
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

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
          'Video Baru',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
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
            // ── Toggle ───────────────────────────────────────────────────
            Row(
              children: [
                _ToggleChip(
                  label: 'Unggah File',
                  selected: !_useUrl,
                  onTap: () => setState(() { _useUrl = false; }),
                ),
                const SizedBox(width: 8),
                _ToggleChip(
                  label: 'Link URL',
                  selected: _useUrl,
                  onTap: () => setState(() { _useUrl = true; }),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── File picker OR URL field ──────────────────────────────────
            if (!_useUrl) _buildFilePicker(),
            if (_useUrl) ...[
              _buildLabel('URL Video'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _urlCtrl,
                hint: 'https://youtube.com/...',
                maxLines: 1,
              ),
            ],
            const SizedBox(height: 24),

            // ── Judul ─────────────────────────────────────────────────────
            _buildLabel('Judul (opsional)'),
            const SizedBox(height: 8),
            _buildTextField(controller: _titleCtrl, hint: 'Ketik judul video', maxLines: 1),
            const SizedBox(height: 18),

            // ── Deskripsi ─────────────────────────────────────────────────
            _buildLabel('Deskripsi (opsional)'),
            const SizedBox(height: 8),
            _buildTextField(controller: _descCtrl, hint: 'Ketik deskripsi video', maxLines: 5),
            const SizedBox(height: 32),

            // ── Submit ────────────────────────────────────────────────────
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Bagikan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    if (_videoFile != null) {
      return Stack(
        children: [
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam_rounded, color: Colors.white54, size: 48),
                const SizedBox(height: 8),
                Text(
                  _videoFile!.path.split('/').last,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            top: 8, right: 8,
            child: GestureDetector(
              onTap: _removeVideo,
              child: Container(
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickVideo,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 48, color: Color(0xFF888888)),
            SizedBox(height: 8),
            Text('Pilih Video dari Galeri', style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
    );
  }

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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPink, width: 1.5)),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? kPink : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? kPink : const Color(0xFFDDDDDD)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}
