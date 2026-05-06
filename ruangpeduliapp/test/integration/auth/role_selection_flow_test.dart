// integration_test/authentication/role_selection_flow_test.dart
//
// Integration test for Role Selection flow:
// RoleSelectionScreen → AuthOptionsScreen → back → RoleSelectionScreen

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ruangpeduliapp/auth/role_selection_screen.dart';
import 'package:ruangpeduliapp/auth/auth_options_screen.dart';
import '../../helpers/auth/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Role Selection Flow', () {
    // ─────────────────────────────────────────────
    // TC-RS-FLOW-01
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RS-FLOW-01: Selecting "Panti Sosial" navigates to AuthOptionsScreen with correct role',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        // Verify RoleSelectionScreen is shown
        expect(find.byType(RoleSelectionScreen), findsOneWidget);
        expect(find.text('Panti Sosial'), findsOneWidget);
        expect(find.text('Masyarakat'), findsOneWidget);

        // Select Panti Sosial
        await selectRole(tester, 'Panti Sosial');

        // Verify AuthOptionsScreen with correct role
        final authOptions = tester.widget<AuthOptionsScreen>(
          find.byType(AuthOptionsScreen),
        );
        expect(authOptions.role, 'Panti Sosial');
      },
    );

    // ─────────────────────────────────────────────
    // TC-RS-FLOW-02
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RS-FLOW-02: Selecting "Masyarakat" navigates to AuthOptionsScreen with correct role',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');

        final authOptions = tester.widget<AuthOptionsScreen>(
          find.byType(AuthOptionsScreen),
        );
        expect(authOptions.role, 'Masyarakat');
      },
    );

    // ─────────────────────────────────────────────
    // TC-RS-FLOW-03
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RS-FLOW-03: Back button on AuthOptionsScreen returns to RoleSelectionScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        // Go to AuthOptionsScreen
        await selectRole(tester, 'Masyarakat');
        expect(find.byType(AuthOptionsScreen), findsOneWidget);

        // Go back
        await goBack(tester);

        // Should be back at RoleSelectionScreen
        expect(find.byType(RoleSelectionScreen), findsOneWidget);
        expect(find.byType(AuthOptionsScreen), findsNothing);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RS-FLOW-04
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RS-FLOW-04: AuthOptionsScreen shows Log In and Sign Up options',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildAuthApp());
        await tester.pumpAndSettle();

        await selectRole(tester, 'Masyarakat');

        expect(find.text('Log In'), findsOneWidget);
        expect(find.text('Sign Up'), findsOneWidget);
      },
    );
  });
}
