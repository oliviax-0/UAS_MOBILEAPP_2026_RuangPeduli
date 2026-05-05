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

    // Cari TabBar
    final tabBar = find.byType(TabBar);
    expect(tabBar, findsOneWidget);

    final tabs = find.byType(Tab);

    if (tabs.evaluate().length >= 2) {
      // Tap tab kedua
      await tester.tap(tabs.at(1));
      await tester.pumpAndSettle();

      // Tap kembali ke tab pertama
      await tester.tap(tabs.first);
      await tester.pumpAndSettle();
    }

    // Pastikan tidak crash
    expect(find.byType(InputTransaksiPage), findsOneWidget);
  });
}