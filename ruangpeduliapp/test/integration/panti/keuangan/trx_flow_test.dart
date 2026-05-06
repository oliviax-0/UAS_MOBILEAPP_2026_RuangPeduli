import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_panti.dart';

void main() {
  testWidgets('Transaction flow basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: KeuanganPanti(
          userId: null,
          pantiId: null,
        ),
      ),
    );

    expect(find.byType(KeuanganPanti), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));

    final loading = find.byType(CircularProgressIndicator);
    final list = find.byType(ListView);
    final empty = find.textContaining('Belum');
    final title = find.text('Transaksi');

    expect(
      loading.evaluate().isNotEmpty ||
          list.evaluate().isNotEmpty ||
          empty.evaluate().isNotEmpty ||
          title.evaluate().isNotEmpty,
      true,
    );

    final trxTile = find.byType(TrxTile);

    if (trxTile.evaluate().isNotEmpty) {
      await tester.tap(trxTile.first);
      await tester.pump();
    }

    expect(find.byType(KeuanganPanti), findsWidgets);
  });
}
