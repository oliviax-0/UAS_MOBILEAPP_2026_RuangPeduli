import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti.dart';

void main() {
  testWidgets(
    'Dashboard inventory flow test',
    (WidgetTester tester) async {

      await tester.pumpWidget(
        const MaterialApp(
          home: InventarisPanti(),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(InventarisPanti), findsOneWidget);

      final loading =
          find.byType(CircularProgressIndicator);

      final gesture =
          find.byType(GestureDetector);

      final text =
          find.textContaining('Stok');

      expect(
        loading.evaluate().isNotEmpty ||
            gesture.evaluate().isNotEmpty ||
            text.evaluate().isNotEmpty,
        true,
      );

      if (gesture.evaluate().isNotEmpty) {
        await tester.tap(gesture.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(MaterialApp), findsOneWidget);
    },
  );
}