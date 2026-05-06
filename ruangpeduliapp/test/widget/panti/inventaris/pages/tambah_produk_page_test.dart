import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ import sesuai struktur asli kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_produkbaru.dart';

void main() {
  testWidgets('Tambah produk page render test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: InventoryPantiProdukBaru(),
      ),
    );

    // render awal
    await tester.pump();

    // tunggu async selesai
    await tester.pumpAndSettle();

    // page tampil
    expect(find.byType(InventoryPantiProdukBaru), findsOneWidget);

    // scaffold tampil
    expect(find.byType(Scaffold), findsOneWidget);

    // kemungkinan komponen form
    final fields = find.byType(TextField);
    final dropdown = find.byType(DropdownButton);
    final loading = find.byType(CircularProgressIndicator);
    final button = find.byType(ElevatedButton);

    expect(
      fields.evaluate().isNotEmpty ||
          dropdown.evaluate().isNotEmpty ||
          loading.evaluate().isNotEmpty ||
          button.evaluate().isNotEmpty,
      true,
    );
  });
}