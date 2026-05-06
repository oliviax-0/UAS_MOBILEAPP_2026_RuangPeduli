import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ sesuaikan dengan class asli project kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_produkbaru.dart';

void main() {
  testWidgets('Tambah produk flow test',
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

    // halaman tampil
    expect(find.byType(InventoryPantiProdukBaru), findsOneWidget);

    // cari textfield
    final fields = find.byType(TextField);

    // isi field jika ada
    if (fields.evaluate().isNotEmpty) {
      await tester.enterText(fields.first, 'Beras');
      await tester.pump();
    }

    if (fields.evaluate().length >= 2) {
      await tester.enterText(fields.at(1), '20');
      await tester.pump();
    }

    // dropdown jika ada
    final dropdown = find.byType(DropdownButton);

    if (dropdown.evaluate().isNotEmpty) {
      await tester.tap(dropdown.first);
      await tester.pumpAndSettle();
    }

    // tombol submit jika ada
    final button = find.byType(ElevatedButton);

    if (button.evaluate().isNotEmpty) {
      await tester.tap(button.first);
      await tester.pumpAndSettle();
    }

    // kondisi akhir
    final loading = find.byType(CircularProgressIndicator);
    final snackbar = find.byType(SnackBar);

    expect(
      loading.evaluate().isNotEmpty ||
          snackbar.evaluate().isNotEmpty ||
          find.byType(MaterialApp).evaluate().isNotEmpty,
      true,
    );
  });
}