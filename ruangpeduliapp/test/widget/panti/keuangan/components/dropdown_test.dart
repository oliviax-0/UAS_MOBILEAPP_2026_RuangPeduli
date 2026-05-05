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

    await tester.pump(const Duration(seconds: 1));

    final dropdown = find.byType(DropdownButton);

    if (dropdown.evaluate().isNotEmpty) {
      await tester.tap(dropdown.first);
      await tester.pumpAndSettle();

      final item = find.byType(DropdownMenuItem);

      if (item.evaluate().isNotEmpty) {
        await tester.tap(item.first);
        await tester.pumpAndSettle();
      }
    }

    expect(find.text('Jenis Pemasukan'), findsOneWidget);
    expect(find.byType(InputTransaksiPage), findsOneWidget);
  });
}
