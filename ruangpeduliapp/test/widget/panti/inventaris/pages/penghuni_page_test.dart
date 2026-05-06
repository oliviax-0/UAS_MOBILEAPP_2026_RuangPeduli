import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ import sesuai struktur asli kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_anggota.dart';

void main() {
  testWidgets('Penghuni page render test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: InventoryPantiAnggota(),
      ),
    );

    // render awal
    await tester.pump();

    // tunggu async selesai
    await tester.pumpAndSettle();

    // page tampil
    expect(find.byType(InventoryPantiAnggota), findsOneWidget);

    // scaffold tampil
    expect(find.byType(Scaffold), findsOneWidget);

    // kemungkinan komponen UI
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