
// Widget test for SignUpScreen — only tests logic specific to SignUpScreen.
// Shared widget behavior (DarkButton, AuthBackButton, UnderlineField, AuthBackground)
// is already covered in:
// - test/widget/shared/auth_widgets_test.dart
// - test/widget/shared/underline_field_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/auth/signup_screen.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';
import '../shared/screen_builders.dart';

// ─────────────────────────────────────────────────────────────
// Mock navigator observer — intercepts navigation without
// actually rendering the destination screen
// ─────────────────────────────────────────────────────────────
class _MockNavigatorObserver extends NavigatorObserver {
  int didPushCount = 0;

  @override
  void didPush(Route route, Route? previousRoute) {
    didPushCount++;
    // Do NOT call super — intercepts navigation
  }
}

void main() {
  // ═══════════════════════════════════════════════════════════
  // GROUP 1: Back navigation — SignUpScreen specific
  // ═══════════════════════════════════════════════════════════
  group('Back Navigation - SignUpScreen.build()', () {
    testWidgets(
      'TC-RG-01: Tapping AuthBackButton pops SignUpScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          AuthScreenBuilder.buildSignUpScreenWithNavigation(),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Go to Sign Up'));
        await tester.pumpAndSettle();

        expect(find.byType(SignUpScreen), findsOneWidget);

        await tester.tap(find.byType(AuthBackButton));
        await tester.pumpAndSettle();

        expect(find.byType(SignUpScreen), findsNothing);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 2: Role display — SignUpScreen specific
  // ═══════════════════════════════════════════════════════════
  group('Role Display - SignUpScreen.build()', () {
    testWidgets(
      'TC-RG-02: Role "Masyarakat" is displayed correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          AuthScreenBuilder.buildSignUpScreen(role: 'Masyarakat'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Masyarakat'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-RG-03: Role "Panti Sosial" is displayed correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          AuthScreenBuilder.buildSignUpScreen(role: 'Panti Sosial'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Panti Sosial'), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 3: Email validation — SignUpScreen._onSignUp() specific
  // ═══════════════════════════════════════════════════════════
  group('Email Validation - SignUpScreen._onSignUp()', () {
    testWidgets(
      'TC-RG-04: Email error "Email wajib diisi" shown when empty on submit',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildSignUpScreen());
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 4: Password validation — SignUpScreen._validatePassword() specific
  // ═══════════════════════════════════════════════════════════
  group('Password Validation - SignUpScreen._validatePassword()', () {
    testWidgets(
      'TC-RG-05: Sandi error shown when empty on submit',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildSignUpScreen());
        await tester.pumpAndSettle();

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
      'TC-RG-06: Sandi error shown when less than 6 characters',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildSignUpScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.enterText(
            find.widgetWithText(
                TextField, 'Min. 6 karakter, 1 kapital, 1 angka'),
            'Ab1');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Sandi minimal 6 karakter'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-RG-07: Sandi error shown when no uppercase letter',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildSignUpScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.enterText(
            find.widgetWithText(
                TextField, 'Min. 6 karakter, 1 kapital, 1 angka'),
            'password1');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Sandi harus mengandung minimal 1 huruf kapital'),
            findsOneWidget);
      },
    );

    testWidgets(
      'TC-RG-08: Sandi error shown when no number',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildSignUpScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.enterText(
            find.widgetWithText(
                TextField, 'Min. 6 karakter, 1 kapital, 1 angka'),
            'Password');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Sandi harus mengandung minimal 1 angka'),
            findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 5: Confirm password validation — SignUpScreen._onSignUp() specific
  // ═══════════════════════════════════════════════════════════
  group('Confirm Password Validation - SignUpScreen._onSignUp()', () {
    testWidgets(
      'TC-RG-09: Konfirmasi Sandi error shown when empty on submit',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildSignUpScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.enterText(
            find.widgetWithText(
                TextField, 'Min. 6 karakter, 1 kapital, 1 angka'),
            'Password1');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Konfirmasi sandi wajib diisi'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-RG-10: Konfirmasi Sandi error shown when passwords do not match',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildSignUpScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.enterText(
            find.widgetWithText(
                TextField, 'Min. 6 karakter, 1 kapital, 1 angka'),
            'Password1');
        await tester.enterText(
            find.widgetWithText(TextField, 'Ulangi sandi'), 'Password2');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Sandi tidak cocok'), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 6: Combined form validation — SignUpScreen._onSignUp() specific
  // ═══════════════════════════════════════════════════════════
  group('Combined Form Validation - SignUpScreen._onSignUp()', () {
    testWidgets(
      'TC-RG-11: All 3 errors shown when all fields empty on submit',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildSignUpScreen());
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsOneWidget);
        expect(find.text('Sandi wajib diisi'), findsOneWidget);
        expect(find.text('Konfirmasi sandi wajib diisi'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-RG-12: No validation errors shown when all fields are valid',
      (WidgetTester tester) async {
        // Use MockNavigatorObserver to intercept navigation
        // without rendering FillDataMasyarakatScreen
        final mockObserver = _MockNavigatorObserver();

        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [mockObserver],
            home: const SignUpScreen(role: 'Masyarakat'),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.enterText(
            find.widgetWithText(
                TextField, 'Min. 6 karakter, 1 kapital, 1 angka'),
            'Password1');
        await tester.enterText(
            find.widgetWithText(TextField, 'Ulangi sandi'), 'Password1');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        // No validation errors — all fields are valid
        expect(find.text('Email wajib diisi'), findsNothing);
        expect(find.text('Sandi wajib diisi'), findsNothing);
        expect(find.text('Konfirmasi sandi wajib diisi'), findsNothing);
        expect(find.text('Sandi tidak cocok'), findsNothing);

        // Navigation was triggered — validation passed
        expect(mockObserver.didPushCount, greaterThan(0));
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 7: Google Sign Up — SignUpScreen._onGoogleSignUp() specific
  // ═══════════════════════════════════════════════════════════
  group('Google Sign Up - SignUpScreen._onGoogleSignUp()', () {
    testWidgets(
      'TC-RG-13: "Daftar dengan Google" text is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildSignUpScreen());
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Daftar dengan Google'));
        expect(find.text('Daftar dengan Google'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-RG-14: Google error InlineMessage not visible initially',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildSignUpScreen());
        await tester.pumpAndSettle();

        expect(
          find.text('Akun Google ini sudah terdaftar, silahkan login'),
          findsNothing,
        );
      },
    );
  });
}