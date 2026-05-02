import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';

void main() {
  group('DarkButton Widget', () {
    testWidgets(
      'TC-DB-01: DarkButton displays label correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DarkButton(
                label: 'Kirim',
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('Kirim'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-DB-02: DarkButton is tappable',
      (WidgetTester tester) async {
        bool pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DarkButton(
                label: 'Kirim',
                onTap: () {
                  pressed = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(pressed, true);
      },
    );

    testWidgets(
      'TC-DB-03: DarkButton responds to visual state changes on tap',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DarkButton(
                label: 'Kirim',
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('Kirim'), findsOneWidget);
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Kirim'), findsOneWidget);
      },
    );
  });

  group('AuthBackButton Widget', () {
    testWidgets(
      'TC-ABB-01: AuthBackButton is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: AuthBackButton(),
              ),
            ),
          ),
        );

        expect(find.byType(AuthBackButton), findsOneWidget);
      },
    );

    testWidgets(
      'TC-ABB-02: AuthBackButton pops the screen when tapped',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      body: Center(
                        child: AuthBackButton(),
                      ),
                    ),
                  ),
                ),
                child: const Text('Go to Next'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go to Next'));
        await tester.pumpAndSettle();

        expect(find.byType(AuthBackButton), findsOneWidget);

        await tester.tap(find.byType(AuthBackButton));
        await tester.pumpAndSettle();

        expect(find.byType(AuthBackButton), findsNothing);
      },
    );
  });

  group('AuthBackground Widget', () {
    testWidgets(
      'TC-AB-01: AuthBackground is rendered with child',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthBackground(
                child: Center(
                  child: Text('Test Content'),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(AuthBackground), findsOneWidget);
        expect(find.text('Test Content'), findsOneWidget);
      },
    );
  });
}
