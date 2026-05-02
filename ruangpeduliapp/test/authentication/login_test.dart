import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/auth/login_screen.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';
import 'package:ruangpeduliapp/auth/forgot_password_screen.dart';

// ─────────────────────────────────────────────────────────────
// Helper: build LoginScreen inside a testable MaterialApp
// ─────────────────────────────────────────────────────────────
Widget buildLoginScreen({String role = 'Masyarakat'}) {
  return MaterialApp(
    home: LoginScreen(role: role),
  );
}

void main() {
  // ═══════════════════════════════════════════════════════════
  // GROUP 1: AuthBackground
  // ═══════════════════════════════════════════════════════════
  group('AuthBackground Widget', () {
    testWidgets(
      'TC-LG-01: AuthBackground is rendered on LoginScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        expect(find.byType(AuthBackground), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 2: AuthBackButton
  // ═══════════════════════════════════════════════════════════
  group('AuthBackButton Widget', () {
    testWidgets(
      'TC-LG-02: AuthBackButton is visible on LoginScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        expect(find.byType(AuthBackButton), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LG-03: Tapping AuthBackButton pops the screen',
      (WidgetTester tester) async {
        // Push LoginScreen on top of another screen so pop works
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(role: 'Masyarakat'),
                  ),
                ),
                child: const Text('Go to Login'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go to Login'));
        await tester.pumpAndSettle();

        // Verify LoginScreen is shown
        expect(find.byType(LoginScreen), findsOneWidget);

        // Tap back button
        await tester.tap(find.byType(AuthBackButton));
        await tester.pumpAndSettle();

        // LoginScreen should be popped
        expect(find.byType(LoginScreen), findsNothing);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 3: UnderlineField (Email)
  // ═══════════════════════════════════════════════════════════
  group('UnderlineField Email Widget', () {
    testWidgets(
      'TC-LG-04: Email UnderlineField is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Masukan Email'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LG-05: Email field accepts text input',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.pump();

        expect(find.text('test@email.com'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LG-06: Email error "Email wajib diisi" shown when email is empty on submit',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        // Scroll to DarkButton first (may be off-screen in test viewport)
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LG-07: Email error clears when user starts typing',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        // Trigger error
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();
        expect(find.text('Email wajib diisi'), findsOneWidget);

        // Type in email field
        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'a');
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsNothing);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 4: UnderlineField (Sandi) with toggle show/hide
  // ═══════════════════════════════════════════════════════════
  group('UnderlineField Sandi Widget', () {
    testWidgets(
      'TC-LG-08: Sandi UnderlineField is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        expect(find.text('Sandi'), findsOneWidget);
        expect(find.text('Masukan Sandi'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LG-09: Sandi field is obscured by default',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        // Find the password TextField
        final passwordField = tester.widget<TextField>(
          find.widgetWithText(TextField, 'Masukan Sandi'),
        );
        expect(passwordField.obscureText, isTrue);
      },
    );

    testWidgets(
      'TC-LG-10: Tapping visibility icon toggles password visibility',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        // Initially obscured
        final passwordFieldBefore = tester.widget<TextField>(
          find.widgetWithText(TextField, 'Masukan Sandi'),
        );
        expect(passwordFieldBefore.obscureText, isTrue);

        // Tap the visibility icon
        await tester.tap(find.byIcon(Icons.visibility_off_outlined));
        await tester.pump();

        // Should now be visible
        final passwordFieldAfter = tester.widget<TextField>(
          find.widgetWithText(TextField, 'Masukan Sandi'),
        );
        expect(passwordFieldAfter.obscureText, isFalse);
      },
    );

    testWidgets(
      'TC-LG-11: Sandi error "Sandi wajib diisi" shown when password is empty on submit',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        // Fill email but leave password empty
        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Sandi wajib diisi'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LG-12: Sandi error clears when user starts typing',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        // Trigger error
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();
        expect(find.text('Sandi wajib diisi'), findsOneWidget);

        // Type in password field
        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Sandi'), 'a');
        await tester.pump();

        expect(find.text('Sandi wajib diisi'), findsNothing);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 5: DarkButton ("Log In")
  // ═══════════════════════════════════════════════════════════
  group('DarkButton Log In Widget', () {
    testWidgets(
      'TC-LG-13: DarkButton "Log In" is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        expect(find.byType(DarkButton), findsOneWidget);
        expect(find.text('Log In'), findsWidgets);
      },
    );

    testWidgets(
      'TC-LG-14: Tapping "Log In" with both fields empty shows both errors',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsOneWidget);
        expect(find.text('Sandi wajib diisi'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LG-15: Tapping "Log In" with only email empty shows email error only',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        // Fill password only
        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Sandi'), 'Password123');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsOneWidget);
        expect(find.text('Sandi wajib diisi'), findsNothing);
      },
    );

    testWidgets(
      'TC-LG-16: Tapping "Log In" with only password empty shows password error only',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        // Fill email only
        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsNothing);
        expect(find.text('Sandi wajib diisi'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LG-17: No validation errors when both fields are filled',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Sandi'), 'Password123');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsNothing);
        expect(find.text('Sandi wajib diisi'), findsNothing);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 6: InlineMessage (General Error)
  // ═══════════════════════════════════════════════════════════
  group('InlineMessage Widget', () {
    testWidgets(
      'TC-LG-18: InlineMessage is not visible initially',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        // InlineMessage with null/empty message renders SizedBox.shrink
        final inlineMessages = tester.widgetList<InlineMessage>(
          find.byType(InlineMessage),
        );
        for (final msg in inlineMessages) {
          expect(msg.message == null || msg.message!.isEmpty, isTrue);
        }
      },
    );

    testWidgets(
      'TC-LG-19: InlineMessage general error clears when Log In is tapped again',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        // First tap with empty fields
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        // Fill both fields and tap again
        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Sandi'), 'Password123');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        // General error should be cleared (set to null in _onLogin)
        expect(find.text('Email wajib diisi'), findsNothing);
        expect(find.text('Sandi wajib diisi'), findsNothing);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 7: GestureDetector (Google Login)
  // ═══════════════════════════════════════════════════════════
  group('GestureDetector Google Login Widget', () {
    testWidgets(
      'TC-LG-20: "Log In dengan Google" text is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        expect(find.text('Log In dengan Google'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LG-21: Google login button is tappable when not loading',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        // Should be tappable — no exception
        await tester.tap(find.text('Log In dengan Google'),
            warnIfMissed: false);
        await tester.pump();

        // No crash = pass
        expect(find.text('Log In dengan Google'), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 8: "Lupa Sandi?" Navigation
  // ═══════════════════════════════════════════════════════════
  group('Lupa Sandi Navigation', () {
    testWidgets(
      'TC-LG-22: "Lupa Sandi?" text is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        expect(find.text('Lupa Sandi?'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LG-23: Tapping "Lupa Sandi?" navigates to ForgotPasswordScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Lupa Sandi?'));
        await tester.pumpAndSettle();

        expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 9: Role display
  // ═══════════════════════════════════════════════════════════
  group('Role Display', () {
    testWidgets(
      'TC-LG-24: Role "Masyarakat" is displayed correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen(role: 'Masyarakat'));
        await tester.pumpAndSettle();

        expect(find.text('Masyarakat'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LG-25: Role "Panti Sosial" is displayed correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildLoginScreen(role: 'Panti Sosial'));
        await tester.pumpAndSettle();

        expect(find.text('Panti Sosial'), findsOneWidget);
      },
    );
  });
}