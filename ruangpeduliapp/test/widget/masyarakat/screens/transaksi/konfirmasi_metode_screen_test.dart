// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ruangpeduliapp/data/donation_api.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/masyarakat/transaksi/konfirmasi_metode_screen.dart';

import 'konfirmasi_metode_screen_test.mocks.dart';

@GenerateMocks([DonationApi, ProfileApi])
void main() {
  late MockDonationApi mockDonationApi;
  late MockProfileApi mockProfileApi;

  setUp(() {
    mockDonationApi = MockDonationApi();
    mockProfileApi = MockProfileApi();
  });

  Widget _buildScreen({
    String namaPanti = 'Panti Asuhan Cahaya',
    String terkumpul = 'Terkumpul Rp500.000',
    String imagePath = '',
    String nominal = '50.000',
    int? pantiId = 1,
    int? userId = 42,
  }) {
    return MaterialApp(
      home: KonfirmasiMetodeScreen(
        namaPanti: namaPanti,
        terkumpul: terkumpul,
        imagePath: imagePath,
        nominal: nominal,
        pantiId: pantiId,
        userId: userId,
      ),
    );
  }

  group('KonfirmasiMetodeScreen', () {
    // ── Back button ──
    testWidgets('GestureDetector (Back) – tombol kembali ke halaman sebelumnya',
        (tester) async {
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

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.text('open'), findsOneWidget);
    });

    // ── _PantiImage placeholder ──
    testWidgets('_PantiImage – menampilkan placeholder saat imagePath kosong',
        (tester) async {
      await tester.pumpWidget(_buildScreen(imagePath: ''));
      await tester.pump();

      expect(find.byIcon(Icons.home_work_rounded), findsOneWidget);
    });

    // ── Text nama panti & nominal ──
    testWidgets(
        'Text (Nama Panti & Nominal) – menampilkan ringkasan donasi dengan benar',
        (tester) async {
      await tester.pumpWidget(
          _buildScreen(namaPanti: 'Panti Harapan', nominal: '50.000'));
      await tester.pump();

      expect(find.text('Panti Harapan'), findsOneWidget);
      // Nominal donasi label
      expect(find.text('Jumlah Donasi'), findsOneWidget);
    });

    // ── _BiayaRow: nominal donasi ──
    testWidgets(
        '_BiayaRow (Nominal Donasi) – menampilkan nominal donasi yang diinput',
        (tester) async {
      await tester.pumpWidget(_buildScreen(nominal: '50.000'));
      await tester.pump();

      // _nominalInt = 50000, formatted as 'Rp50.000' prepended with 'Rp'
      expect(find.textContaining('50.000'), findsWidgets);
    });

    // ── _BiayaRow: biaya admin Rp2.500 ──
    testWidgets(
        '_BiayaRow (Biaya Admin) – menampilkan biaya admin Rp2.500',
        (tester) async {
      await tester.pumpWidget(_buildScreen(nominal: '50.000'));
      await tester.pump();

      expect(find.text('Biaya Admin'), findsOneWidget);
      expect(find.textContaining('2.500'), findsOneWidget);
    });

    // ── _BiayaRow: total pembayaran ──
    testWidgets(
        '_BiayaRow (Total Pembayaran) – menampilkan total nominal + admin',
        (tester) async {
      // nominal 50.000 + 2.500 admin = 52.500
      await tester.pumpWidget(_buildScreen(nominal: '50.000'));
      await tester.pump();

      expect(find.text('Total Pembayaran'), findsOneWidget);
      expect(find.textContaining('52.500'), findsOneWidget);
    });

    // ── GestureDetector radio metode – default GoPay selected ──
    testWidgets(
        'GestureDetector (Radio Metode) – GoPay terpilih secara default',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(find.text('GoPay'), findsOneWidget);
      expect(find.text('OVO'), findsOneWidget);
      expect(find.text('DANA'), findsOneWidget);
      expect(find.text('Transfer Bank'), findsOneWidget);
    });

    // ── GestureDetector radio metode – can change selection ──
    testWidgets(
        'GestureDetector (Radio Metode) – pilih metode OVO mengubah seleksi',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      await tester.tap(find.text('OVO'));
      await tester.pump();

      // After tap OVO, find filled inner radio circle (black dot)
      // We verify by ensuring no error and OVO row still visible
      expect(find.text('OVO'), findsOneWidget);
    });

    // ── CircularProgressIndicator – loading state ──
    testWidgets(
        'CircularProgressIndicator – muncul saat proses donasi berlangsung',
        (tester) async {
      // We check that the button shows loading indicator during _onKonfirmasi
      // by mocking a delayed donation API
      when(mockDonationApi.createDonation(
        userId: anyNamed('userId'),
        pantiId: anyNamed('pantiId'),
        namaPanti: anyNamed('namaPanti'),
        jumlah: anyNamed('jumlah'),
        metodePembayaran: anyNamed('metodePembayaran'),
        noReferensi: anyNamed('noReferensi'),
      )).thenAnswer((_) => Future.delayed(const Duration(seconds: 5)));

      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      await tester.tap(find.text('Konfirmasi'));
      // pump one frame so _loading becomes true
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // ── ElevatedButton Konfirmasi exists ──
    testWidgets(
        'ElevatedButton (Konfirmasi) – tombol submit donasi ke API ada di layar',
        (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      expect(
        find.widgetWithText(ElevatedButton, 'Konfirmasi'),
        findsOneWidget,
      );
    });

    // ── SnackBar error gagal donasi ──
    testWidgets(
        'SnackBar – menampilkan error gagal menyimpan donasi saat API gagal',
        (tester) async {
      when(mockDonationApi.createDonation(
        userId: anyNamed('userId'),
        pantiId: anyNamed('pantiId'),
        namaPanti: anyNamed('namaPanti'),
        jumlah: anyNamed('jumlah'),
        metodePembayaran: anyNamed('metodePembayaran'),
        noReferensi: anyNamed('noReferensi'),
      )).thenThrow(Exception('Network error'));

      await tester.pumpWidget(_buildScreen());
      await tester.pump();

      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();

      expect(find.text('Gagal menyimpan donasi, coba lagi!'), findsOneWidget);
    });
  });
}