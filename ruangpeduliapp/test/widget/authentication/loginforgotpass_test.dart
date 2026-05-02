import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/auth/forgot_password_screen.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';
import '../shared/screen_builders.dart';

void main() {
  group('ForgotPasswordScreen - Form Validation', () {
    testWidgets(
      'TC-FP-01: Empty email shows error "Email wajib diisi"',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-FP-02: Email error clears when user starts typing',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        // Trigger error first
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();
        expect(find.text('Email wajib diisi'), findsOneWidget);

        // Type in email field — error should clear
        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'a');
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsNothing);
      },
    );

    testWidgets(
      'TC-FP-03: No email error shown when email is filled',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsNothing);
      },
    );
  });

  group('ForgotPasswordScreen - DarkButton Submit', () {
    testWidgets(
      'TC-FP-04: DarkButton "Kirim" is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        expect(find.byType(DarkButton), findsOneWidget);
        expect(find.text('Kirim'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-FP-05: Tapping "Kirim" with empty email shows error',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsOneWidget);
        expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      },
    );
  });

  group('ForgotPasswordScreen - Navigation', () {
    testWidgets(
      'TC-FP-06: AuthBackButton pops the screen',
      (WidgetTester tester) async {
        await tester.pumpWidget(
            AuthScreenBuilder.buildForgotPasswordScreenWithNavigation());

        await tester.tap(find.text('Go to Forgot Password'));
        await tester.pumpAndSettle();

        expect(find.byType(ForgotPasswordScreen), findsOneWidget);

        await tester.tap(find.byType(AuthBackButton));
        await tester.pumpAndSettle();

        expect(find.byType(ForgotPasswordScreen), findsNothing);
      },
    );
  });
}
