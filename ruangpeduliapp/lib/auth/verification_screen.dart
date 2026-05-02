// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';
import 'package:ruangpeduliapp/auth/success_screen.dart';
import 'package:ruangpeduliapp/data/data.dart';

class VerificationScreen extends StatefulWidget {
  final String pendingId;
  final String email;
  final String role;

  const VerificationScreen({
    super.key,
    required this.pendingId,
    required this.email,
    this.role = 'masyarakat',
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  // Single hidden TextField — keyboard stays open without animation between digits
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  final _authApi = AuthApi();
  bool _loading = false;
  bool _resendLoading = false;

  int _countdown = 60;
  Timer? _timer;
  bool get _canResend => _countdown == 0;

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
    _startCountdown();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        if (_countdown > 0) { _countdown--; } else { timer.cancel(); }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  String? _otpError;
  String? _otpSuccess;

  void _showSnackBar(String message, {bool isError = false}) {
    setState(() {
      if (isError) { _otpError = message; _otpSuccess = null; }
      else { _otpSuccess = message; _otpError = null; }
    });
  }

  // ─── VERIFY OTP ────────────────────────────────────────────────────
  Future<void> _onVerify() async {
    final otp = _otpController.text;

    if (otp.length != 5) {
      _showSnackBar('Kode OTP harus 5 digit', isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await _authApi.verifyOtp(widget.pendingId, otp);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessScreen(
            role: widget.role,
            userId: result['user_id'] as int?,
            pantiId: result['panti_id'] as int?,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      print('❌ Verify OTP error: $e');
      _showSnackBar('$e', isError: true);
      _otpController.clear();
      _otpFocusNode.requestFocus();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── RESEND OTP ─────────────────────────────────────────────────────
  Future<void> _onResend() async {
    if (!_canResend || _resendLoading) return;

    setState(() => _resendLoading = true);

    try {
      await _authApi.resendOtp(widget.email);
      if (!mounted) return;

      _otpController.clear();
      _otpFocusNode.requestFocus();
      _startCountdown();

      _showSnackBar('OTP baru telah dikirim ke email kamu');
    } catch (e) {
      if (!mounted) return;
      print('❌ Resend OTP error: $e');
      _showSnackBar('Gagal kirim ulang OTP: $e', isError: true);
    } finally {
      if (mounted) setState(() => _resendLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Gradient background
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
              height: size.height * 0.85,
              width: size.width,
              child: CustomPaint(painter: _VerifWavePainter()),
            ),
          ),

          // Hidden TextField — captures all input, keeps keyboard static
          Opacity(
            opacity: 0,
            child: SizedBox(
              width: 0,
              height: 0,
              child: TextField(
                controller: _otpController,
                focusNode: _otpFocusNode,
                keyboardType: TextInputType.number,
                maxLength: 5,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (val) {
                  setState(() {});
                  if (val.length == 5) {
                    _otpFocusNode.unfocus();
                  }
                },
              ),
            ),
          ),

          // Konten
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
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: size.height * 0.22),

                            const Text(
                              'Verifikasi',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 16),

                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                                children: [
                                  const TextSpan(
                                    text: 'Masukkan kode 5 digit yang sudah dikirimkan\npada email ',
                                  ),
                                  TextSpan(
                                    text: widget.email,
                                    style: const TextStyle(
                                      color: Color(0xFFF43D5E),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),

                            // 5 OTP display boxes
                            GestureDetector(
                              onTap: () => _otpFocusNode.requestFocus(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(5, (i) => _buildOtpBox(i)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            InlineMessage(message: _otpError),
                            InlineMessage(message: _otpSuccess, isError: false),
                            const SizedBox(height: 24),

                            // Resend OTP
                            Center(
                              child: _resendLoading
                                  ? const SizedBox(
                                      height: 20, width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFF43D5E),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: _canResend ? _onResend : null,
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(fontSize: 13),
                                          children: [
                                            TextSpan(
                                              text: 'Tidak menerima kode? ',
                                              style: TextStyle(color: Colors.grey.shade500),
                                            ),
                                            TextSpan(
                                              text: _canResend
                                                  ? 'Kirim ulang'
                                                  : 'Kirim ulang ($_countdown)',
                                              style: TextStyle(
                                                color: _canResend
                                                    ? const Color(0xFFF43D5E)
                                                    : Colors.grey.shade400,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 32),

                            // Tombol Verifikasi
                            Center(
                              child: SizedBox(
                                width: size.width * 0.55,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A1A1A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _loading ? null : _onVerify,
                                  child: _loading
                                      ? const SizedBox(
                                          height: 18, width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Verifikasi',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
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

  Widget _buildOtpBox(int index) {
    final otp = _otpController.text;
    final char = index < otp.length ? otp[index] : '';
    final isFocused = _otpFocusNode.hasFocus && index == otp.length.clamp(0, 4);

    return Container(
      width: 58,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF0E8EA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFocused ? const Color(0xFFF43D5E) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Text(
        char,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}

class _VerifWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBack = Paint()
      ..color = Colors.white.withOpacity(0.40)
      ..style = PaintingStyle.fill;

    final pathBack = Path()
      ..moveTo(0, size.height * 0.10)
      ..quadraticBezierTo(size.width * 0.20, size.height * 0.01,
          size.width * 0.50, size.height * 0.07)
      ..quadraticBezierTo(size.width * 0.80, size.height * 0.13,
          size.width, size.height * 0.05)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathBack, paintBack);

    final paintFront = Paint()
      ..color = const Color(0xFFFFF0F2)
      ..style = PaintingStyle.fill;

    final pathFront = Path()
      ..moveTo(0, size.height * 0.17)
      ..quadraticBezierTo(size.width * 0.22, size.height * 0.06,
          size.width * 0.50, size.height * 0.12)
      ..quadraticBezierTo(size.width * 0.78, size.height * 0.18,
          size.width, size.height * 0.10)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathFront, paintFront);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
