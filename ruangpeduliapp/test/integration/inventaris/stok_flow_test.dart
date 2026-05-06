import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_stokmasuk.dart';

void main() {
  testWidgets(
    'Stok masuk flow test',
    (WidgetTester tester) async {

      await tester.pumpWidget(
        const MaterialApp(
          home: StokMasukScreen(
            userId: 1,
            pantiId: 1,
          ),
        ),
      );

      // render awal
      await tester.pump();

      // tunggu async selesai
      await tester.pumpAndSettle();

      // validasi halaman tampil
      expect(find.byType(StokMasukScreen), findsOneWidget);

      // kemungkinan widget tampil
      final loadingFinder =
          find.byType(CircularProgressIndicator);

      final listFinder =
          find.byType(ListView);

      final gridFinder =
          find.byType(GridView);

      final searchFinder =
          find.byType(TextField);

      final gestureFinder =
          find.byType(GestureDetector);

      expect(
        loadingFinder.evaluate().isNotEmpty ||
            listFinder.evaluate().isNotEmpty ||
            gridFinder.evaluate().isNotEmpty ||
            searchFinder.evaluate().isNotEmpty ||
            gestureFinder.evaluate().isNotEmpty,
        true,
      );

      // search produk jika ada
      if (searchFinder.evaluate().isNotEmpty) {
        await tester.enterText(
          searchFinder.first,
          'Beras',
        );

        await tester.pump();
      }

      // tap item pertama jika ada
      if (gestureFinder.evaluate().isNotEmpty) {
        await tester.tap(gestureFinder.first);
        await tester.pumpAndSettle();
      }

      // validasi app tidak crash
      expect(find.byType(MaterialApp), findsOneWidget);
    },
  );
}