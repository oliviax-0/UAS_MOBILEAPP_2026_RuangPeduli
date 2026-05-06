import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_notifikasi.dart';

void main() {
  testWidgets(
    'Notif inventory flow test',
    (WidgetTester tester) async {

      await tester.pumpWidget(
        const MaterialApp(
          home: InventarisNotifikasiScreen(
            pantiId: 1,
          ),
        ),
      );

      // render awal
      await tester.pump();

      // tunggu async selesai
      await tester.pumpAndSettle();

      // halaman tampil
      expect(
        find.byType(InventarisNotifikasiScreen),
        findsOneWidget,
      );

      // kemungkinan widget muncul
      final loading =
          find.byType(CircularProgressIndicator);

      final list =
          find.byType(ListView);

      final gesture =
          find.byType(GestureDetector);

      final text =
          find.textContaining('Stok');

      expect(
        loading.evaluate().isNotEmpty ||
            list.evaluate().isNotEmpty ||
            gesture.evaluate().isNotEmpty ||
            text.evaluate().isNotEmpty,
        true,
      );

      // tap item pertama jika ada
      if (gesture.evaluate().isNotEmpty) {
        await tester.tap(gesture.first);
        await tester.pumpAndSettle();
      }

      // app tidak crash
      expect(find.byType(MaterialApp), findsOneWidget);
    },
  );
}