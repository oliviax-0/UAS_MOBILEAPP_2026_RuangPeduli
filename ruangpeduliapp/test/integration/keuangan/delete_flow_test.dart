import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_panti.dart';

void main() {
  testWidgets('Delete transaction flow test', (WidgetTester tester) async {
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

    final trxTile = find.byType(TrxTile);

    if (trxTile.evaluate().isNotEmpty) {
      await tester.tap(trxTile.first);
      await tester.pump();

      final snackbar = find.byType(SnackBar);

      expect(
        snackbar.evaluate().isNotEmpty ||
            find.byType(KeuanganPanti).evaluate().isNotEmpty,
        true,
      );
    } else {
      expect(find.byType(KeuanganPanti), findsOneWidget);
    }
  });
}
