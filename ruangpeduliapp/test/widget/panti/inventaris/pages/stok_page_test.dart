import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_stokmasuk.dart';

void main() {
  testWidgets('StokPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StokMasukScreen(),
      ),
    );

    expect(find.byType(StokMasukScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    // kondisi: loading / list / empty
    final loading = find.byType(CircularProgressIndicator);
    final list = find.byType(ListView);
    final empty = find.textContaining('Belum');

    expect(
      loading.evaluate().isNotEmpty ||
          list.evaluate().isNotEmpty ||
          empty.evaluate().isNotEmpty,
      true,
    );
  });
}
