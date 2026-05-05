import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_panti.dart';

void main() {
  testWidgets('DashCard render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeuanganPanti(
            userId: null,
            pantiId: null,
          ),
        ),
      ),
    );

    expect(find.byType(KeuanganPanti), findsOneWidget);
    expect(find.textContaining('Saldo'), findsWidgets);

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
  });
}
