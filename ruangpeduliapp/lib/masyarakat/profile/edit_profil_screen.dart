import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/data/data.dart';

const Color _kPink = Color(0xFFF47B8C);

class EditProfilScreen extends StatefulWidget {
  final SocietyProfileModel? profile;
  final int? userId;

  const EditProfilScreen({super.key, this.profile, this.userId});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  late final TextEditingController _namaPenggunaCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _teleponCtrl;
  late final TextEditingController _jenisKelaminCtrl;
  late String _currentEmail;
  bool _saving = false;
  File? _pickedImage;
  bool _removePhoto = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _namaPenggunaCtrl = TextEditingController(text: p?.namaPengguna ?? '');
    _usernameCtrl = TextEditingController(text: p?.username ?? '');
    _teleponCtrl = TextEditingController(text: p?.nomorTelepon ?? '');
    _jenisKelaminCtrl = TextEditingController(text: p?.jenisKelamin ?? '');
    _currentEmail = p?.email ?? '';
  }

  @override
  void dispose() {
    _namaPenggunaCtrl.dispose();
    _usernameCtrl.dispose();
    _teleponCtrl.dispose();
    _jenisKelaminCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      setState(() {
        _pickedImage = File(picked.path);
        _removePhoto = false;
      });
    }
  }

  void _removeProfilePhoto() {
    setState(() {
      _pickedImage = null;
      _removePhoto = true;
    });
  }

  void _showPhotoOptions() {
    final hasPhoto = _pickedImage != null || (widget.profile?.profilePicture != null && !_removePhoto);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF2F2F2),
                  child: Icon(Icons.photo_library_rounded, color: Color(0xFF1A1A1A), size: 20),
                ),
                title: const Text('Ganti Foto', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              if (hasPhoto)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade50,
                    child: Icon(Icons.delete_rounded, color: Colors.red.shade500, size: 20),
                  ),
                  title: Text(
                    'Hapus Foto',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfilePhoto();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _openChangePassword() async {
    if (widget.userId == null) {
      _showError('Sesi tidak valid, silakan login ulang');
      return;
    }
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ChangePasswordDialog(
        userId: widget.userId!,
        email: _currentEmail,
      ),
    );
  }

  Future<void> _openChangeEmail() async {
    if (widget.userId == null) {
      _showError('Sesi tidak valid, silakan login ulang');
      return;
    }
    if (_currentEmail.isEmpty) {
      _showError('Email tidak ditemukan pada profil ini');
      return;
    }
    final newEmail = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ChangeEmailDialog(
        userId: widget.userId!,
        currentEmail: _currentEmail,
      ),
    );
    if (newEmail != null && mounted) {
      setState(() => _currentEmail = newEmail);
    }
  }

  Future<void> _onSimpan() async {
    final profileId = widget.profile?.id;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil tidak ditemukan'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final namaPengguna = _namaPenggunaCtrl.text.trim();

      final updated = await ProfileApi().updateMasyarakatProfile(
        profileId,
        namaPengguna: namaPengguna.isNotEmpty ? namaPengguna : null,
        alamat: widget.profile?.alamat,
        username: _usernameCtrl.text.trim().isNotEmpty ? _usernameCtrl.text.trim() : null,
        nomorTelepon: _teleponCtrl.text.trim(),
        jenisKelamin: _jenisKelaminCtrl.text.trim(),
        profilePicture: _pickedImage,
        removeProfilePicture: _removePhoto,
      );

      if (!mounted) return;
      Navigator.of(context).pop(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil berhasil diperbarui'),
          backgroundColor: _kPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ──
            Center(
              child: GestureDetector(
                onTap: _showPhotoOptions,
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _kPink, width: 2),
                        color: Colors.grey.shade200,
                      ),
                      child: ClipOval(
                        child: _pickedImage != null
                            ? Image.file(_pickedImage!, fit: BoxFit.cover)
                            : (widget.profile?.profilePicture != null && !_removePhoto
                                ? Image.network(
                                    widget.profile!.profilePicture!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.person_rounded,
                                      size: 44,
                                      color: Colors.grey.shade400,
                                    ),
                                  )
                                : Icon(
                                    Icons.person_rounded,
                                    size: 44,
                                    color: Colors.grey.shade400,
                                  )),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ubah foto',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kPink,
                        decoration: TextDecoration.underline,
                        decorationColor: _kPink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Fields ──
            _buildLabel('Nama Pengguna'),
            const SizedBox(height: 8),
            _buildTextField(controller: _namaPenggunaCtrl, hint: 'Nama lengkap'),
            const SizedBox(height: 18),

            _buildLabel('Username'),
            const SizedBox(height: 8),
            _buildTextField(controller: _usernameCtrl, hint: '@username'),
            const SizedBox(height: 18),

            // ── Email (locked) ──
            _buildLabel('Alamat Email'),
            const SizedBox(height: 8),
            _buildLockedEmailField(),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _openChangeEmail,
                child: const Text(
                  'Ganti email',
                  style: TextStyle(
                    fontSize: 13,
                    color: _kPink,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: _kPink,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            _buildLabel('Nomor Telepon'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _teleponCtrl,
              hint: '0812-3456-7890',
              inputType: TextInputType.phone,
            ),
            const SizedBox(height: 18),

            _buildLabel('Jenis Kelamin'),
            const SizedBox(height: 8),
            _buildTextField(controller: _jenisKelaminCtrl, hint: 'Laki-laki / Perempuan'),
            const SizedBox(height: 18),

            // ── Ganti Kata Sandi button ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openChangePassword,
                icon: const Icon(Icons.lock_outline_rounded, size: 18),
                label: const Text(
                  'Ganti Kata Sandi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A1A1A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFDDDDDD)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Simpan button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _onSimpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPink,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _kPink.withValues(alpha: 0.5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Simpan',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedEmailField() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _currentEmail.isEmpty ? 'Belum ada email' : _currentEmail,
              style: TextStyle(
                fontSize: 14,
                color: _currentEmail.isEmpty
                    ? const Color(0xFFAAAAAA)
                    : const Color(0xFF666666),
              ),
            ),
          ),
          const Icon(Icons.lock_outline_rounded,
              size: 16, color: Color(0xFFAAAAAA)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: _kPink, width: 1.5)),
      ),
    );
  }
}

// ── Change Email Dialog (4-step) ──────────────────────────────────────────────

enum _EmailStep { sendCurrentOtp, verifyCurrentOtp, enterNewEmail, verifyNewOtp }

class _ChangeEmailDialog extends StatefulWidget {
  final int userId;
  final String currentEmail;
  const _ChangeEmailDialog({required this.userId, required this.currentEmail});

  @override
  State<_ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<_ChangeEmailDialog> {
  _EmailStep _step = _EmailStep.sendCurrentOtp;
  final _currentOtpController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _newOtpController = TextEditingController();
  bool _loading = false;
  String? _error;
  final _api = AuthApi();

  @override
  void dispose() {
    _currentOtpController.dispose();
    _newEmailController.dispose();
    _newOtpController.dispose();
    super.dispose();
  }

  Future<void> _sendCurrentOtp() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _api.requestEmailChange(widget.userId);
      setState(() => _step = _EmailStep.verifyCurrentOtp);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendNewEmailOtp() async {
    final otp = _currentOtpController.text.trim();
    final newEmail = _newEmailController.text.trim();
    if (otp.length != 5) { setState(() => _error = 'Masukkan 5 digit kode OTP'); return; }
    if (newEmail.isEmpty || !newEmail.contains('@')) { setState(() => _error = 'Masukkan email yang valid'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await _api.requestNewEmailVerify(widget.userId, otp, newEmail);
      setState(() => _step = _EmailStep.verifyNewOtp);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmChange() async {
    final otpNew = _newOtpController.text.trim();
    final newEmail = _newEmailController.text.trim();
    if (otpNew.length != 5) { setState(() => _error = 'Masukkan 5 digit kode OTP'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      final confirmed = await _api.confirmEmailChange(widget.userId, otpNew, newEmail);
      if (!mounted) return;
      Navigator.pop(context, confirmed);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ganti Email',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A))),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded,
                      color: Color(0xFF888888), size: 22),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildStepIndicator(),
            const SizedBox(height: 16),
            _buildStepContent(),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            _buildActionButton(),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Verifikasi\nemail lama', 'Email\nbaru', 'Verifikasi\nemail baru'];
    final currentIndex = _step.index < 2 ? _step.index ~/ 1 : _step.index - 1;
    return Row(
      children: List.generate(steps.length, (i) {
        final active = i <= currentIndex;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor:
                          active ? _kPink : const Color(0xFFDDDDDD),
                      child: Text('${i + 1}',
                          style: TextStyle(
                              fontSize: 10,
                              color: active ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    Text(steps[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 9,
                            color: active ? _kPink : Colors.grey)),
                  ],
                ),
              ),
              if (i < steps.length - 1)
                Expanded(
                    child: Divider(
                        color: i < currentIndex
                            ? _kPink
                            : const Color(0xFFDDDDDD),
                        thickness: 1.5)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case _EmailStep.sendCurrentOtp:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Kode verifikasi akan dikirim ke email kamu saat ini:',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF555555))),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12)),
            child: Text(widget.currentEmail,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ]);

      case _EmailStep.verifyCurrentOtp:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              'Masukkan kode OTP yang dikirim ke ${widget.currentEmail}:',
              style: const TextStyle(
                  fontSize: 13.5, color: Color(0xFF555555))),
          const SizedBox(height: 12),
          _buildInputField(
              controller: _currentOtpController,
              hint: '5 digit kode OTP',
              inputType: TextInputType.number,
              maxLength: 5),
          const SizedBox(height: 12),
          const Text('Masukkan email baru kamu:',
              style:
                  TextStyle(fontSize: 13.5, color: Color(0xFF555555))),
          const SizedBox(height: 8),
          _buildInputField(
              controller: _newEmailController,
              hint: 'emailbaru@gmail.com',
              inputType: TextInputType.emailAddress),
          TextButton(
            onPressed: _loading ? null : _sendCurrentOtp,
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero, minimumSize: Size.zero),
            child: const Text('Kirim ulang OTP',
                style: TextStyle(fontSize: 13, color: _kPink)),
          ),
        ]);

      case _EmailStep.enterNewEmail:
        return const SizedBox.shrink();

      case _EmailStep.verifyNewOtp:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              'Masukkan kode OTP yang dikirim ke ${_newEmailController.text.trim()}:',
              style: const TextStyle(
                  fontSize: 13.5, color: Color(0xFF555555))),
          const SizedBox(height: 12),
          _buildInputField(
              controller: _newOtpController,
              hint: '5 digit kode OTP',
              inputType: TextInputType.number,
              maxLength: 5),
        ]);
    }
  }

  Widget _buildActionButton() {
    String label;
    VoidCallback? onTap;
    switch (_step) {
      case _EmailStep.sendCurrentOtp:
        label = 'Kirim Kode OTP';
        onTap = _loading ? null : _sendCurrentOtp;
        break;
      case _EmailStep.verifyCurrentOtp:
      case _EmailStep.enterNewEmail:
        label = 'Kirim OTP ke Email Baru';
        onTap = _loading ? null : _sendNewEmailOtp;
        break;
      case _EmailStep.verifyNewOtp:
        label = 'Simpan Email Baru';
        onTap = _loading ? null : _confirmChange;
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _kPink.withValues(alpha: 0.5),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: _loading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white)))
            : Text(label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType inputType = TextInputType.text,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: _kPink, width: 1.5)),
      ),
    );
  }
}

// ── Change Password Dialog ────────────────────────────────────────────────────

enum _PassMode { change, forgotSendOtp, forgotReset }

class _ChangePasswordDialog extends StatefulWidget {
  final int userId;
  final String email;
  const _ChangePasswordDialog({required this.userId, required this.email});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  // ── change mode controllers ──
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // ── forgot mode controllers ──
  final _otpCtrl = TextEditingController();
  final _resetNewPassCtrl = TextEditingController();
  final _resetConfirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _obscureResetNew = true;
  bool _obscureResetConfirm = true;

  _PassMode _mode = _PassMode.change;
  bool _loading = false;
  String? _error;

  final _api = AuthApi();

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _otpCtrl.dispose();
    _resetNewPassCtrl.dispose();
    _resetConfirmCtrl.dispose();
    super.dispose();
  }

  // ── change password ──────────────────────────────────────────────────────
  Future<void> _saveChange() async {
    final current = _currentPassCtrl.text;
    final newPass = _newPassCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Semua kolom wajib diisi');
      return;
    }
    if (newPass.length < 8) {
      setState(() => _error = 'Kata sandi baru minimal 8 karakter');
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = 'Konfirmasi kata sandi tidak cocok');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await _api.changePassword(widget.userId, current, newPass);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kata sandi berhasil diubah'),
          backgroundColor: _kPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── forgot: send OTP ─────────────────────────────────────────────────────
  Future<void> _sendForgotOtp() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _api.forgotPassword(widget.email);
      setState(() => _mode = _PassMode.forgotReset);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── forgot: reset with OTP ───────────────────────────────────────────────
  Future<void> _resetPassword() async {
    final otp = _otpCtrl.text.trim();
    final newPass = _resetNewPassCtrl.text;
    final confirm = _resetConfirmCtrl.text;

    if (otp.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Semua kolom wajib diisi');
      return;
    }
    if (newPass.length < 8) {
      setState(() => _error = 'Kata sandi baru minimal 8 karakter');
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = 'Konfirmasi kata sandi tidak cocok');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await _api.resetPassword(widget.email, otp, newPass);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kata sandi berhasil direset'),
          backgroundColor: _kPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_mode != _PassMode.change)
                    GestureDetector(
                      onTap: () => setState(() { _mode = _PassMode.change; _error = null; }),
                      child: const Icon(Icons.arrow_back_rounded,
                          size: 20, color: Color(0xFF888888)),
                    )
                  else
                    const SizedBox(width: 20),
                  Text(
                    _mode == _PassMode.change ? 'Ganti Kata Sandi' : 'Lupa Kata Sandi',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded,
                        color: Color(0xFF888888), size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Body by mode ──
              if (_mode == _PassMode.change) ...[
                const Text('Kata sandi saat ini',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 8),
                _buildPasswordField(
                    controller: _currentPassCtrl,
                    hint: '••••••••',
                    obscure: _obscureCurrent,
                    onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent)),
                const SizedBox(height: 4),

                // Lupa kata sandi link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() { _mode = _PassMode.forgotSendOtp; _error = null; }),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text(
                      'Lupa kata sandi?',
                      style: TextStyle(fontSize: 13, color: _kPink, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                const Text('Kata sandi baru',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 8),
                _buildPasswordField(
                    controller: _newPassCtrl,
                    hint: 'Min. 8 karakter',
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew)),
                const SizedBox(height: 16),

                const Text('Konfirmasi kata sandi baru',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 8),
                _buildPasswordField(
                    controller: _confirmPassCtrl,
                    hint: 'Ulangi kata sandi baru',
                    obscure: _obscureConfirm,
                    onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm)),
              ] else if (_mode == _PassMode.forgotSendOtp) ...[
                const Text(
                  'Kode OTP akan dikirim ke email kamu:',
                  style: TextStyle(fontSize: 13.5, color: Color(0xFF555555)),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(widget.email,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                const SizedBox(height: 8),
              ] else ...[
                // forgotReset
                Text(
                  'Masukkan kode OTP yang dikirim ke ${widget.email}:',
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF555555)),
                ),
                const SizedBox(height: 12),
                _buildOtpField(),
                const SizedBox(height: 16),

                const Text('Kata sandi baru',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 8),
                _buildPasswordField(
                    controller: _resetNewPassCtrl,
                    hint: 'Min. 8 karakter',
                    obscure: _obscureResetNew,
                    onToggle: () => setState(() => _obscureResetNew = !_obscureResetNew)),
                const SizedBox(height: 16),

                const Text('Konfirmasi kata sandi baru',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 8),
                _buildPasswordField(
                    controller: _resetConfirmCtrl,
                    hint: 'Ulangi kata sandi baru',
                    obscure: _obscureResetConfirm,
                    onToggle: () => setState(() => _obscureResetConfirm = !_obscureResetConfirm)),

                // Resend OTP
                TextButton(
                  onPressed: _loading ? null : _sendForgotOtp,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                  child: const Text('Kirim ulang OTP',
                      style: TextStyle(fontSize: 13, color: _kPink)),
                ),
              ],

              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : (_mode == _PassMode.change
                          ? _saveChange
                          : _mode == _PassMode.forgotSendOtp
                              ? _sendForgotOtp
                              : _resetPassword),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPink,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _kPink.withValues(alpha: 0.5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : Text(
                          _mode == _PassMode.change
                              ? 'Simpan'
                              : _mode == _PassMode.forgotSendOtp
                                  ? 'Kirim Kode OTP'
                                  : 'Reset Kata Sandi',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField() {
    return TextField(
      controller: _otpCtrl,
      keyboardType: TextInputType.number,
      maxLength: 5,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: '5 digit kode OTP',
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: _kPink, width: 1.5)),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: _kPink, width: 1.5)),
        suffixIcon: IconButton(
          icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: Colors.grey),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
