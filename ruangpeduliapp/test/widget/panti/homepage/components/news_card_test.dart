import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_panti.dart';

void main() {
  testWidgets('HomePanti news feed render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePanti(
          userId: 1,
          pantiId: 1,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HomePanti), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}