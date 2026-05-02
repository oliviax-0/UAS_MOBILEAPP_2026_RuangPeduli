import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/auth/role_selection_screen.dart';
import 'package:ruangpeduliapp/auth/auth_options_screen.dart';
import '../shared/screen_builders.dart';

void main() {
  group('RoleSelectionScreen - _onSelect()', () {
    testWidgets(
      'TC-RS-01: Tapping "Panti Sosial" navigates to AuthOptionsScreen with role "Panti Sosial"',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildRoleSelectionScreen());
        await tester.pumpAndSettle();

        expect(find.text('Panti Sosial'), findsOneWidget);

        await tester.tap(find.text('Panti Sosial'));
        await tester.pumpAndSettle();

        expect(find.byType(AuthOptionsScreen), findsOneWidget);
      },
    );

    testWidgets(
      'TC-RS-02: Tapping "Masyarakat" navigates to AuthOptionsScreen with role "Masyarakat"',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildRoleSelectionScreen());
        await tester.pumpAndSettle();

        expect(find.text('Masyarakat'), findsOneWidget);

        await tester.tap(find.text('Masyarakat'));
        await tester.pumpAndSettle();

        expect(find.byType(AuthOptionsScreen), findsOneWidget);
      },
    );
    testWidgets(
      'TC-RS-03: AuthOptionsScreen receives correct role "Panti Sosial"',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildRoleSelectionScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Panti Sosial'));
        await tester.pumpAndSettle();

        final authOptionsWidget = tester.widget<AuthOptionsScreen>(
          find.byType(AuthOptionsScreen),
        );
        expect(authOptionsWidget.role, equals('Panti Sosial'));
      },
    );

    testWidgets(
      'TC-RS-04: AuthOptionsScreen receives correct role "Masyarakat"',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildRoleSelectionScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Masyarakat'));
        await tester.pumpAndSettle();

        final authOptionsWidget = tester.widget<AuthOptionsScreen>(
          find.byType(AuthOptionsScreen),
        );
        expect(authOptionsWidget.role, equals('Masyarakat'));
      },
    );

    testWidgets(
      'TC-RS-05: Both "Panti Sosial" and "Masyarakat" buttons are visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildRoleSelectionScreen());
        await tester.pumpAndSettle();

        expect(find.text('Panti Sosial'), findsOneWidget);
        expect(find.text('Masyarakat'), findsOneWidget);
      },
    );
    testWidgets(
      'TC-RS-06: RoleSelectionScreen role buttons are no longer visible after navigation',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildRoleSelectionScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Panti Sosial'));
        await tester.pumpAndSettle();

        expect(find.text('Pilih peran Anda'), findsNothing);
      },
    );
    testWidgets(
      'TC-RS-07: Back button on AuthOptionsScreen returns to RoleSelectionScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildRoleSelectionScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Masyarakat'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        expect(find.byType(RoleSelectionScreen), findsOneWidget);
      },
    );
  });
}
