// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/masyarakat/transaksi/konfirmasi_pembayaran_screen.dart';

/// Helper: wrap widget in MaterialApp so Navigator & MediaQuery exist
Widget _wrap(Widget child) => MaterialApp(home: child);

Widget _buildScreen({
  String namaPanti = 'Panti Asuhan Cahaya',
  String terkumpul = 'Terkumpul Rp500.000',
  String imagePath = '',
  int? pantiId = 1,
  int? userId = 42,
}) {
  return _wrap(
    KonfirmasiPembayaranScreen(
      namaPanti: namaPanti,
      terkumpul: terkumpul,
      imagePath: imagePath,
      pantiId: pantiId,
      userId: userId,
    ),
  );
}

void main() {
  group('KonfirmasiPembayaranScreen', () {
    // ── Back button ──
    testWidgets('GestureDetector (Back) – tombol kembali ke halaman sebelumnya',
        (tester) async {
      bool popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => Navigator.push(
                ctx,
                MaterialPageRoute(builder: (_) => _buildScreen()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // screen is now open
      expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);

      // tap back icon
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // should have returned to previous page
      expect(find.text('open'), findsOneWidget);
      _ = popped; // suppress unused warning
    });

    // ── _PantiImage – placeholder when path is empty ──
    testWidgets('_PantiImage – menampilkan placeholder saat imagePath kosong',
        (tester) async {
      await tester.pumpWidget(_buildScreen(imagePath: ''));
      await tester.pump();

      expect(find.byIcon(Icons.home_work_rounded), findsOneWidget);
    });

    // ── Text nama panti ──
    testWidgets('Text (Nama Panti) – menampilkan nama panti tujuan donasi',
        (tester) async {
      await tester.pumpWidget(_buildScreen(namaPanti: 'Panti Harapan Bangsa'));
      await tester.pump();

      expect(find.text('Panti Harapan Bangsa'), findsOneWidget);
    });

    // ── TextField nominal – format otomatis ribuan ──
    testWidgets(
        'TextField (Nominal) – input nominal donasi dengan format otomatis ribuan',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      final tf = find.byType(TextField);
      expect(tf, findsOneWidget);

      await tester.enterText(tf, '50000');
      await tester.pump();

      // After formatting, dots should be inserted: 50.000
      final TextEditingController ctrl =
          (tester.widget<TextField>(tf)).controller!;
      expect(ctrl.text, '50.000');
    });

    // ── Error: nominal kosong ──
    testWidgets(
        'Text (Error Nominal) & SnackBar – menampilkan error saat nominal kosong',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      // Tap konfirmasi without entering amount
      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();

      expect(find.text('Masukkan nominal donasi'), findsWidgets);
    });

    // ── Error: nominal kurang dari Rp1.000 ──
    testWidgets(
        'Text (Error Nominal) & SnackBar – menampilkan error saat nominal < Rp1.000',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      final tf = find.byType(TextField);
      await tester.enterText(tf, '500');
      await tester.pump();

      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();

      expect(find.text('Nominal minimal Rp1.000'), findsWidgets);
    });

    // ── SnackBar error muncul ──
    testWidgets('SnackBar – menampilkan pesan error melalui _showError',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();

      // SnackBar should appear
      expect(find.byType(SnackBar), findsOneWidget);
    });

    // ── ElevatedButton Konfirmasi exists ──
    testWidgets(
        'ElevatedButton (Konfirmasi) – tombol lanjut ke pilih metode pembayaran ada di layar',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(
        find.widgetWithText(ElevatedButton, 'Konfirmasi'),
        findsOneWidget,
      );
    });

    // ── ElevatedButton Konfirmasi navigates when nominal valid ──
    testWidgets(
        'ElevatedButton (Konfirmasi) – navigasi ke KonfirmasiMetodeScreen saat nominal valid',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      final tf = find.byType(TextField);
      await tester.enterText(tf, '10000');
      await tester.pump();

      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();

      // KonfirmasiMetodeScreen title should appear
      expect(find.text('Metode Pembayaran'), findsOneWidget);
    });
  });
}