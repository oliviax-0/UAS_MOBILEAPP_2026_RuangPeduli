import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/auth/role_selection_screen.dart';
import 'package:ruangpeduliapp/auth/auth_options_screen.dart';

void main() {
  // Helper to build RoleSelectionScreen inside a testable app
  Widget buildTestApp() {
    return const MaterialApp(
      home: RoleSelectionScreen(),
    );
  }

  group('RoleSelectionScreen - _onSelect()', () {
    // ─────────────────────────────────────────────
    // TC-RS-01: Tap "Panti Sosial" button
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RS-01: Tapping "Panti Sosial" navigates to AuthOptionsScreen with role "Panti Sosial"',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle(); // wait for animation

        // Verify "Panti Sosial" button exists
        expect(find.text('Panti Sosial'), findsOneWidget);

        // Tap the button
        await tester.tap(find.text('Panti Sosial'));
        await tester.pumpAndSettle();

        // Should navigate to AuthOptionsScreen
        expect(find.byType(AuthOptionsScreen), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RS-02: Tap "Masyarakat" button
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RS-02: Tapping "Masyarakat" navigates to AuthOptionsScreen with role "Masyarakat"',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Verify "Masyarakat" button exists
        expect(find.text('Masyarakat'), findsOneWidget);

        // Tap the button
        await tester.tap(find.text('Masyarakat'));
        await tester.pumpAndSettle();

        // Should navigate to AuthOptionsScreen
        expect(find.byType(AuthOptionsScreen), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RS-03: Correct role passed for "Panti Sosial"
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RS-03: AuthOptionsScreen receives correct role "Panti Sosial"',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Panti Sosial'));
        await tester.pumpAndSettle();

        // Find the AuthOptionsScreen widget and verify its role property
        final authOptionsWidget = tester.widget<AuthOptionsScreen>(
          find.byType(AuthOptionsScreen),
        );
        expect(authOptionsWidget.role, equals('Panti Sosial'));
      },
    );

    // ─────────────────────────────────────────────
    // TC-RS-04: Correct role passed for "Masyarakat"
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RS-04: AuthOptionsScreen receives correct role "Masyarakat"',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Masyarakat'));
        await tester.pumpAndSettle();

        final authOptionsWidget = tester.widget<AuthOptionsScreen>(
          find.byType(AuthOptionsScreen),
        );
        expect(authOptionsWidget.role, equals('Masyarakat'));
      },
    );

    // ─────────────────────────────────────────────
    // TC-RS-05: Both role buttons are visible on screen
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RS-05: Both "Panti Sosial" and "Masyarakat" buttons are visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.text('Panti Sosial'), findsOneWidget);
        expect(find.text('Masyarakat'), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RS-06: RoleSelectionScreen is not shown after navigation
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RS-06: RoleSelectionScreen role buttons are no longer visible after navigation',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Panti Sosial'));
        await tester.pumpAndSettle();

        // After navigating, the role buttons should no longer be in view
        expect(find.text('Pilih peran Anda'), findsNothing);
      },
    );

    // ─────────────────────────────────────────────
    // TC-RS-07: Back button on AuthOptionsScreen returns to RoleSelectionScreen
    // ─────────────────────────────────────────────
    testWidgets(
      'TC-RS-07: Back button on AuthOptionsScreen returns to RoleSelectionScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Navigate to AuthOptionsScreen
        await tester.tap(find.text('Masyarakat'));
        await tester.pumpAndSettle();

        // Tap back button (AuthBackButton)
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        // Should be back at RoleSelectionScreen
        expect(find.byType(RoleSelectionScreen), findsOneWidget);
      },
    );
  });
}