// Integration test for Register flow:
// RoleSelection → AuthOptions → SignUp → validation

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ruangpeduliapp/auth/signup_screen.dart';
import 'package:ruangpeduliapp/auth/auth_options_screen.dart';
import '../../helpers/auth/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Register Flow', () {
    // ─────────────────────────────────────────────
    // TC-RG-FLOW-01
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RG-FLOW-01: Full navigation from RoleSelection to SignUpScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToSignUp(tester);

        expect(find.byType(SignUpScreen), findsOneWidget);
        expect(find.text('Sign Up'), findsOneWidget);
        expect(find.text('Masyarakat'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RG-FLOW-02
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RG-FLOW-02: Back button on SignUpScreen returns to AuthOptionsScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToSignUp(tester);
        expect(find.byType(SignUpScreen), findsOneWidget);

        await goBack(tester);

        expect(find.byType(AuthOptionsScreen), findsOneWidget);
        expect(find.byType(SignUpScreen), findsNothing);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RG-FLOW-03
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RG-FLOW-03: All fields empty shows all 3 errors',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToSignUp(tester);

        await tapDarkButton(tester);
        await tester.pumpAndSettle();

        expect(find.text('Email wajib diisi'), findsOneWidget);
        expect(find.text('Sandi wajib diisi'), findsOneWidget);
        expect(find.text('Konfirmasi sandi wajib diisi'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RG-FLOW-04
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RG-FLOW-04: Password less than 6 chars shows error',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToSignUp(tester);

        await fillSignUpForm(
          tester,
          email: 'test@email.com',
          password: 'Ab1',
          confirmPassword: 'Ab1',
        );

        await tapDarkButton(tester);
        await tester.pumpAndSettle();

        expect(find.text('Sandi minimal 6 karakter'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RG-FLOW-05
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RG-FLOW-05: Password without uppercase shows error',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToSignUp(tester);

        await fillSignUpForm(
          tester,
          email: 'test@email.com',
          password: 'password1',
          confirmPassword: 'password1',
        );

        await tapDarkButton(tester);
        await tester.pumpAndSettle();

        expect(find.text('Sandi harus mengandung minimal 1 huruf kapital'),
            findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RG-FLOW-06
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RG-FLOW-06: Password without number shows error',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToSignUp(tester);

        await fillSignUpForm(
          tester,
          email: 'test@email.com',
          password: 'Password',
          confirmPassword: 'Password',
        );

        await tapDarkButton(tester);
        await tester.pumpAndSettle();

        expect(find.text('Sandi harus mengandung minimal 1 angka'),
            findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RG-FLOW-07
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RG-FLOW-07: Passwords not matching shows error',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToSignUp(tester);

        await fillSignUpForm(
          tester,
          email: 'test@email.com',
          password: 'Password1',
          confirmPassword: 'Password2',
        );

        await tapDarkButton(tester);
        await tester.pumpAndSettle();

        expect(find.text('Sandi tidak cocok'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RG-FLOW-08
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RG-FLOW-08: Panti Sosial role shows correct role on SignUpScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Panti Sosial');
        await goToSignUp(tester);

        expect(find.text('Panti Sosial'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RG-FLOW-09
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RG-FLOW-09: "Daftar dengan Google" button is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToSignUp(tester);

        await tester.ensureVisible(find.text('Daftar dengan Google'));
        expect(find.text('Daftar dengan Google'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RG-FLOW-10
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RG-FLOW-10: Valid form submission succeeds',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToSignUp(tester);

        await fillSignUpForm(
          tester,
          email: 'valid@email.com',
          password: 'ValidPassword1',
          confirmPassword: 'ValidPassword1',
        );

        await tapDarkButton(tester);
        await tester.pumpAndSettle();
      },
    );

    // ─────────────────────────────────────────────
    // TC-RG-FLOW-11 (DELETED - Email validation doesn't happen on SignUpScreen)
    // ─────────────────────────────────────────────

    // ─────────────────────────────────────────────
    // TC-RG-FLOW-12
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RG-FLOW-12: Google signup button is clickable',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToSignUp(tester);

        await tester.ensureVisible(find.text('Daftar dengan Google'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Daftar dengan Google'));
        await tester.pumpAndSettle();
      },
    );

    // ─────────────────────────────────────────────
    // TC-RG-FLOW-13
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RG-FLOW-13: Form submission navigates to data entry screen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');
        await goToSignUp(tester);

        await fillSignUpForm(
          tester,
          email: 'valid@email.com',
          password: 'ValidPassword1',
          confirmPassword: 'ValidPassword1',
        );

        await tapDarkButton(tester);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('Isi Data'), findsOneWidget);
      },
    );
  });
}
