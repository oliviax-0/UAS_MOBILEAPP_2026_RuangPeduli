import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_plus.dart';

void main() {
  testWidgets('Tab flow basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InputTransaksiPage(
          userId: 1,
          pantiId: 1,
        ),
      ),
    );

    // Halaman tampil
    expect(find.byType(InputTransaksiPage), findsOneWidget);

    // Berikan waktu ekstra untuk transisi state jika ada pemanggilan API yang gagal/timeout
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Gunakan pencarian teks karena lebih reliabel daripada mencari tipe widget Tab
    // jika TabBar tidak menggunakan widget Tab secara eksplisit.
    final pemasukanTab = find.text('Pemasukan');
    final pengeluaranTab = find.text('Pengeluaran');

    expect(pemasukanTab, findsOneWidget);
    expect(pengeluaranTab, findsOneWidget);

    // Tap tab Pengeluaran
    await tester.tap(pengeluaranTab);
    await tester.pumpAndSettle();

    // Tap kembali ke tab Pemasukan
    await tester.tap(pemasukanTab);
    await tester.pumpAndSettle();

    // Pastikan tidak crash
    expect(find.byType(InputTransaksiPage), findsOneWidget);
  });
}