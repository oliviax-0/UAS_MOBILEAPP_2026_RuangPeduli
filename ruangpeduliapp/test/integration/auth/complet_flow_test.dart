// integration_test/main_flow/app_flow_test.dart
//
// Integration test for complete app authentication flow:
// Tests the full navigation path from start to end
// including RoleSelection, AuthOptions, Login, SignUp, and Forgot Password.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ruangpeduliapp/auth/role_selection_screen.dart';
import 'package:ruangpeduliapp/auth/auth_options_screen.dart';
import 'package:ruangpeduliapp/auth/login_screen.dart';
import 'package:ruangpeduliapp/auth/signup_screen.dart';
import 'package:ruangpeduliapp/auth/forgot_password_screen.dart';
import '../../helpers/auth/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full App Authentication Flow', () {
    // ─────────────────────────────────────────────
    // TC-APP-FLOW-01
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-APP-FLOW-01: Complete Masyarakat login path navigation',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        // Step 1: RoleSelection
        expect(find.byType(RoleSelectionScreen), findsOneWidget);

        // Step 2: Select Masyarakat → AuthOptions
        await selectRole(tester, 'Masyarakat');
        expect(find.byType(AuthOptionsScreen), findsOneWidget);

        // Step 3: Go to Login
        await goToLogin(tester);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.text('Masyarakat'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-APP-FLOW-02
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-APP-FLOW-02: Complete Panti Sosial login path navigation',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        // Step 1: RoleSelection
        expect(find.byType(RoleSelectionScreen), findsOneWidget);

        // Step 2: Select Panti Sosial → AuthOptions
        await selectRole(tester, 'Panti Sosial');
        expect(find.byType(AuthOptionsScreen), findsOneWidget);

        // Step 3: Go to Login
        await goToLogin(tester);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.text('Panti Sosial'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-APP-FLOW-03
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-APP-FLOW-03: Complete Masyarakat register path navigation',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        // Step 1: RoleSelection
        expect(find.byType(RoleSelectionScreen), findsOneWidget);

        // Step 2: Select Masyarakat → AuthOptions
        await selectRole(tester, 'Masyarakat');
        expect(find.byType(AuthOptionsScreen), findsOneWidget);

        // Step 3: Go to SignUp
        await goToSignUp(tester);
        expect(find.byType(SignUpScreen), findsOneWidget);
        expect(find.text('Masyarakat'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-APP-FLOW-04
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-APP-FLOW-04: Complete Panti Sosial register path navigation',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        // Step 1: RoleSelection
        expect(find.byType(RoleSelectionScreen), findsOneWidget);

        // Step 2: Select Panti Sosial → AuthOptions
        await selectRole(tester, 'Panti Sosial');

        // Step 3: Go to SignUp
        await goToSignUp(tester);
        expect(find.byType(SignUpScreen), findsOneWidget);
        expect(find.text('Panti Sosial'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-APP-FLOW-05
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-APP-FLOW-05: Complete forgot password path navigation',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        // Step 1-3: Navigate to LoginScreen
        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);

        // Step 4: Go to ForgotPassword
        await tester.tap(find.text('Lupa Sandi?'));
        await tester.pumpAndSettle();
        expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-APP-FLOW-06
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-APP-FLOW-06: Full back navigation from Login to RoleSelection',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        // Navigate forward
        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);
        expect(find.byType(LoginScreen), findsOneWidget);

        // Back to AuthOptions
        await goBack(tester);
        expect(find.byType(AuthOptionsScreen), findsOneWidget);

        // Back to RoleSelection
        await goBack(tester);
        expect(find.byType(RoleSelectionScreen), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-APP-FLOW-07
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-APP-FLOW-07: Full back navigation from SignUp to RoleSelection',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        // Navigate forward
        await selectRole(tester, 'Masyarakat');
        await goToSignUp(tester);
        expect(find.byType(SignUpScreen), findsOneWidget);

        // Back to AuthOptions
        await goBack(tester);
        expect(find.byType(AuthOptionsScreen), findsOneWidget);

        // Back to RoleSelection
        await goBack(tester);
        expect(find.byType(RoleSelectionScreen), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-APP-FLOW-08
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-APP-FLOW-08: Switching from Login to SignUp via AuthOptions',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        // Navigate to Login
        await selectRole(tester, 'Masyarakat');
        await goToLogin(tester);
        expect(find.byType(LoginScreen), findsOneWidget);

        // Back to AuthOptions
        await goBack(tester);
        expect(find.byType(AuthOptionsScreen), findsOneWidget);

        // Now go to SignUp
        await goToSignUp(tester);
        expect(find.byType(SignUpScreen), findsOneWidget);
      },
    );
  });
}
