import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_panti.dart';

void main() {
  testWidgets('HomePanti search bar render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePanti(
          userId: 1,
          pantiId: 1,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // HomePanti harus ada
    expect(find.byType(HomePanti), findsOneWidget);

    // Search TextField harus ada (dengan hint text 'Search')
    expect(find.byType(TextField), findsWidgets);
  });
}