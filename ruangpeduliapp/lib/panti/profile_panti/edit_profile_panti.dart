import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ruangpeduliapp/data/data.dart' show AuthApi;
import 'package:ruangpeduliapp/data/profile_api.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const Color kPink = Color(0xFFF28C9F);

// ─── Edit Profile Page ───────────────────────────────────────────────────────

class EditProfilePanti extends StatefulWidget {
  final int pantiId;
  final int userId;
  final PantiProfileModel initialProfile;

  const EditProfilePanti({
    super.key,
    required this.pantiId,
    required this.userId,
    required this.initialProfile,
  });

  @override
  State<EditProfilePanti> createState() => _EditProfilePantiState();
}

class _EditProfilePantiState extends State<EditProfilePanti> {
  late final TextEditingController _namaController;
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;

  late String _currentEmail;
  File? _selectedImage;
  bool _removePhoto = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _namaController    = TextEditingController(text: p.namaPanti);
    _usernameController = TextEditingController(text: p.username);
    _phoneController   = TextEditingController(text: p.nomorPanti);
    _currentEmail      = p.email;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _removePhoto = false;
      });
    }
  }

  void _removeProfilePhoto() {
    setState(() {
      _selectedImage = null;
      _removePhoto = true;
    });
  }

  Future<void> _save() async {
    final nama     = _namaController.text.trim();
    final username = _usernameController.text.trim();
    final phone    = _phoneController.text.trim();

    if (nama.isEmpty || username.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua kolom yang diperlukan')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updated = await ProfileApi().updatePantiProfile(
        widget.pantiId,
        namaPanti: nama,
        username: username,
        nomorPanti: phone,
        profilePicture: _selectedImage,
        removeProfilePicture: _removePhoto,
      );
      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── Change Password Flow ─────────────────────────────────────────────────

  Future<void> _openChangePassword() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ChangePasswordDialog(userId: widget.userId),
    );
  }

  // ─── Change Email Flow ────────────────────────────────────────────────────

  Future<void> _openChangeEmail() async {
    final newEmail = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ChangeEmailDialog(
        userId: widget.userId,
        currentEmail: _currentEmail,
      ),
    );
    if (newEmail != null && mounted) {
      setState(() => _currentEmail = newEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPicUrl = widget.initialProfile.profilePicture;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
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
            _buildAvatarPicker(currentPicUrl),
            const SizedBox(height: 32),

            _buildLabel('Nama'),
            const SizedBox(height: 8),
            _buildTextField(controller: _namaController, hint: 'Nama Panti', inputType: TextInputType.name),
            const SizedBox(height: 18),

            _buildLabel('Username'),
            const SizedBox(height: 8),
            _buildTextField(controller: _usernameController, hint: '@usernamepanti'),
            const SizedBox(height: 18),

            // ── Email (locked) ────────────────────────────────────────
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
                    color: kPink,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: kPink,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            _buildLabel('Nomor Telepon'),
            const SizedBox(height: 8),
            _buildTextField(controller: _phoneController, hint: '+62812-3456-7890', inputType: TextInputType.phone),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openChangePassword,
                icon: const Icon(Icons.lock_outline_rounded, size: 18),
                label: const Text('Ganti Kata Sandi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A1A1A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFDDDDDD)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPink,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: kPink.withValues(alpha: 0.5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Locked Email Field ───────────────────────────────────────────────────

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
                color: _currentEmail.isEmpty ? const Color(0xFFAAAAAA) : const Color(0xFF666666),
              ),
            ),
          ),
          const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFFAAAAAA)),
        ],
      ),
    );
  }

  // ─── Avatar Picker ────────────────────────────────────────────────────────

  void _showPhotoOptions(String? currentPicUrl) {
    final hasPhoto = _selectedImage != null || (currentPicUrl != null && !_removePhoto);
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

  Widget _buildAvatarPicker(String? currentPicUrl) {
    final hasPhoto = _selectedImage != null || (currentPicUrl != null && !_removePhoto);
    return Center(
      child: GestureDetector(
        onTap: () => _showPhotoOptions(currentPicUrl),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kPink, width: 2.5),
                color: Colors.grey[200],
                image: _selectedImage != null
                    ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                    : (currentPicUrl != null && !_removePhoto
                        ? DecorationImage(image: NetworkImage(currentPicUrl), fit: BoxFit.cover)
                        : null),
              ),
              child: !hasPhoto
                  ? const Icon(Icons.home_work_rounded, size: 48, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ubah foto',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kPink,
                decoration: TextDecoration.underline,
                decorationColor: kPink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType inputType = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
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
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: kPink, width: 1.5)),
      ),
    );
  }
}

// ─── Change Email Dialog (4-step) ─────────────────────────────────────────────

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
  final _newEmailController   = TextEditingController();
  final _newOtpController     = TextEditingController();
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
    final otp      = _currentOtpController.text.trim();
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
    final otpNew   = _newOtpController.text.trim();
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ganti Email', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, color: Color(0xFF888888), size: 22),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildStepIndicator(),
            const SizedBox(height: 16),
            _buildStepContent(),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            _buildActionButton(),
          ],
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
                      backgroundColor: active ? kPink : const Color(0xFFDDDDDD),
                      child: Text('${i + 1}', style: TextStyle(fontSize: 10, color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    Text(steps[i], textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: active ? kPink : Colors.grey)),
                  ],
                ),
              ),
              if (i < steps.length - 1)
                Expanded(child: Divider(color: i < currentIndex ? kPink : const Color(0xFFDDDDDD), thickness: 1.5)),
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
          const Text('Kode verifikasi akan dikirim ke email kamu saat ini:', style: TextStyle(fontSize: 13.5, color: Color(0xFF555555))),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(12)),
            child: Text(widget.currentEmail, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ]);

      case _EmailStep.verifyCurrentOtp:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Masukkan kode OTP yang dikirim ke ${widget.currentEmail}:', style: const TextStyle(fontSize: 13.5, color: Color(0xFF555555))),
          const SizedBox(height: 12),
          _buildInputField(controller: _currentOtpController, hint: '5 digit kode OTP', inputType: TextInputType.number, maxLength: 5),
          const SizedBox(height: 12),
          const Text('Masukkan email baru kamu:', style: TextStyle(fontSize: 13.5, color: Color(0xFF555555))),
          const SizedBox(height: 8),
          _buildInputField(controller: _newEmailController, hint: 'emailbaru@gmail.com', inputType: TextInputType.emailAddress),
          TextButton(
            onPressed: _loading ? null : _sendCurrentOtp,
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
            child: const Text('Kirim ulang OTP', style: TextStyle(fontSize: 13, color: kPink)),
          ),
        ]);

      case _EmailStep.enterNewEmail:
        return const SizedBox.shrink(); // merged into verifyCurrentOtp step

      case _EmailStep.verifyNewOtp:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Masukkan kode OTP yang dikirim ke ${_newEmailController.text.trim()}:', style: const TextStyle(fontSize: 13.5, color: Color(0xFF555555))),
          const SizedBox(height: 12),
          _buildInputField(controller: _newOtpController, hint: '5 digit kode OTP', inputType: TextInputType.number, maxLength: 5),
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
          backgroundColor: kPink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: kPink.withValues(alpha: 0.5),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: _loading
            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: kPink, width: 1.5)),
      ),
    );
  }
}

// ─── Change Password Dialog ────────────────────────────────────────────────────

class _ChangePasswordDialog extends StatefulWidget {
  final int userId;
  const _ChangePasswordDialog({required this.userId});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentPassController = TextEditingController();
  final _newPassController     = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _loading        = false;
  String? _error;

  final _api = AuthApi();

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = _currentPassController.text;
    final newPass = _newPassController.text;
    final confirm = _confirmPassController.text;

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
        const SnackBar(content: Text('Kata sandi berhasil diubah')),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ganti Kata Sandi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, color: Color(0xFF888888), size: 22),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Kata sandi saat ini', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 8),
            _buildPasswordField(controller: _currentPassController, hint: '••••••••', obscure: _obscureCurrent, onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent)),
            const SizedBox(height: 16),

            const Text('Kata sandi baru', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 8),
            _buildPasswordField(controller: _newPassController, hint: 'Min. 8 karakter', obscure: _obscureNew, onToggle: () => setState(() => _obscureNew = !_obscureNew)),
            const SizedBox(height: 16),

            const Text('Konfirmasi kata sandi baru', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 8),
            _buildPasswordField(controller: _confirmPassController, hint: 'Ulangi kata sandi baru', obscure: _obscureConfirm, onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm)),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPink,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: kPink.withValues(alpha: 0.5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _loading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                    : const Text('Simpan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
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
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: kPink, width: 1.5)),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.grey),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
