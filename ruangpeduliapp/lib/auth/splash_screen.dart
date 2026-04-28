// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/auth/role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late AnimationController _whiteController;
  late AnimationController _taglineInController;
  late AnimationController _taglineOutController;
  late AnimationController _welcomeController;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _bgOpacity;
  late Animation<double> _logoWhiteFade;
  // Tagline: slide dari kanan ke tengah
  late Animation<Offset> _taglineSlide;
  late Animation<double> _taglineFadeIn;
  // Tagline: fade out
  late Animation<double> _taglineFadeOut;
  // Welcome
  late Animation<double> _welcomeFade;
  late Animation<Offset> _welcomeSlide;

  bool _showBackground = false;
  bool _showTagline = false;
  bool _showWelcome = false;
  bool _makeWhite = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _runSequence();
  }

  void _setupAnimations() {
    // Logo
    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _logoFade =
        CurvedAnimation(parent: _logoController, curve: Curves.easeIn);
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));

    // Background gradient
    _backgroundController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _bgOpacity = CurvedAnimation(
        parent: _backgroundController, curve: Curves.easeInOut);

    // Logo → putih
    _whiteController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _logoWhiteFade =
        CurvedAnimation(parent: _whiteController, curve: Curves.easeIn);

    // Tagline slide in dari kanan
    _taglineInController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _taglineSlide = Tween<Offset>(
      begin: const Offset(1.5, 0), // mulai dari kanan layar
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _taglineInController, curve: Curves.easeOut));
    _taglineFadeIn =
        CurvedAnimation(parent: _taglineInController, curve: Curves.easeIn);

    // Tagline fade out
    _taglineOutController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _taglineFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _taglineOutController, curve: Curves.easeIn));

    // Welcome
    _welcomeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _welcomeFade =
        CurvedAnimation(parent: _welcomeController, curve: Curves.easeIn);
    _welcomeSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _welcomeController, curve: Curves.easeOut));
  }

  Future<void> _runSequence() async {
    // 1. Logo muncul di background putih
    await Future.delayed(const Duration(milliseconds: 400));
    _logoController.forward();

    // 2. Background gradient muncul
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() => _showBackground = true);
    _backgroundController.forward();

    // 3. Logo & nama berubah putih
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _makeWhite = true);
    _whiteController.forward();

    // 4. Tagline "Satu Ruang, Seribu Harapan" slide dari kanan
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _showTagline = true);
    _taglineInController.forward();

    // 5. Tagline berhenti sebentar lalu fade out
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    _taglineOutController.forward();

    // 6. Setelah tagline hilang, muncul "Selamat datang"
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _showTagline = false;
      _showWelcome = true;
    });
    _welcomeController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    _whiteController.dispose();
    _taglineInController.dispose();
    _taglineOutController.dispose();
    _welcomeController.dispose();
    super.dispose();
  }

  void _navigate() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.75;
    final double waveHeight = size.height * 0.48;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _logoController,
          _backgroundController,
          _whiteController,
          _taglineInController,
          _taglineOutController,
          _welcomeController,
        ]),
        builder: (context, _) {
          final double w = _makeWhite ? _logoWhiteFade.value : 0.0;
          final colorMatrix = <double>[
            1.0 - w * 0.7, 0, 0, 0, 255 * w,
            0, 1.0 - w * 0.7, 0, 0, 255 * w,
            0, 0, 1.0 - w * 0.7, 0, 255 * w,
            0, 0, 0, 1, 0,
          ];

          return Stack(
            children: [
              // Base putih
              Container(color: Colors.white),

              // Gradient background
              if (_showBackground)
                Opacity(
                  opacity: _bgOpacity.value,
                  child: Container(
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
                ),

              // Wave
              if (_showBackground)
                Opacity(
                  opacity: _bgOpacity.value,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: waveHeight,
                      width: size.width,
                      child: CustomPaint(painter: _SplashWavePainter()),
                    ),
                  ),
                ),

              // Logo + tagline dalam satu Column (di tengah layar)
              Align(
                alignment: const Alignment(0, -0.15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.matrix(colorMatrix),
                          child: Image.asset(
                            'assets/images/logo_ruang_peduli.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // Tagline tepat di bawah logo
                    if (_showTagline)
                      SlideTransition(
                        position: _taglineSlide,
                        child: FadeTransition(
                          opacity: _taglineFadeIn,
                          child: FadeTransition(
                            opacity: _taglineFadeOut,
                            child: const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Satu Ruang, Seribu Harapan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // "Selamat datang" + panah
              if (_showWelcome)
                Positioned(
                  bottom: size.height * 0.13,
                  left: 28,
                  right: 28,
                  child: SlideTransition(
                    position: _welcomeSlide,
                    child: FadeTransition(
                      opacity: _welcomeFade,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Selamat datang',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: _navigate,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFFF43D5E),
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SplashWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBack = Paint()
      ..color = Colors.white.withOpacity(0.40)
      ..style = PaintingStyle.fill;

    final pathBack = Path()
      ..moveTo(0, size.height * 0.38)
      ..quadraticBezierTo(
          size.width * 0.20, size.height * 0.05,
          size.width * 0.50, size.height * 0.25)
      ..quadraticBezierTo(
          size.width * 0.80, size.height * 0.45,
          size.width, size.height * 0.22)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathBack, paintBack);

    final paintFront = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pathFront = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
          size.width * 0.22, size.height * 0.22,
          size.width * 0.50, size.height * 0.42)
      ..quadraticBezierTo(
          size.width * 0.78, size.height * 0.62,
          size.width, size.height * 0.40)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathFront, paintFront);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}