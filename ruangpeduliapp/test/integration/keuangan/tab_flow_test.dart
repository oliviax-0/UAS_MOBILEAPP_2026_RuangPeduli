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

    await tester.pumpAndSettle();

    // Mencari widget Tab secara langsung. 
    // Menggunakan find.byType(Tab) lebih reliabel pada integration test dibandingkan mencari kontainer TabBar-nya.
    final tabFinder = find.byType(Tab);
    
    // Pastikan widget Tab ditemukan (biasanya 'Pemasukan' dan 'Pengeluaran')
    expect(tabFinder, findsWidgets, reason: 'Tab tidak ditemukan. Pastikan halaman sudah selesai memuat data.');

    if (tester.widgetList(tabFinder).length >= 2) {
      // Tap tab kedua
      await tester.tap(tabFinder.at(1));
      await tester.pumpAndSettle();

      // Tap kembali ke tab pertama
      await tester.tap(tabFinder.first);
      await tester.pumpAndSettle();
    }

    // Pastikan tidak crash
    expect(find.byType(InputTransaksiPage), findsOneWidget);
  });
}