// test/widget/authentication/register_test.dart
//
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

void main() {
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
        // Use onSignUpSuccess callback to intercept navigation
        // without rendering FillDataMasyarakatScreen (avoids pending timer error)
        bool signUpCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: SignUpScreen(
              role: 'Masyarakat',
              onSignUpSuccess: () {
                signUpCalled = true;
              },
            ),
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
        await tester.pumpAndSettle();

        expect(find.text('Email wajib diisi'), findsNothing);
        expect(find.text('Sandi wajib diisi'), findsNothing);
        expect(find.text('Konfirmasi sandi wajib diisi'), findsNothing);
        expect(find.text('Sandi tidak cocok'), findsNothing);

        expect(signUpCalled, true);
      },
    );
  });

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

  group('Full Valid Registration - SignUpScreen._onSignUp()', () {
    testWidgets(
      'TC-RG-18: Google Sign Up button is clickable and visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildSignUpScreen());
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Daftar dengan Google'));
        expect(find.text('Daftar dengan Google'), findsOneWidget);

        // Verify button is tappable
        await tester.tap(find.text('Daftar dengan Google'));
        await tester.pumpAndSettle();
      },
    );
  });
}
