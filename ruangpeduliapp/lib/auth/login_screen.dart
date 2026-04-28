import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';
import 'package:ruangpeduliapp/auth/forgot_password_screen.dart';
import 'package:ruangpeduliapp/auth/fill_data_masyarakat_screen.dart';
import 'package:ruangpeduliapp/auth/fill_data_panti_screen.dart';
import 'package:ruangpeduliapp/data/data.dart';
import 'package:ruangpeduliapp/masyarakat/home/home_masyarakat_screen.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_panti.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _api = AuthApi();
  bool _loading = false;
  bool _googleLoading = false;
  String? _emailError;
  String? _passwordError;
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onGoogleLogin() async {
    final backendRole = widget.role.toLowerCase().contains('panti') ? 'panti' : 'masyarakat';

    setState(() { _googleLoading = true; _generalError = null; });
    try {
      final idToken = await GoogleSignInService.signIn();
      if (idToken == null) return; // user cancelled

      final result = await _api.googleAuth(idToken, backendRole);

      if (!mounted) return;

      if (result['exists'] == true) {
        final role = result['role'] as String;
        final userId = result['user_id'] as int?;
        final pantiId = result['panti_id'] as int?;
        final Widget home = role == 'panti'
            ? HomePanti(userId: userId, pantiId: pantiId)
            : HomeMasyarakatScreen(userId: userId);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => home),
          (route) => false,
        );
      } else {
        // Account doesn't exist → go to fill data with Google token
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
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _generalError = '$e');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _onLogin() async {
    final emailErr = _emailController.text.isEmpty ? 'Email wajib diisi' : null;
    final passErr = _passwordController.text.isEmpty ? 'Sandi wajib diisi' : null;
    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
      _generalError = null;
    });
    if (emailErr != null || passErr != null) return;

    setState(() => _loading = true);

    try {
      final backendRole = widget.role.toLowerCase().contains('panti') ? 'panti' : 'masyarakat';
      final result = await _api.login(
        _emailController.text.trim(),
        _passwordController.text,
        backendRole,
      );

      if (!mounted) return;

      final role = result['role'] as String;
      final userId = result['user_id'] as int?;
      final pantiId = result['panti_id'] as int?;
      final Widget home = role == 'panti'
          ? HomePanti(userId: userId, pantiId: pantiId)
          : HomeMasyarakatScreen(userId: userId);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => home),
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
                    // Back button
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 8),
                      child: AuthBackButton(),
                    ),

                    // Spacer turun ke bawah wave
                    SizedBox(height: size.height * 0.38),

                    // Konten di area putih/cream
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),

                          // Title
                          const Text('Log In',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 4),
                          Text(widget.role,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.teal)),
                          const SizedBox(height: 32),

                          // Email
                          UnderlineField(
                            label: 'Email',
                            hint: 'Masukan Email',
                            controller: _emailController,
                            errorText: _emailError,
                            onChanged: (_) => setState(() => _emailError = null),
                          ),
                          const SizedBox(height: 24),

                          // Sandi
                          UnderlineField(
                            label: 'Sandi',
                            hint: 'Masukan Sandi',
                            obscure: true,
                            controller: _passwordController,
                            errorText: _passwordError,
                            onChanged: (_) => setState(() => _passwordError = null),
                          ),
                          const SizedBox(height: 8),

                          // Lupa Sandi
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ForgotPasswordScreen(role: widget.role),
                                ),
                              ),
                              child: const Text(
                                'Lupa Sandi?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFF43D5E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          InlineMessage(message: _generalError),
                          if (_generalError != null) const SizedBox(height: 12),

                          // Log In button (centered)
                          Center(
                            child: SizedBox(
                              width: size.width * 0.58,
                              child: DarkButton(
                                label: _loading ? 'Memproses...' : 'Log In',
                                onTap: _loading ? () {} : _onLogin,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Google Login — tanpa background, logo asli + teks
                          GestureDetector(
                            onTap: (_loading || _googleLoading) ? null : _onGoogleLogin,
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
                                  _googleLoading ? 'Memproses...' : 'Log In dengan Google',
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
