import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/profile_panti.dart';

void main() {
  testWidgets('ProfilePanti post feed render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePanti(
          pantiId: 1,
          userId: 1,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ProfilePanti), findsOneWidget);
    expect(find.byType(Column), findsWidgets);
  });
}