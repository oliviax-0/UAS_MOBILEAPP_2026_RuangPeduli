import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_plus.dart';

void main() {
  testWidgets('Input field fill test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InputTransaksiPage(
          userId: 1,
          pantiId: 1,
        ),
      ),
    );

    final fields = find.byType(TextField);
    expect(fields, findsWidgets);

    if (fields.evaluate().isNotEmpty) {
      await tester.enterText(fields.first, '10000');
      await tester.pump();
    }

    if (fields.evaluate().length >= 2) {
      await tester.enterText(fields.at(1), 'Test catatan');
      await tester.pump();
    }

    expect(find.text('10.000'), findsOneWidget);
    expect(find.text('Test catatan'), findsWidgets);
  });
}
