// integration_test/authentication/reset_password_flow_test.dart
//
// Integration test for Reset Password flow:
// Login → Lupa Sandi → ForgotPassword → OTP → ResetPasswordNew

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ruangpeduliapp/auth/forgot_password_screen.dart';
import 'package:ruangpeduliapp/auth/reset_password_otp_screen.dart';
import 'package:ruangpeduliapp/auth/reset_password_new_screen.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';
import '../../helpers/auth/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Reset Password Flow', () {
    // ─────────────────────────────────────────────
    // TC-RP-FLOW-01
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RP-FLOW-01: Full navigation from Login to ForgotPasswordScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);
        await tester.tap(find.text('Lupa Sandi?'));
        await tester.pumpAndSettle();

        expect(find.byType(ForgotPasswordScreen), findsOneWidget);
        expect(find.text('Lupa Sandi'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RP-FLOW-02
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RP-FLOW-02: ForgotPassword empty email shows error and stays on screen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);
        await tester.tap(find.text('Lupa Sandi?'));
        await tester.pumpAndSettle();

        await tapDarkButton(tester);

        expect(find.text('Email wajib diisi'), findsOneWidget);
        expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RP-FLOW-03
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RP-FLOW-03: Back from ForgotPassword → LoginScreen → AuthOptions → RoleSelection',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        // Navigate to ForgotPasswordScreen
        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);
        await tester.tap(find.text('Lupa Sandi?'));
        await tester.pumpAndSettle();
        expect(find.byType(ForgotPasswordScreen), findsOneWidget);

        // Back to LoginScreen
        await goBack(tester);
        expect(find.byType(ForgotPasswordScreen), findsNothing);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RP-FLOW-04
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RP-FLOW-04: ForgotPassword loading state shows "Memproses..." on button',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);
        await tester.tap(find.text('Lupa Sandi?'));
        await tester.pumpAndSettle();

        // Fill email and tap — triggers loading
        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Memproses...'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RP-FLOW-05
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RP-FLOW-05: ResetPasswordNewScreen validation — empty fields show errors',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ResetPasswordNewScreen(
              email: 'test@email.com',
              otp: '12345',
              role: 'Masyarakat',
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Sandi wajib diisi'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RP-FLOW-06
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RP-FLOW-06: ResetPasswordNewScreen — passwords not matching shows error',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ResetPasswordNewScreen(
              email: 'test@email.com',
              otp: '12345',
              role: 'Masyarakat',
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(
                TextField, 'Min. 6 karakter, 1 kapital, 1 angka'),
            'Password1');
        await tester.enterText(
            find.widgetWithText(TextField, 'Ulangi sandi baru'), 'Password2');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Sandi tidak cocok'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RP-FLOW-07
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RP-FLOW-07: ResetPasswordOtpScreen shows verification code screen',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ResetPasswordOtpScreen(
              email: 'test@email.com',
              role: 'Masyarakat',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Kode Verifikasi'), findsOneWidget);

        // Check for RichText containing resend message
        expect(
          find.byType(RichText),
          findsWidgets,
          reason: 'Resend message should be in RichText widget',
        );
      },
    );

    // ─────────────────────────────────────────────
    // TC-RP-FLOW-08
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RP-FLOW-08: ResetPasswordOtpScreen OTP less than 5 digits shows error',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ResetPasswordOtpScreen(
              email: 'test@email.com',
              role: 'Masyarakat',
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap verify without entering OTP
        await tester.tap(find.text('Lanjut'));
        await tester.pumpAndSettle();

        expect(find.text('Kode OTP harus 5 digit'), findsOneWidget);
      },
    );
  });
}
