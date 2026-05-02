import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/auth/forgot_password_screen.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';

Widget buildForgotPasswordScreen({String role = 'Masyarakat'}) {
  return MaterialApp(
    home: ForgotPasswordScreen(role: role),
  );
}

void main() {
  group('UnderlineField Email - ForgotPasswordScreen._onSubmit()', () {
    testWidgets(
      'TC-FP-01: Email UnderlineField is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Masukan Email'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-FP-02: Email field accepts text input',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.pump();

        expect(find.text('test@email.com'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-FP-03: Email error "Email wajib diisi" shown when email is empty on submit',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        // Leave email empty, scroll to button and tap
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-FP-04: Email error clears when user starts typing',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        // Trigger error first
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();
        expect(find.text('Email wajib diisi'), findsOneWidget);

        // Type in email field — error should clear
        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'a');
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsNothing);
      },
    );

    testWidgets(
      'TC-FP-05: No email error shown when email is filled',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsNothing);
      },
    );
  });

  group('DarkButton Kirim - ForgotPasswordScreen._onSubmit()', () {
    testWidgets(
      'TC-FP-06: DarkButton "Kirim" is visible on screen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        expect(find.byType(DarkButton), findsOneWidget);
        expect(find.text('Kirim'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-FP-07: Tapping "Kirim" with empty email shows error and does NOT navigate',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsOneWidget);
        expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      },
    );

    testWidgets(
      'TC-FP-08: DarkButton label changes to "Memproses..." when loading',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));

        await tester.pump();

        expect(find.text('Memproses...'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-FP-09: DarkButton is not tappable again while loading',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Memproses...'), findsOneWidget);
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Memproses...'), findsOneWidget);
      },
    );
  });

  group('AuthBackButton - ForgotPasswordScreen.build()', () {
    testWidgets(
      'TC-FP-10: AuthBackButton is visible on ForgotPasswordScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        expect(find.byType(AuthBackButton), findsOneWidget);
      },
    );

    testWidgets(
      'TC-FP-11: Tapping AuthBackButton pops ForgotPasswordScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ForgotPasswordScreen(role: 'Masyarakat'),
                  ),
                ),
                child: const Text('Go to Forgot Password'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go to Forgot Password'));
        await tester.pumpAndSettle();

        expect(find.byType(ForgotPasswordScreen), findsOneWidget);

        await tester.tap(find.byType(AuthBackButton));
        await tester.pumpAndSettle();

        expect(find.byType(ForgotPasswordScreen), findsNothing);
      },
    );
  });
}
