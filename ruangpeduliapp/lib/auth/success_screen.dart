import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_panti.dart';
import 'package:ruangpeduliapp/masyarakat/home/home_masyarakat_screen.dart';

class SuccessScreen extends StatefulWidget {
  final String role;
  final int? userId;
  final int? pantiId;
  const SuccessScreen({
    super.key,
    required this.role,
    this.userId,
    this.pantiId,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeInAnim;

  late AnimationController _crossFadeController;
  late Animation<double> _darkOpacity;
  late Animation<double> _whiteOpacity;

  @override
  void initState() {
    super.initState();

    // Slide naik dari bawah
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeInAnim =
        CurvedAnimation(parent: _slideController, curve: Curves.easeIn);

    // Cross-fade hitam → putih
    _crossFadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _darkOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _crossFadeController, curve: Curves.easeIn));
    _whiteOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _crossFadeController, curve: Curves.easeIn));

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Step 1: logo hitam slide naik
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _slideController.forward();

    // Step 2: tunggu 1 detik → berubah ke putih
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    _crossFadeController.forward();

    // Step 3: tunggu 1 detik → ke homepage
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    _navigateToHome();
  }

  void _navigateToHome() {
    final Widget home = widget.role == 'panti'
        ? HomePanti(userId: widget.userId, pantiId: widget.pantiId)
        : HomeMasyarakatScreen(userId: widget.userId);

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => home,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _crossFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Center(
          child: AnimatedBuilder(
            animation:
                Listenable.merge([_slideController, _crossFadeController]),
            builder: (context, _) {
              return SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeInAnim,
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Logo hitam (checkmark_dark) → fade out
                        Opacity(
                          opacity: _darkOpacity.value,
                          child: Image.asset(
                            'assets/images/checkmark_dark.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Logo putih (checkmark_white) → fade in
                        Opacity(
                          opacity: _whiteOpacity.value,
                          child: Image.asset(
                            'assets/images/checkmark_white.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}