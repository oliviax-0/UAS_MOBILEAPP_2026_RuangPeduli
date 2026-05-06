import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Loading indicator render test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    // loading tampil
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // scaffold tampil
    expect(find.byType(Scaffold), findsOneWidget);
  });
}