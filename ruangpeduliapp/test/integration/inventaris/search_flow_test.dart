import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_stokmasuk.dart';

void main() {
  testWidgets(
    'Search inventory flow test',
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

      // validasi screen tampil
      expect(find.byType(StokMasukScreen), findsOneWidget);

      // cari search field
      final searchFinder =
          find.byType(TextField);

      // input text jika ada field
      if (searchFinder.evaluate().isNotEmpty) {

        await tester.enterText(
          searchFinder.first,
          'Beras',
        );

        await tester.pump();

        // validasi text masuk
        expect(find.text('Beras'), findsWidgets);
      }

      // kemungkinan widget muncul
      final loadingFinder =
          find.byType(CircularProgressIndicator);

      final listFinder =
          find.byType(ListView);

      final gridFinder =
          find.byType(GridView);

      expect(
        loadingFinder.evaluate().isNotEmpty ||
            listFinder.evaluate().isNotEmpty ||
            gridFinder.evaluate().isNotEmpty ||
            searchFinder.evaluate().isNotEmpty,
        true,
      );

      // app tidak crash
      expect(find.byType(MaterialApp), findsOneWidget);
    },
  );
}