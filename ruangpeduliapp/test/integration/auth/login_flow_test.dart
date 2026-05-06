// Integration test for Login flow:
// RoleSelection → AuthOptions → Login → validation
// RoleSelection → AuthOptions → Login → Forgot Password → OTP → Reset Password

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ruangpeduliapp/auth/login_screen.dart';
import 'package:ruangpeduliapp/auth/auth_options_screen.dart';
import 'package:ruangpeduliapp/auth/forgot_password_screen.dart';
import '../../helpers/auth/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow', () {

    testWidgets(
      'TC-LG-FLOW-01: Full navigation from RoleSelection to LoginScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.text('Log In'), findsWidgets);
        expect(find.text('Masyarakat'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-LG-FLOW-02
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-LG-FLOW-02: Back button on LoginScreen returns to AuthOptionsScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);
        expect(find.byType(LoginScreen), findsOneWidget);

        await goBack(tester);

        expect(find.byType(AuthOptionsScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );

    // ─────────────────────────────────────────────
    // TC-LG-FLOW-03
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-LG-FLOW-03: Both fields empty shows both validation errors',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);
        await tapDarkButton(tester);

        expect(find.text('Email wajib diisi'), findsOneWidget);
        expect(find.text('Sandi wajib diisi'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-LG-FLOW-04
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-LG-FLOW-04: Only email empty shows email error only',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);
        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Sandi'), 'Password1');
        await tapDarkButton(tester);

        expect(find.text('Email wajib diisi'), findsOneWidget);
        expect(find.text('Sandi wajib diisi'), findsNothing);
      },
    );

    // ─────────────────────────────────────────────
    // TC-LG-FLOW-05
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-LG-FLOW-05: Only password empty shows password error only',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);
        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tapDarkButton(tester);

        expect(find.text('Email wajib diisi'), findsNothing);
        expect(find.text('Sandi wajib diisi'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-LG-FLOW-06
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-LG-FLOW-06: "Lupa Sandi?" navigates to ForgotPasswordScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);

        await tester.tap(find.text('Lupa Sandi?'));
        await tester.pumpAndSettle();

        expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-LG-FLOW-07
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-LG-FLOW-07: Back button on ForgotPasswordScreen returns to LoginScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);
        await tester.tap(find.text('Lupa Sandi?'));
        await tester.pumpAndSettle();

        expect(find.byType(ForgotPasswordScreen), findsOneWidget);

        await goBack(tester);

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(ForgotPasswordScreen), findsNothing);
      },
    );

    // ─────────────────────────────────────────────
    // TC-LG-FLOW-08
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-LG-FLOW-08: ForgotPassword empty email shows error',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);
        await tester.tap(find.text('Lupa Sandi?'));
        await tester.pumpAndSettle();

        await tapDarkButton(tester);

        expect(find.text('Email wajib diisi'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-LG-FLOW-09
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-LG-FLOW-09: "Log In dengan Google" button is visible on LoginScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);

        await tester.ensureVisible(find.text('Log In dengan Google'));
        expect(find.text('Log In dengan Google'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-LG-FLOW-10
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-LG-FLOW-10: Panti Sosial role shows correct role on LoginScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Panti Sosial');
        await goToLogin(tester);

        expect(find.text('Panti Sosial'), findsOneWidget);
      },
    );
  });
}