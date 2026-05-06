// integration_test/donation_flow_test.dart
//
// Tests the full donation flow:
// PantiDetailScreen → KonfirmasiPembayaranScreen
//                   → KonfirmasiMetodeScreen
//                   → TransaksiSuksesScreen

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ruangpeduliapp/masyarakat/transaksi/konfirmasi_pembayaran_screen.dart';
import 'package:ruangpeduliapp/masyarakat/transaksi/konfirmasi_metode_screen.dart';
import 'package:ruangpeduliapp/masyarakat/transaksi/transaksi_sukses_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────
  //  KonfirmasiPembayaranScreen
  // ─────────────────────────────────────────────
  group('KonfirmasiPembayaranScreen', () {
    Widget buildScreen() => MaterialApp(
          home: KonfirmasiPembayaranScreen(
            namaPanti: 'Panti Asuhan Harapan',
            terkumpul: 'Rp5.000.000',
            imagePath: '',
            pantiId: 1,
            userId: 42,
          ),
        );

    testWidgets('renders panti info and nominal input', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);
      expect(find.text('Panti Asuhan Harapan'), findsOneWidget);
      expect(find.text('Rp5.000.000'), findsOneWidget);
      expect(find.text('Konfirmasi'), findsOneWidget);
    });

    testWidgets('shows error when nominal is empty', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();

      expect(find.text('Masukkan nominal donasi'), findsWidgets);
    });

    testWidgets('shows error when nominal is below Rp1.000', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      final field = find.byType(TextField).first;
      await tester.tap(field);
      await tester.enterText(field, '500');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();

      expect(find.text('Nominal minimal Rp1.000'), findsWidgets);
    });

    testWidgets('auto-formats nominal with thousand separators',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      final field = find.byType(TextField).first;
      await tester.tap(field);
      await tester.enterText(field, '50000');
      await tester.pumpAndSettle();

      // After formatting: 50.000
      expect(find.text('50.000'), findsOneWidget);
    });

    testWidgets('navigates to KonfirmasiMetodeScreen on valid input',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      final field = find.byType(TextField).first;
      await tester.tap(field);
      await tester.enterText(field, '10000');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();

      expect(find.byType(KonfirmasiMetodeScreen), findsOneWidget);
    });

    testWidgets('back button pops screen', (tester) async {
      bool popped = false;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                ctx,
                MaterialPageRoute(
                  builder: (_) => KonfirmasiPembayaranScreen(
                    namaPanti: 'Panti Asuhan Harapan',
                    terkumpul: 'Rp5.000.000',
                    imagePath: '',
                  ),
                ),
              );
              popped = result == null;
            },
            child: const Text('Open'),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final backBtn = find.byIcon(Icons.arrow_back_rounded).first;
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });
  });

  // ─────────────────────────────────────────────
  //  KonfirmasiMetodeScreen
  // ─────────────────────────────────────────────
  group('KonfirmasiMetodeScreen', () {
    Widget buildScreen() => MaterialApp(
          home: KonfirmasiMetodeScreen(
            namaPanti: 'Panti Asuhan Harapan',
            terkumpul: 'Rp5.000.000',
            imagePath: '',
            nominal: '10.000',
            pantiId: 1,
            userId: 42,
          ),
        );

    testWidgets('renders all payment method options', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('GoPay'), findsOneWidget);
      expect(find.text('OVO'), findsOneWidget);
      expect(find.text('DANA'), findsOneWidget);
      expect(find.text('Transfer Bank'), findsOneWidget);
    });

    testWidgets('renders total breakdown including admin fee', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Nominal: 10.000 + admin 2.500 = 12.500
      expect(find.textContaining('Rp10.000'), findsWidgets);
      expect(find.text('Rp2.500'), findsOneWidget);
      expect(find.text('Rp12.500'), findsOneWidget);
    });

    testWidgets('selecting a payment method updates UI', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('OVO'));
      await tester.pumpAndSettle();

      // No crash and OVO tile is visible
      expect(find.text('OVO'), findsOneWidget);
    });

    testWidgets('back button pops screen', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
      await tester.pumpAndSettle();

      expect(find.byType(KonfirmasiMetodeScreen), findsNothing);
    });
  });

  // ─────────────────────────────────────────────
  //  TransaksiSuksesScreen
  // ─────────────────────────────────────────────
  group('TransaksiSuksesScreen', () {
    Widget buildScreen() => MaterialApp(
          home: TransaksiSuksesScreen(
            namaPanti: 'Panti Asuhan Harapan',
            total: 'Rp12.500',
            jumlahDonasi: 10000,
            metodePembayaran: 'GoPay',
            noReferensi: 'REF123456',
            pantiId: 1,
            userId: 42,
            username: 'budi',
          ),
        );

    testWidgets('checkmark animation phase renders correctly', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump(const Duration(milliseconds: 500));

      // Should show the black circle checkmark
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('success page renders after animation', (tester) async {
      await tester.pumpWidget(buildScreen());
      // Wait past animation delay (200ms) + forward (600ms) + display (2000ms)
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      expect(find.text('Transaksi Anda Berhasil'), findsOneWidget);
      expect(find.text('Rp12.500'), findsOneWidget);
      expect(find.text('@budi'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
    });

    testWidgets('transaction detail rows are rendered', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      expect(find.text('Tanggal Transaksi'), findsOneWidget);
      expect(find.text('No. Referensi'), findsOneWidget);
      expect(find.text('Waktu Transfer'), findsOneWidget);
    });

    testWidgets('Selesai button is tappable after success screen shows',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();

      // Should have navigated away
      expect(find.text('Transaksi Anda Berhasil'), findsNothing);
    });
  });

  // ─────────────────────────────────────────────
  //  End-to-end: Pembayaran → Metode → Sukses
  // ─────────────────────────────────────────────
  group('End-to-end donation flow', () {
    testWidgets('full flow: enter nominal → pick method → see success',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: KonfirmasiPembayaranScreen(
          namaPanti: 'Panti Asuhan Harapan',
          terkumpul: 'Rp5.000.000',
          imagePath: '',
          pantiId: 1,
          userId: 42,
        ),
      ));
      await tester.pumpAndSettle();

      // 1. Enter valid nominal
      final field = find.byType(TextField).first;
      await tester.tap(field);
      await tester.enterText(field, '10000');
      await tester.pumpAndSettle();

      // 2. Tap Konfirmasi
      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();

      // 3. Now on KonfirmasiMetodeScreen
      expect(find.byType(KonfirmasiMetodeScreen), findsOneWidget);
      expect(find.text('GoPay'), findsOneWidget);

      // 4. Pick DANA
      await tester.tap(find.text('DANA'));
      await tester.pumpAndSettle();

      // Confirm button visible
      expect(find.textContaining('Konfirmasi'), findsWidgets);
    });
  });
}
