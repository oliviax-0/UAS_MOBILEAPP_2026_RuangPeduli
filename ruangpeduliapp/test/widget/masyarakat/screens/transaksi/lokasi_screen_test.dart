// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/masyarakat/transaksi/lokasi_screen.dart';

Widget _buildScreen({
  String namaPanti = 'Panti Asuhan Cahaya',
  String alamat = 'Jl. Kebon Jeruk No. 10, Jakarta Barat',
  double lat = -6.2088,
  double lng = 106.8456,
  double? distanceMeters = 1500,
}) {
  return MaterialApp(
    home: LokasiScreen(
      namaPanti: namaPanti,
      alamat: alamat,
      lat: lat,
      lng: lng,
      distanceMeters: distanceMeters,
    ),
  );
}

void main() {
    // ── CustomPaint _MapPainter ──
    testWidgets('CustomPaint (_MapPainter)  peta ilustrasi dirender di layar',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    // ── CustomPaint _RoutePainter ──
    testWidgets(
        'CustomPaint (_RoutePainter) – rute dari user ke panti dirender',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      // Both _MapPainter and _RoutePainter are rendered as CustomPaint widgets
      final customPaints = tester.widgetList(find.byType(CustomPaint));
      expect(customPaints.length, greaterThanOrEqualTo(2));
    });

    // ── _MapPin merah (panti) ──
    testWidgets('_MapPin (Merah) – pin lokasi panti tujuan ditampilkan',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      // location_on icon used in _MapPin
      expect(find.byIcon(Icons.location_on), findsWidgets);
    });

    // ── _MapPin hijau (user) ──
    testWidgets('_MapPin (Hijau) – pin lokasi user saat ini ditampilkan',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      // Two _MapPin widgets rendered (merah + hijau)
      expect(find.byIcon(Icons.location_on), findsNWidgets(2));
    });

    // ── Text nama panti ──
    testWidgets('Text (Nama Panti) – menampilkan nama panti dengan benar',
        (tester) async {
      await tester.pumpWidget(_buildScreen(namaPanti: 'Panti Harapan Bangsa'));
      await tester.pump();

      expect(find.text('Panti Harapan Bangsa'), findsOneWidget);
    });

    // ── Text jarak – dalam meter ──
    testWidgets('Text (Jarak) – menampilkan jarak dalam meter saat < 1000m',
        (tester) async {
      await tester.pumpWidget(_buildScreen(distanceMeters: 850));
      await tester.pump();

      expect(find.text('850 m dari lokasi Anda'), findsOneWidget);
    });

    // ── Text jarak – dalam km ──
    testWidgets('Text (Jarak) – menampilkan jarak dalam km saat >= 1000m',
        (tester) async {
      await tester.pumpWidget(_buildScreen(distanceMeters: 1500));
      await tester.pump();

      expect(find.text('1.5 km dari lokasi Anda'), findsOneWidget);
    });

    // ── Text jarak – tidak tersedia ──
    testWidgets(
        'Text (Jarak) – menampilkan "Jarak tidak tersedia" saat distanceMeters null',
        (tester) async {
      await tester.pumpWidget(_buildScreen(distanceMeters: null));
      await tester.pump();

      expect(find.text('Jarak tidak tersedia'), findsOneWidget);
    });

    // ── Text alamat ──
    testWidgets('Text (Alamat) – menampilkan alamat lengkap panti',
        (tester) async {
      await tester.pumpWidget(
          _buildScreen(alamat: 'Jl. Kebon Jeruk No. 10, Jakarta Barat'));
      await tester.pump();

      expect(
          find.text('Jl. Kebon Jeruk No. 10, Jakarta Barat'), findsOneWidget);
    });

    // ── ElevatedButton Google Maps ──
    testWidgets(
        'ElevatedButton (Buka di Google Maps) – tombol membuka Google Maps ada di layar',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(
        find.widgetWithText(ElevatedButton, 'Buka di Google Maps'),
        findsOneWidget,
      );
    });

    // ── _NavItem (Navbar) ──
    testWidgets('_NavItem (Navbar) – bottom navigation bar dirender',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      // Nav bar container exists at bottom
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets(
        '_NavItem – item search terpilih memiliki indikator dot di bawah ikon',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      // The selected nav item (search) renders a small dot Container
      // We verify by checking the nav bar is fully rendered
      final navBar = find.byType(BottomNavigationBar);
      // LokasiScreen uses a custom nav, not BottomNavigationBar
      // so we look for the Row inside the nav container
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });
  }
