import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';
import 'package:ruangpeduliapp/data/data.dart';
import 'package:ruangpeduliapp/auth/verification_screen.dart';
import 'package:ruangpeduliapp/auth/success_screen.dart';

class FillDataMasyarakatScreen extends StatefulWidget {
  final String email;
  final String password;
  final String? googleIdToken; // non-null → Google mode (skip OTP)

  const FillDataMasyarakatScreen({
    super.key,
    required this.email,
    required this.password,
    this.googleIdToken,
  });

  @override
  State<FillDataMasyarakatScreen> createState() =>
      _FillDataMasyarakatScreenState();
}

class _FillDataMasyarakatScreenState extends State<FillDataMasyarakatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final _namaPenggunaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nomorTeleponController = TextEditingController();
  bool _agreeTnC = true;
  String? _namaPenggunaError;
  String? _alamatError;
  String? _usernameError;
  String? _nomorTeleponError;
  String? _tncError;
  String? _generalError;

  final _api = AuthApi();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _namaPenggunaController.dispose();
    _alamatController.dispose();
    _usernameController.dispose();
    _nomorTeleponController.dispose();
    super.dispose();
  }

  void _onSelanjutnya() {
    final namaErr = _namaPenggunaController.text.isEmpty ? 'Wajib diisi' : null;
    final alamatErr = _alamatController.text.isEmpty ? 'Wajib diisi' : null;
    final username = _usernameController.text.trim();
    final usernameErr = username.isEmpty
        ? 'Wajib diisi'
        : (!RegExp(r'[a-zA-Z]').hasMatch(username) || !RegExp(r'\d').hasMatch(username))
            ? 'Username harus mengandung huruf dan angka'
            : null;
    final teleponErr = _nomorTeleponController.text.trim().isEmpty ? 'Wajib diisi' : null;
    final tncErr = !_agreeTnC ? 'Anda harus menyetujui S&K terlebih dahulu' : null;

    setState(() {
      _namaPenggunaError = namaErr;
      _alamatError = alamatErr;
      _usernameError = usernameErr;
      _nomorTeleponError = teleponErr;
      _tncError = tncErr;
      _generalError = null;
    });

    if (namaErr != null || alamatErr != null || usernameErr != null || teleponErr != null || tncErr != null) return;

    setState(() => _loading = true);

    if (widget.googleIdToken != null) {
      // Google mode — register directly, no OTP
      _api.googleRegister(
        idToken: widget.googleIdToken!,
        role: 'masyarakat',
        username: username,
        namaPengguna: _namaPenggunaController.text.trim(),
        alamat: _alamatController.text.trim(),
        nomorTelepon: _nomorTeleponController.text.trim().replaceAll('-', ''),
      ).then((_) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SuccessScreen(role: 'masyarakat')),
          (route) => false,
        );
      }).catchError((e) {
        if (!mounted) return;
        setState(() => _generalError = '$e');
      }).whenComplete(() {
        if (mounted) setState(() => _loading = false);
      });
    } else {
      _api.startRegister(RegisterData(
        username: username,
        email: widget.email,
        password: widget.password,
        role: 'masyarakat',
        namaPengguna: _namaPenggunaController.text.trim(),
        alamat: _alamatController.text.trim(),
        nomorTelepon: _nomorTeleponController.text.trim().replaceAll('-', ''),
      )).then((pendingId) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationScreen(
              pendingId: pendingId,
              email: widget.email,
            ),
          ),
        );
      }).catchError((e) {
        if (!mounted) return;
        setState(() => _generalError = '$e');
      }).whenComplete(() {
        if (mounted) setState(() => _loading = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFA5B1),
                  Color(0xFFF47B8C),
                  Color(0xFFF43D5E),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Wave
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: size.height * 0.78,
              width: size.width,
              child: CustomPaint(painter: _MasyarakatWavePainter()),
            ),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 8),
                      child: AuthBackButton(),
                    ),
                    SizedBox(height: size.height * 0.16),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            const Text('Isi Data',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A1A1A))),
                            const SizedBox(height: 28),

                            // Nama Pengguna
                            _FieldLabel('Nama Pengguna'),
                            const SizedBox(height: 8),
                            _RoundedInput(
                              controller: _namaPenggunaController,
                              hint: 'Contoh: Sienna Malik',
                              errorText: _namaPenggunaError,
                              onChanged: (_) => setState(() => _namaPenggunaError = null),
                            ),
                            const SizedBox(height: 20),

                            // Alamat
                            _FieldLabel('Alamat'),
                            const SizedBox(height: 8),
                            _RoundedInput(
                              controller: _alamatController,
                              hint: 'Contoh: Jalan Sudirman 123',
                              errorText: _alamatError,
                              onChanged: (_) => setState(() => _alamatError = null),
                            ),
                            const SizedBox(height: 20),

                            // Username
                            _FieldLabel('Username'),
                            const SizedBox(height: 8),
                            _RoundedInput(
                              controller: _usernameController,
                              hint: 'Contoh: sunshinebecomesyou14',
                              errorText: _usernameError,
                              onChanged: (_) => setState(() => _usernameError = null),
                            ),
                            const SizedBox(height: 20),

                            // Nomor Telepon
                            _FieldLabel('Nomor Telepon'),
                            const SizedBox(height: 8),
                            _RoundedInput(
                              controller: _nomorTeleponController,
                              hint: 'Contoh: 0812-3456-7890',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[\d-]')),
                                _PhoneFormatter(),
                              ],
                              errorText: _nomorTeleponError,
                              onChanged: (_) => setState(() => _nomorTeleponError = null),
                            ),
                            const SizedBox(height: 28),

                            // Syarat dan Ketentuan
                            const Text('Syarat dan Ketentuan',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A1A))),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _agreeTnC,
                                    onChanged: (val) => setState(
                                        () => _agreeTnC = val ?? false),
                                    activeColor: const Color(0xFF2C2C2C),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          height: 1.5),
                                      children: const [
                                        TextSpan(
                                            text:
                                                'Saya mengakui telah membaca dan menyetujui Syarat & Ketentuan dan Kebijakan Ruang Peduli. '),
                                        TextSpan(
                                          text: 'Baca selengkapnya.',
                                          style: TextStyle(
                                            color: Color(0xFFF43D5E),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_tncError != null)
                              InlineMessage(message: _tncError),
                            const SizedBox(height: 24),

                            InlineMessage(message: _generalError),
                            if (_generalError != null) const SizedBox(height: 8),

                            Center(
                              child: SizedBox(
                                width: size.width * 0.55,
                                child: DarkButton(
                                  label: _loading ? 'Memproses...' : 'Sign Up',
                                  onTap: _loading ? () {} : _onSelanjutnya,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A)));
  }
}

// ── Phone number formatter: 0812-3456-7890 ──
class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll('-', '');
    if (digits.isEmpty) return next.copyWith(text: '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 13; i++) {
      if (i == 4 || i == 8) buffer.write('-');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return next.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _RoundedInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;

  const _RoundedInput({
    required this.controller,
    required this.hint,
    this.errorText,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF0E8EA),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? const Color(0xFFF43D5E) : const Color(0xFFF43D5E),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: Color(0xFFF43D5E), width: 1.5)
                  : BorderSide.none,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 13, color: Color(0xFFF43D5E)),
              const SizedBox(width: 4),
              Text(
                errorText!,
                style: const TextStyle(fontSize: 12, color: Color(0xFFF43D5E)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _MasyarakatWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBack = Paint()
      ..color = Colors.white.withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;

    final pathBack = Path()
      ..moveTo(0, size.height * 0.12)
      ..quadraticBezierTo(size.width * 0.20, size.height * 0.01,
          size.width * 0.50, size.height * 0.08)
      ..quadraticBezierTo(
          size.width * 0.80, size.height * 0.15, size.width, size.height * 0.06)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathBack, paintBack);

    final paintFront = Paint()
      ..color = const Color(0xFFFFF0F2)
      ..style = PaintingStyle.fill;

    final pathFront = Path()
      ..moveTo(0, size.height * 0.20)
      ..quadraticBezierTo(size.width * 0.22, size.height * 0.07,
          size.width * 0.50, size.height * 0.14)
      ..quadraticBezierTo(
          size.width * 0.78, size.height * 0.21, size.width, size.height * 0.12)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathFront, paintFront);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
