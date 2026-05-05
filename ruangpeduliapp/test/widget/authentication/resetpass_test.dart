import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/auth/reset_password_new_screen.dart';
import '../shared/screen_builders.dart';

void main() {
  group('Email Display - ResetPasswordNewScreen.build()', () {
    testWidgets(
      'TC-RP-01: Email is displayed correctly',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          AuthScreenBuilder.buildResetPasswordScreen(email: 'test@email.com'),
        );
        await tester.pumpAndSettle();

        expect(find.text('test@email.com'), findsOneWidget);
      },
    );
  });

  group('Password Matching - ResetPasswordNewScreen._onResetPassword()', () {
    testWidgets(
      'TC-RP-02: Error shown when passwords do not match',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildResetPasswordScreen());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).at(0), 'Password1');
        await tester.enterText(find.byType(TextField).at(1), 'Password2');
        await tester.ensureVisible(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        expect(find.text('Sandi tidak cocok'), findsOneWidget);
      },
    );
  });

  group('Form Submission - ResetPasswordNewScreen._onResetPassword()', () {
    testWidgets(
      'TC-RP-03: Form submission successful with matching passwords',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildResetPasswordScreen());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).at(0), 'Password1');
        await tester.enterText(find.byType(TextField).at(1), 'Password1');
        await tester.ensureVisible(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        expect(find.text('Sandi tidak cocok'), findsNothing);
      },
    );

    testWidgets(
      'TC-RP-04: Error shown when either password field is empty',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildResetPasswordScreen());
        await tester.pumpAndSettle();

        // Only fill first password
        await tester.enterText(find.byType(TextField).at(0), 'Password1');
        await tester.ensureVisible(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Should show validation error for confirm password
        expect(
          find.text('Konfirmasi sandi wajib diisi'),
          findsOneWidget,
        );
      },
    );
  });
}
