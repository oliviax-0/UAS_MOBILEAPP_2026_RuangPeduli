import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';
import 'package:ruangpeduliapp/data/data.dart';
import 'package:ruangpeduliapp/auth/fill_data_masyarakat_screen.dart';
import 'package:ruangpeduliapp/auth/fill_data_panti_screen.dart';

// ignore_for_file: use_build_context_synchronously

class SignUpScreen extends StatefulWidget {
  final String role;
  const SignUpScreen({super.key, required this.role});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _namaPenggunaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _namaPantiController = TextEditingController();
  final _alamatPantiController = TextEditingController();
  final _nomorPantiController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _googleError;
  bool _googleLoading = false;

  final api = AuthApi();

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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _namaPenggunaController.dispose();
    _alamatController.dispose();
    _namaPantiController.dispose();
    _alamatPantiController.dispose();
    _nomorPantiController.dispose();
    super.dispose();
  }

  Future<void> _onGoogleSignUp() async {
    final backendRole = widget.role == 'Panti Sosial' ? 'panti' : 'masyarakat';
    setState(() { _googleLoading = true; _googleError = null; });
    try {
      final idToken = await GoogleSignInService.signIn();
      if (idToken == null) return; // user cancelled

      final result = await api.googleAuth(idToken, backendRole);

      if (!mounted) return;

      if (result['exists'] == true) {
        setState(() => _googleError = 'Akun Google ini sudah terdaftar, silahkan login');
        return;
      }

      final email = result['email'] as String? ?? '';
      if (backendRole == 'panti') {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => FillDataPantiScreen(
            email: email,
            password: '',
            googleIdToken: idToken,
          ),
        ));
      } else {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => FillDataMasyarakatScreen(
            email: email,
            password: '',
            googleIdToken: idToken,
          ),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _googleError = '$e');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return 'Sandi wajib diisi';
    if (password.length < 6) return 'Sandi minimal 6 karakter';
    if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Sandi harus mengandung minimal 1 huruf kapital';
    if (!RegExp(r'\d').hasMatch(password)) return 'Sandi harus mengandung minimal 1 angka';
    return null;
  }

  void _onSignUp() {
    final emailErr = _emailController.text.isEmpty ? 'Email wajib diisi' : null;
    final passErr = _validatePassword(_passwordController.text);
    final confirmErr = _confirmPasswordController.text.isEmpty
        ? 'Konfirmasi sandi wajib diisi'
        : passErr == null && _confirmPasswordController.text != _passwordController.text
            ? 'Sandi tidak cocok'
            : null;

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
      _confirmPasswordError = confirmErr;
    });

    if (emailErr != null || passErr != null || confirmErr != null) return;

    if (widget.role == 'Panti Sosial') {
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => FillDataPantiScreen(
          email: _emailController.text,
          password: _passwordController.text,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ));
    } else {
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => FillDataMasyarakatScreen(
          email: _emailController.text,
          password: _passwordController.text,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ));
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
                    SizedBox(height: size.height * 0.38),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          const Text('Sign Up',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 4),
                          Text(widget.role,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.teal)),
                          const SizedBox(height: 32),
                          UnderlineField(
                            label: 'Email',
                            hint: 'Masukan Email',
                            controller: _emailController,
                            errorText: _emailError,
                            onChanged: (_) => setState(() => _emailError = null),
                          ),
                          const SizedBox(height: 24),
                          UnderlineField(
                            label: 'Sandi',
                            hint: 'Min. 6 karakter, 1 kapital, 1 angka',
                            obscure: true,
                            controller: _passwordController,
                            errorText: _passwordError,
                            onChanged: (_) => setState(() => _passwordError = null),
                          ),
                          const SizedBox(height: 24),
                          UnderlineField(
                            label: 'Konfirmasi Sandi',
                            hint: 'Ulangi sandi',
                            obscure: true,
                            controller: _confirmPasswordController,
                            errorText: _confirmPasswordError,
                            onChanged: (_) => setState(() => _confirmPasswordError = null),
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: SizedBox(
                              width: size.width * 0.58,
                              child: DarkButton(
                                label: 'Selanjutnya',
                                onTap: _googleLoading ? () {} : _onSignUp,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Google Sign Up
                          if (_googleError != null) ...[
                            InlineMessage(message: _googleError),
                            const SizedBox(height: 8),
                          ],
                          GestureDetector(
                            onTap: _googleLoading ? null : _onGoogleSignUp,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/logo_google.png',
                                  width: 28,
                                  height: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _googleLoading ? 'Memproses...' : 'Daftar dengan Google',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _googleLoading ? Colors.grey : const Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
