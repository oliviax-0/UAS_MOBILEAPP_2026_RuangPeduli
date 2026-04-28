import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ruangpeduliapp/masyarakat/notification/notification_screen.dart';

class LokasiScreen extends StatelessWidget {
  final String namaPanti;
  final String alamat;
  final double lat;
  final double lng;
  final double? distanceMeters;

  const LokasiScreen({
    super.key,
    required this.namaPanti,
    required this.alamat,
    required this.lat,
    required this.lng,
    this.distanceMeters,
  });

  String get _distanceLabel {
    if (distanceMeters == null) return 'Jarak tidak tersedia';
    if (distanceMeters! < 1000) return '${distanceMeters!.round()} m dari lokasi Anda';
    return '${(distanceMeters! / 1000).toStringAsFixed(1)} km dari lokasi Anda';
  }

  Future<void> _openMaps() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    await launchUrl(uri, mode: LaunchMode.inAppWebView);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_rounded,
                        size: 24, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Lokasi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationScreen()),
                    ),
                    child: Image.asset(
                      'assets/images/bell_notification.png',
                      width: 26,
                      height: 26,
                      color: const Color(0xFF1A1A1A),
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.notifications_none_rounded,
                          size: 26,
                          color: Color(0xFF1A1A1A)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Map placeholder ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  color: const Color(0xFFE8F0D8),
                  child: Stack(
                    children: [
                      // Map grid lines
                      CustomPaint(
                        size: const Size(double.infinity, 220),
                        painter: _MapPainter(),
                      ),

                      // Destination pin (merah - panti)
                      Positioned(
                        top: 50,
                        right: 80,
                        child: _MapPin(color: const Color(0xFFE53935)),
                      ),

                      // Current location pin (hijau)
                      Positioned(
                        bottom: 55,
                        left: 90,
                        child: _MapPin(color: const Color(0xFF43A047)),
                      ),

                      // Route line
                      CustomPaint(
                        size: const Size(double.infinity, 220),
                        painter: _RoutePainter(),
                      ),

                      // Watermark
                      Positioned(
                        bottom: 6,
                        right: 8,
                        child: Text(
                          'designed by © freepik.com',
                          style: TextStyle(
                              fontSize: 9, color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Detail card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F2),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama panti
                    Text(
                      namaPanti,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Jarak
                    Row(
                      children: [
                        const Icon(Icons.near_me_rounded,
                            size: 16, color: Color(0xFFF43D5E)),
                        const SizedBox(width: 8),
                        Text(
                          _distanceLabel,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Alamat
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 16, color: Color(0xFFF43D5E)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alamat,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Google Maps button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openMaps,
                        icon: const Icon(Icons.map_rounded, size: 18),
                        label: const Text('Buka di Google Maps'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF43D5E),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavBar(context),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF47B8C),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_rounded, selected: false, onTap: () {}),
              _NavItem(
                  icon: Icons.search_rounded, selected: true, onTap: () {}),
              _NavItem(
                  icon: Icons.history_rounded, selected: false, onTap: () {}),
              _NavItem(
                  icon: Icons.person_rounded, selected: false, onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Map pin widget ──
class _MapPin extends StatelessWidget {
  final Color color;
  const _MapPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 16),
        ),
        Container(
          width: 2,
          height: 8,
          color: color.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}

// ── Simple map background painter ──
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4E8B0)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height * 0.3),
        Offset(size.width, size.height * 0.3), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.6),
        Offset(size.width, size.height * 0.6), roadPaint);
    canvas.drawLine(Offset(size.width * 0.3, 0),
        Offset(size.width * 0.3, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.65, 0),
        Offset(size.width * 0.65, size.height), roadPaint);

    final buildingPaint = Paint()
      ..color = const Color(0xFFB8CCAA)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.05, 70, 50),
        buildingPaint);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.35, size.height * 0.05, 80, 55),
        buildingPaint);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.70, size.height * 0.05, 60, 45),
        buildingPaint);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.65, 75, 60),
        buildingPaint);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.35, size.height * 0.65, 85, 55),
        buildingPaint);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.70, size.height * 0.65, 65, 60),
        buildingPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Route painter ──
class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1565C0)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.78)
      ..lineTo(size.width * 0.25, size.height * 0.60)
      ..lineTo(size.width * 0.65, size.height * 0.60)
      ..lineTo(size.width * 0.65, size.height * 0.30)
      ..lineTo(size.width * 0.78, size.height * 0.30);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Nav Item ──
class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem(
      {required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 28,
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.60)),
            if (selected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
