// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/masyarakat/transaksi/transaksi_sukses_screen.dart';

Widget _buildScreen({
  String namaPanti = 'Panti Asuhan Cahaya',
  String total = 'Rp52.500',
  int jumlahDonasi = 50000,
  String metodePembayaran = 'GoPay',
  String noReferensi = 'REF12345',
  int? pantiId = 1,
  int? userId = 42,
  String username = 'budi123',
  String? profilePicture,
}) {
  return MaterialApp(
    home: TransaksiSuksesScreen(
      namaPanti: namaPanti,
      total: total,
      jumlahDonasi: jumlahDonasi,
      metodePembayaran: metodePembayaran,
      noReferensi: noReferensi,
      pantiId: pantiId,
      userId: userId,
      username: username,
      profilePicture: profilePicture,
    ),
  );
}

void main() {
  group('TransaksiSuksesScreen', () {
    // ── Checkmark animation page ──
    testWidgets(
        'Container (Checkmark Animasi) – animasi centang slide dari kanan muncul di awal',
        (tester) async {
      await tester.pumpWidget(_buildScreen());

      // Pump one frame so slide animation starts
      await tester.pump(const Duration(milliseconds: 300));

      // Black circle container with check icon should be visible
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    // ── Transition to sukses page ──
    testWidgets(
        'Sukses page – muncul setelah animasi centang selesai (2 detik)',
        (tester) async {
      await tester.pumpWidget(_buildScreen());

      // Fast-forward past the 200ms delay + 600ms animation + 2000ms display
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pump();

      expect(find.text('Transaksi Anda Berhasil'), findsOneWidget);
    });

    // ── Container Avatar User ──
    testWidgets(
        'Container (Avatar User) – menampilkan inisial username saat tidak ada foto profil',
        (tester) async {
      await tester.pumpWidget(_buildScreen(username: 'budi123'));

      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pump();

      // First letter of username uppercase: 'B'
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets(
        'Container (Avatar User) – menampilkan username dengan prefix @ di sukses page',
        (tester) async {
      await tester.pumpWidget(_buildScreen(username: 'budi123'));

      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pump();

      expect(find.text('@budi123'), findsOneWidget);
    });

    // ── Text total nominal ──
    testWidgets(
        'Text (Total Nominal) – menampilkan total pembayaran dengan benar',
        (tester) async {
      await tester.pumpWidget(_buildScreen(total: 'Rp52.500'));

      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pump();

      expect(find.text('Rp52.500'), findsOneWidget);
    });

    // ── _DetailRow tanggal transaksi ──
    testWidgets(
        '_DetailRow (Tanggal Transaksi) – menampilkan tanggal transaksi',
        (tester) async {
      await tester.pumpWidget(_buildScreen());

      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pump();

      expect(find.text('Tanggal Transaksi'), findsOneWidget);

      // Verify formatted date contains current year
      final now = DateTime.now();
      expect(find.textContaining(now.year.toString()), findsWidgets);
    });

    // ── _DetailRow no. referensi ──
    testWidgets(
        '_DetailRow (No. Referensi) – menampilkan nomor referensi transaksi',
        (tester) async {
      await tester.pumpWidget(_buildScreen());

      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pump();

      expect(find.text('No. Referensi'), findsOneWidget);
      // Reference starts with REF
      expect(find.textContaining('REF'), findsWidgets);
    });

    // ── _DetailRow waktu transfer ──
    testWidgets(
        '_DetailRow (Waktu Transfer) – menampilkan waktu transaksi',
        (tester) async {
      await tester.pumpWidget(_buildScreen());

      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pump();

      expect(find.text('Waktu Transfer'), findsOneWidget);
      // Time format contains 'WIB'
      expect(find.textContaining('WIB'), findsOneWidget);
    });

    // ── ElevatedButton Selesai ──
    testWidgets(
        'ElevatedButton (Selesai) – tombol kembali ke Profile Screen ada di layar',
        (tester) async {
      await tester.pumpWidget(_buildScreen());

      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pump();

      expect(
        find.widgetWithText(ElevatedButton, 'Selesai'),
        findsOneWidget,
      );
    });

    // ── ElevatedButton Selesai navigates ──
    testWidgets(
        'ElevatedButton (Selesai) – navigasi ke ProfileScreen saat ditekan',
        (tester) async {
      await tester.pumpWidget(_buildScreen());

      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Selesai'));
      await tester.pumpAndSettle();

      // ProfileScreen should be pushed; verify previous screen is gone
      expect(find.text('Transaksi Anda Berhasil'), findsNothing);
    });
  });
}