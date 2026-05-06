import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Tooltip render test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Tooltip(
              message: 'Refresh Data',
              child: Icon(Icons.refresh),
            ),
          ),
        ),
      ),
    );

    // icon tampil
    expect(find.byIcon(Icons.refresh), findsOneWidget);

    // trigger tooltip
    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.refresh)),
    );

    await tester.pump(const Duration(seconds: 1));

    // tooltip tampil
    expect(find.text('Refresh Data'), findsOneWidget);

    await gesture.up();
  });
}