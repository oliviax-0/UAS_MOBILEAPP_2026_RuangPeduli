import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Empty state render test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Belum ada data'),
          ),
        ),
      ),
    );

    // text empty state tampil
    expect(find.text('Belum ada data'), findsOneWidget);

    // scaffold tampil
    expect(find.byType(Scaffold), findsOneWidget);
  });
}