import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/profile_panti.dart';

void main() {
  testWidgets('ProfilePanti post feed render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePanti(),
      ),
    );

    expect(find.byType(ProfilePanti), findsOneWidget);

    final loadingFinder = find.byType(CircularProgressIndicator);
    final emptyFinder = find.text('Belum ada postingan');

    expect(
      loadingFinder.evaluate().isNotEmpty || emptyFinder.evaluate().isNotEmpty,
      true,
    );
  });
}