import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_plus.dart';

void main() {
  testWidgets('Dropdown render & select test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InputTransaksiPage(
          userId: 1,
          pantiId: 1,
        ),
      ),
    );

    final dropdown = find.byType(DropdownButton);
    expect(dropdown, findsWidgets);

    // Buka dropdown pertama
    if (dropdown.evaluate().isNotEmpty) {
      await tester.tap(dropdown.first);
      await tester.pumpAndSettle();

      // Pilih item pertama jika ada
      final item = find.byType(DropdownMenuItem);

      if (item.evaluate().isNotEmpty) {
        await tester.tap(item.first);
        await tester.pumpAndSettle();
      }
    }

    expect(find.byType(InputTransaksiPage), findsOneWidget);
  });
}
