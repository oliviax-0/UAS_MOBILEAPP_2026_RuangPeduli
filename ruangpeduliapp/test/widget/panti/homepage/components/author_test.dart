import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_berita_panti.dart';

void main() {
  testWidgets('AuthorVoting render & tap test', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthorVoting(
            authorName: 'Test Author',
            onProfileTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.byType(AuthorVoting), findsOneWidget);
    expect(find.text('Test Author'), findsOneWidget);

    await tester.tap(find.byType(AuthorVoting));
    await tester.pump();

    expect(tapped, true);
  });
}
