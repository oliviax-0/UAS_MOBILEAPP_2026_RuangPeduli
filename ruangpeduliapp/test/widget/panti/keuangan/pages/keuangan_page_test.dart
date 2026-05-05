import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_panti.dart';

void main() {
  testWidgets('KeuanganPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: KeuanganPanti(
          userId: null,
          pantiId: null,
        ),
      ),
    );

    expect(find.byType(KeuanganPanti), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    // kondisi kemungkinan: loading / empty / list transaksi
    final loading = find.byType(CircularProgressIndicator);
    final list = find.byType(ListView);
    final empty = find.textContaining('Belum');
    final summary = find.textContaining('Saldo');

    expect(
      loading.evaluate().isNotEmpty ||
          list.evaluate().isNotEmpty ||
          empty.evaluate().isNotEmpty ||
          summary.evaluate().isNotEmpty,
      true,
    );
  });
}
