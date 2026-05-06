import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ sesuaikan dengan file asli kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_notifikasi.dart';

void main() {
  testWidgets('Summary widget render test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SummaryWidget(
            totalCritical: 2,
            totalWarning: 5,
          ),
        ),
      ),
    );

    // widget tampil
    expect(find.byType(SummaryWidget), findsOneWidget);

    // angka tampil
    expect(find.textContaining('2'), findsOneWidget);
    expect(find.textContaining('5'), findsOneWidget);
  });
}