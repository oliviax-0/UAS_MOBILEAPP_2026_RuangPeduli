import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/auth/login_screen.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';
import 'package:ruangpeduliapp/auth/forgot_password_screen.dart';
import '../shared/test_helpers.dart';

void main() {
  group('LoginScreen - Navigation & Integration', () {
    testWidgets(
      'TC-LG-01: AuthBackButton pops the screen',
      (WidgetTester tester) async {
        await tester
            .pumpWidget(AuthScreenBuilder.buildLoginScreenWithNavigation());

        await tester.tap(find.text('Go to Login'));
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);

        await tester.tap(find.byType(AuthBackButton));
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsNothing);
      },
    );

    testWidgets(
      'TC-LG-02: "Lupa Sandi?" navigates to ForgotPasswordScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildLoginScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Lupa Sandi?'));
        await tester.pumpAndSettle();

        expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      },
    );
  });

  group('LoginScreen - Form Validation', () {
    testWidgets(
      'TC-LG-03: Both email and password empty shows both validation errors',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildLoginScreen());
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsOneWidget);
        expect(find.text('Sandi wajib diisi'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LG-04: Only email empty shows email error',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildLoginScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Sandi'), 'Password123');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsOneWidget);
        expect(find.text('Sandi wajib diisi'), findsNothing);
      },
    );

    testWidgets(
      'TC-LG-05: Only password empty shows password error',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildLoginScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsNothing);
        expect(find.text('Sandi wajib diisi'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LG-06: No validation errors when both fields are filled',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildLoginScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Sandi'), 'Password123');
        await tester.ensureVisible(find.byType(DarkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DarkButton));
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsNothing);
        expect(find.text('Sandi wajib diisi'), findsNothing);
      },
    );
  });

  group('LoginScreen - InlineMessage', () {
    testWidgets(
      'TC-LG-07: General error message is not visible initially',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildLoginScreen());
        await tester.pumpAndSettle();

        final inlineMessages = tester.widgetList<InlineMessage>(
          find.byType(InlineMessage),
        );
        for (final msg in inlineMessages) {
          expect(msg.message == null || msg.message!.isEmpty, isTrue);
        }
      },
    );
  });

  group('LoginScreen - UI Elements', () {
    testWidgets(
      'TC-LG-08: "Log In" button is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildLoginScreen());
        await tester.pumpAndSettle();

        expect(find.byType(DarkButton), findsOneWidget);
        expect(find.text('Log In'), findsWidgets);
      },
    );

    testWidgets(
      'TC-LG-09: "Log In dengan Google" text is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildLoginScreen());
        await tester.pumpAndSettle();

        expect(find.text('Log In dengan Google'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LG-10: "Lupa Sandi?" text is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(AuthScreenBuilder.buildLoginScreen());
        await tester.pumpAndSettle();

        expect(find.text('Lupa Sandi?'), findsOneWidget);
      },
    );
  });

  group('LoginScreen - Role Display', () {
    testWidgets(
      'TC-LG-11: Role "Masyarakat" is displayed correctly',
      (WidgetTester tester) async {
        await tester
            .pumpWidget(AuthScreenBuilder.buildLoginScreen(role: 'Masyarakat'));
        await tester.pumpAndSettle();

        expect(find.text('Masyarakat'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LG-12: Role "Panti Sosial" is displayed correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
            AuthScreenBuilder.buildLoginScreen(role: 'Panti Sosial'));
        await tester.pumpAndSettle();

        expect(find.text('Panti Sosial'), findsOneWidget);
      },
    );
  });
}
