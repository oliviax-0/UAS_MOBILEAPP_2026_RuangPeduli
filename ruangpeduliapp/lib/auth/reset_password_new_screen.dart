import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';
import 'package:ruangpeduliapp/auth/login_screen.dart';
import 'package:ruangpeduliapp/data/data.dart';

class ResetPasswordNewScreen extends StatefulWidget {
  final String email;
  final String otp;
  final String role;

  const ResetPasswordNewScreen({
    super.key,
    required this.email,
    required this.otp,
    required this.role,
  });

  @override
  State<ResetPasswordNewScreen> createState() => _ResetPasswordNewScreenState();
}

class _ResetPasswordNewScreenState extends State<ResetPasswordNewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _api = AuthApi();
  bool _loading = false;
  String? _passwordError;
  String? _confirmError;
  String? _generalError;

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
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onReset() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    String? passErr;
    String? confirmErr;

    if (password.isEmpty) {
      passErr = 'Sandi wajib diisi';
    } else if (password.length < 6) {
      passErr = 'Sandi minimal 6 karakter';
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      passErr = 'Sandi harus mengandung minimal 1 huruf kapital';
    } else if (!RegExp(r'\d').hasMatch(password)) {
      passErr = 'Sandi harus mengandung minimal 1 angka';
    }

    if (confirm.isEmpty) {
      confirmErr = 'Konfirmasi sandi wajib diisi';
    } else if (passErr == null && confirm != password) {
      confirmErr = 'Sandi tidak cocok';
    }

    setState(() {
      _passwordError = passErr;
      _confirmError = confirmErr;
    });

    if (passErr != null || confirmErr != null) return;

    setState(() => _loading = true);

    try {
      await _api.resetPassword(widget.email, widget.otp, password);
      if (!mounted) return;

      // Pop back to login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen(role: widget.role)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _generalError = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AuthBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 8),
                      child: AuthBackButton(),
                    ),

                    SizedBox(height: size.height * 0.35),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),

                          const Text(
                            'Sandi Baru',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Buat sandi baru untuk akun kamu.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 32),

                          UnderlineField(
                            label: 'Sandi Baru',
                            hint: 'Min. 6 karakter, 1 kapital, 1 angka',
                            obscure: true,
                            controller: _passwordController,
                            errorText: _passwordError,
                            onChanged: (_) => setState(() => _passwordError = null),
                          ),
                          const SizedBox(height: 24),

                          UnderlineField(
                            label: 'Konfirmasi Sandi',
                            hint: 'Ulangi sandi baru',
                            obscure: true,
                            controller: _confirmController,
                            errorText: _confirmError,
                            onChanged: (_) => setState(() => _confirmError = null),
                          ),
                          const SizedBox(height: 24),

                          InlineMessage(message: _generalError),
                          if (_generalError != null) const SizedBox(height: 8),

                          Center(
                            child: SizedBox(
                              width: size.width * 0.58,
                              child: DarkButton(
                                label: _loading ? 'Memproses...' : 'Reset Sandi',
                                onTap: _loading ? () {} : _onReset,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
