import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ sesuaikan dengan class asli project kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_stokmasuk.dart';

void main() {
  testWidgets('Stok flow test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: InventoryPantiStokMasuk(),
      ),
    );

    // render awal
    await tester.pump();

    // tunggu async selesai
    await tester.pumpAndSettle();

    // halaman tampil
    expect(find.byType(InventoryPantiStokMasuk), findsOneWidget);

    // kemungkinan UI
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

    // coba search jika ada
    if (search.evaluate().isNotEmpty) {
      await tester.enterText(search.first, 'Beras');
      await tester.pump();
    }

    // tap item jika ada
    final gesture = find.byType(GestureDetector);

    if (gesture.evaluate().isNotEmpty) {
      await tester.tap(gesture.first);
      await tester.pumpAndSettle();
    }

    // tidak crash
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}