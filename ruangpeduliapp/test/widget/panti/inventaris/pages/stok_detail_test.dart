import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_stokmasuk.dart';

void main() {
  testWidgets('Stok detail page render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StokMasukScreen(),
      ),
    );

    // render awal
    await tester.pump();

    // tunggu async selesai
    await tester.pumpAndSettle();

    // page tampil
    expect(find.byType(StokMasukScreen), findsOneWidget);

    // scaffold tampil
    expect(find.byType(Scaffold), findsOneWidget);

    // kemungkinan state UI
    final loading = find.byType(CircularProgressIndicator);
    final list = find.byType(ListView);
    final search = find.byType(TextField);
    final empty = find.textContaining('Belum');

    expect(
      loading.evaluate().isNotEmpty ||
          list.evaluate().isNotEmpty ||
          search.evaluate().isNotEmpty ||
          empty.evaluate().isNotEmpty,
      true,
    );
  });
}
