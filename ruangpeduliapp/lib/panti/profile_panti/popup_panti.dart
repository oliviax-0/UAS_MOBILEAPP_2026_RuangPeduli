import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const Color kPink = Color(0xFFF28C9F);

// ─── Public helpers ───────────────────────────────────────────────────────────

/// Returns the saved alamat string, or null if cancelled.
Future<String?> showAlamatPopup(
  BuildContext context, {
  required int pantiId,
  String initialValue = '',
}) {
  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => _AlamatDialog(pantiId: pantiId, initialValue: initialValue),
  );
}

/// Returns the saved deskripsi string, or null if cancelled.
Future<String?> showDeskripsiPopup(
  BuildContext context, {
  required int pantiId,
  String initialValue = '',
}) {
  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) =>
        _DeskripsiDialog(pantiId: pantiId, initialValue: initialValue),
  );
}

/// Returns the updated photo list, or null if cancelled.
Future<List<PantiMediaModel>?> showFotoPopup(
  BuildContext context, {
  required int pantiId,
  required List<PantiMediaModel> media,
}) {
  return showDialog<List<PantiMediaModel>>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => _FotoVideoDialog(pantiId: pantiId, initialMedia: media, videoOnly: false),
  );
}

/// Returns the updated video list, or null if cancelled.
Future<List<PantiMediaModel>?> showVideoPopup(
  BuildContext context, {
  required int pantiId,
  required List<PantiMediaModel> media,
}) {
  return showDialog<List<PantiMediaModel>>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => _FotoVideoDialog(pantiId: pantiId, initialMedia: media, videoOnly: true),
  );
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _PopupShell extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback onSave;
  final bool isSaving;

  const _PopupShell({
    required this.title,
    required this.content,
    required this.onSave,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final maxHeight = mq.size.height - mq.viewInsets.bottom - 80;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            content,
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPink,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: kPink.withValues(alpha: 0.5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
        ), // SingleChildScrollView
      ),   // ConstrainedBox
    );
  }
}

Widget _buildMultilineField({
  required TextEditingController controller,
  required String hint,
  int maxLines = 7,
}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF2F2F2),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFDDDDDD)),
    ),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13.5, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13.5),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(14),
      ),
    ),
  );
}

// ─── Alamat Dialog ────────────────────────────────────────────────────────────

class _AlamatDialog extends StatefulWidget {
  final int pantiId;
  final String initialValue;
  const _AlamatDialog({required this.pantiId, this.initialValue = ''});

  @override
  State<_AlamatDialog> createState() => _AlamatDialogState();
}

class _AlamatDialogState extends State<_AlamatDialog> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    setState(() => _isSaving = true);
    try {
      await ProfileApi().updatePantiProfile(
        widget.pantiId,
        alamatPanti: value,
      );
      if (!mounted) return;
      Navigator.pop(context, value);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PopupShell(
      title: 'Alamat',
      isSaving: _isSaving,
      content: _buildMultilineField(
        controller: _controller,
        hint: 'Masukkan alamat panti...',
        maxLines: 6,
      ),
      onSave: _save,
    );
  }
}

// ─── Deskripsi Dialog ─────────────────────────────────────────────────────────

class _DeskripsiDialog extends StatefulWidget {
  final int pantiId;
  final String initialValue;
  const _DeskripsiDialog({required this.pantiId, this.initialValue = ''});

  @override
  State<_DeskripsiDialog> createState() => _DeskripsiDialogState();
}

class _DeskripsiDialogState extends State<_DeskripsiDialog> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    setState(() => _isSaving = true);
    try {
      await ProfileApi().updatePantiProfile(
        widget.pantiId,
        description: value,
      );
      if (!mounted) return;
      Navigator.pop(context, value);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PopupShell(
      title: 'Deskripsi',
      isSaving: _isSaving,
      content: _buildMultilineField(
        controller: _controller,
        hint: 'Tulis deskripsi panti...',
        maxLines: 7,
      ),
      onSave: _save,
    );
  }
}

// ─── Foto & Video Dialog ──────────────────────────────────────────────────────

class _FotoVideoDialog extends StatefulWidget {
  final int pantiId;
  final List<PantiMediaModel> initialMedia;
  final bool videoOnly;
  const _FotoVideoDialog({
    required this.pantiId,
    required this.initialMedia,
    this.videoOnly = false,
  });

  @override
  State<_FotoVideoDialog> createState() => _FotoVideoDialogState();
}

class _FotoVideoDialogState extends State<_FotoVideoDialog> {
  late List<PantiMediaModel> _media;
  bool _isUploading = false;

  // Video form fields
  bool _useUrl = false;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _media = List.from(widget.initialMedia);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _isUploading = true);
    try {
      final newMedia = await ProfileApi().uploadPantiMedia(
        widget.pantiId,
        file: File(picked.path),
        mediaType: 'photo',
        order: _media.length,
      );
      setState(() => _media.add(newMedia));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _submitVideo() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (_useUrl) {
      final url = _urlCtrl.text.trim();
      if (url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan URL video terlebih dahulu')),
        );
        return;
      }
      setState(() => _isUploading = true);
      try {
        final newMedia = await ProfileApi().uploadPantiMedia(
          widget.pantiId,
          videoUrl: url,
          mediaType: 'video',
          order: _media.length,
          title: title,
          description: desc,
        );
        setState(() {
          _media.add(newMedia);
          _titleCtrl.clear();
          _descCtrl.clear();
          _urlCtrl.clear();
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    } else {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickVideo(source: ImageSource.gallery);
      if (picked == null) return;
      setState(() => _isUploading = true);
      try {
        final newMedia = await ProfileApi().uploadPantiMedia(
          widget.pantiId,
          file: File(picked.path),
          mediaType: 'video',
          order: _media.length,
          title: title,
          description: desc,
        );
        setState(() {
          _media.add(newMedia);
          _titleCtrl.clear();
          _descCtrl.clear();
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _delete(PantiMediaModel item) async {
    try {
      await ProfileApi().deletePantiMedia(widget.pantiId, item.id);
      setState(() => _media.removeWhere((m) => m.id == item.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _buildVideoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormField(_titleCtrl, 'Judul video (opsional)', maxLines: 1),
        const SizedBox(height: 8),
        _buildFormField(_descCtrl, 'Deskripsi (opsional)', maxLines: 2),
        const SizedBox(height: 10),
        // Toggle: Unggah File / Link URL
        Row(
          children: [
            _ToggleChip(
              label: 'Unggah File',
              selected: !_useUrl,
              onTap: () => setState(() => _useUrl = false),
            ),
            const SizedBox(width: 8),
            _ToggleChip(
              label: 'Link URL',
              selected: _useUrl,
              onTap: () => setState(() => _useUrl = true),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_useUrl)
          _buildFormField(_urlCtrl, 'https://youtube.com/...', maxLines: 1),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isUploading ? null : _submitVideo,
            icon: Icon(_useUrl ? Icons.link_rounded : Icons.videocam_rounded, size: 18),
            label: Text(
              _useUrl ? 'Tambah Link' : 'Pilih & Unggah',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPink.withValues(alpha: 0.18),
              foregroundColor: const Color(0xFFD0607A),
              disabledBackgroundColor: kPink.withValues(alpha: 0.08),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _PopupShell(
      title: widget.videoOnly ? 'Video' : 'Foto',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.videoOnly)
            _buildVideoForm()
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickAndUpload,
                icon: const Icon(Icons.photo_rounded, size: 18),
                label: const Text(
                  'Unggah Foto',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPink.withValues(alpha: 0.18),
                  foregroundColor: const Color(0xFFD0607A),
                  disabledBackgroundColor: kPink.withValues(alpha: 0.08),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          if (_isUploading) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kPink),
              backgroundColor: Color(0xFFFFE0E6),
            ),
          ],
          const SizedBox(height: 14),
          if (_media.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                widget.videoOnly ? 'Belum ada video.' : 'Belum ada foto.',
                style: TextStyle(fontSize: 13.5, color: Colors.grey[500]),
              ),
            )
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: _media
                  .map((item) => _MediaTile(
                        item: item,
                        onDelete: () => _delete(item),
                      ))
                  .toList(),
            ),
        ],
      ),
      onSave: () => Navigator.pop(context, _media),
    );
  }
}

Widget _buildFormField(
  TextEditingController controller,
  String hint, {
  int maxLines = 1,
}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF2F2F2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFDDDDDD)),
    ),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13.5, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13.5),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    ),
  );
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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

class _MediaTile extends StatelessWidget {
  final PantiMediaModel item;
  final VoidCallback onDelete;
  const _MediaTile({required this.item, required this.onDelete});

  Future<void> _openVideo() async {
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
      onTap: item.isVideo ? _openVideo : null,
      child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background: video placeholder OR photo
          if (item.isVideo)
            Container(
              color: const Color(0xFF1A1A2E),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_rounded, color: Colors.white54, size: 36),
                  SizedBox(height: 4),
                  Text(
                    'Video',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            )
          else if (item.file != null)
            Image.network(
              item.file!,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Container(
                      color: const Color(0xFFE0E0E0),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(kPink),
                        ),
                      ),
                    ),
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFE0E0E0),
                child: const Icon(Icons.broken_image_outlined,
                    color: Colors.grey),
              ),
            )
          else
            Container(
              color: const Color(0xFFE0E0E0),
              child: const Icon(Icons.image_not_supported_outlined,
                  color: Colors.grey),
            ),
          // Play overlay for video
          if (item.isVideo)
            const Center(
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white24,
                child: Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 26),
              ),
            ),
          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
