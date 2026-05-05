import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_panti.dart';

void main() {
  testWidgets('Visibility toggle test', (WidgetTester tester) async {
    bool isVisible = true;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: DashCard(
                title: 'Saldo',
                amount: 100000.0,
                isVisible: isVisible,
                onToggle: () {
                  setState(() {
                    isVisible = !isVisible;
                  });
                },
              ),
            );
          },
        ),
      ),
    );

    // Awalnya visible
    expect(find.byIcon(Icons.visibility), findsOneWidget);

    // Tap toggle
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    // Setelah toggle jadi hidden
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });
}
