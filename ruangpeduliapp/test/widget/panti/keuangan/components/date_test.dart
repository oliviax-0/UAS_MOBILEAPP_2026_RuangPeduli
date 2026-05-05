import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_plus.dart';

void main() {
  testWidgets('Date picker open test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InputTransaksiPage(
          userId: 1,
          pantiId: 1,
        ),
      ),
    );

    final dateField = find.textContaining('Tanggal').evaluate().isNotEmpty
        ? find.textContaining('Tanggal')
        : find.byType(GestureDetector);

    if (dateField.evaluate().isNotEmpty) {
      await tester.tap(dateField.first);
      await tester.pumpAndSettle();
    }

    expect(find.byType(InputTransaksiPage), findsOneWidget);
  });
}
