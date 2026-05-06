import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ import sesuai struktur asli kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_notifikasi.dart';

void main() {
  testWidgets('Notif page render test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: InventoryPantiNotifikasi(),
      ),
    );

    // render awal
    await tester.pump();

    // tunggu async selesai
    await tester.pumpAndSettle();

    // page tampil
    expect(find.byType(InventoryPantiNotifikasi), findsOneWidget);

    // scaffold tampil
    expect(find.byType(Scaffold), findsOneWidget);

    // kemungkinan state UI
    final loading = find.byType(CircularProgressIndicator);
    final list = find.byType(ListView);
    final empty = find.textContaining('Belum');
    final refresh = find.byIcon(Icons.refresh);

    expect(
      loading.evaluate().isNotEmpty ||
          list.evaluate().isNotEmpty ||
          empty.evaluate().isNotEmpty ||
          refresh.evaluate().isNotEmpty,
      true,
    );
  });
}