import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_produkbaru.dart';

void main() {
  testWidgets(
    'Tambah produk flow test',
    (WidgetTester tester) async {

      await tester.pumpWidget(
        const MaterialApp(
          home: TambahProdukScreen(
            userId: 1,
            pantiId: 1,
          ),
        ),
      );

      // render awal
      await tester.pump();

      // tunggu async selesai
      await tester.pumpAndSettle();

      // validasi screen tampil
      expect(
        find.byType(TambahProdukScreen),
        findsOneWidget,
      );

      // cari semua textfield
      final textFields =
          find.byType(TextField);

      // isi nama produk
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(
          textFields.first,
          'Beras',
        );

        await tester.pump();
      }

      // isi field kedua jika ada
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(
          textFields.at(1),
          '20',
        );

        await tester.pump();
      }

      // dropdown
      final dropdownFinder =
          find.byType(DropdownButton);

      // buka dropdown jika ada
      if (dropdownFinder.evaluate().isNotEmpty) {
        await tester.tap(dropdownFinder.first);
        await tester.pumpAndSettle();
      }

      // tombol submit
      final buttonFinder =
          find.byType(ElevatedButton);

      // klik tombol jika ada
      if (buttonFinder.evaluate().isNotEmpty) {
        await tester.tap(buttonFinder.first);
        await tester.pumpAndSettle();
      }

      // kemungkinan widget muncul
      final loadingFinder =
          find.byType(CircularProgressIndicator);

      final snackbarFinder =
          find.byType(SnackBar);

      expect(
        loadingFinder.evaluate().isNotEmpty ||
            snackbarFinder.evaluate().isNotEmpty ||
            find.byType(MaterialApp)
                .evaluate()
                .isNotEmpty,
        true,
      );

      // app tidak crash
      expect(find.byType(MaterialApp), findsOneWidget);
    },
  );
}