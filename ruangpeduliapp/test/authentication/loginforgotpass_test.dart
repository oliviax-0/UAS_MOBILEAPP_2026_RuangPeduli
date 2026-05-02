import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/auth/forgot_password_screen.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';


Widget buildForgotPasswordScreen({String role = 'Masyarakat'}) {
  return MaterialApp(
    home: ForgotPasswordScreen(role: role),
  );
}

void main() {

  group('UnderlineField Email - ForgotPasswordScreen._onSubmit()', () {
    testWidgets(
      'TC-FP-01: Email UnderlineField is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Masukan Email'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-FP-02: Email field accepts text input',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.pump();

        expect(find.text('test@email.com'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-FP-03: Email error "Email wajib diisi" shown when email is empty on submit',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildForgotPasswordScreen());
        await tester.pumpAndSettle();

        // Leave email empty, scroll to button and tap
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-FP-04: Email error clears when user starts typing',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildForgotPasswordScreen());
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
      'TC-FP-05: No email error shown when email is filled',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildForgotPasswordScreen());
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
}
