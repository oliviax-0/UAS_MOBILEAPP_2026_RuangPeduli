import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_panti.dart';

void main() {
  testWidgets('TrxTile render & tap test', (WidgetTester tester) async {
    bool deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrxTile(
            id: 1,
            kategori: 'Makanan',
            nominal: 10000.0,
            tanggal: '2024-01-01',
            tipe: 'pengeluaran',
            onDelete: () {
              deleted = true;
            },
          ),
        ),
      ),
    );

    expect(find.byType(TrxTile), findsOneWidget);
    expect(find.text('Makanan'), findsOneWidget);

    // coba tap (misal delete gesture)
    await tester.tap(find.byType(TrxTile));
    await tester.pump();

    expect(deleted, true);
  });
}
