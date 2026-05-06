// test/helpers/auth/test_helpers.dart
//
// Shared helpers and utilities for all integration tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';
import 'package:ruangpeduliapp/auth/role_selection_screen.dart';
import 'package:ruangpeduliapp/auth/auth_options_screen.dart';
import 'package:ruangpeduliapp/auth/login_screen.dart';
import 'package:ruangpeduliapp/auth/signup_screen.dart';

// ─────────────────────────────────────────────────────────────
// App builder — starts from RoleSelectionScreen
// ─────────────────────────────────────────────────────────────
Widget buildAuthApp() {
  return const MaterialApp(
    home: RoleSelectionScreen(),
  );
}

// ─────────────────────────────────────────────────────────────
// Navigation helpers
// ─────────────────────────────────────────────────────────────

/// Navigate from RoleSelectionScreen to AuthOptionsScreen
Future<void> selectRole(WidgetTester tester, String role) async {
  await tester.tap(find.text(role).first);
  await tester.pumpAndSettle();
  expect(find.byType(AuthOptionsScreen), findsOneWidget);
}

/// Navigate from AuthOptionsScreen to LoginScreen
Future<void> goToLogin(WidgetTester tester) async {
  // Find DarkButton containing 'Log In' text specifically
  // AuthOptionsScreen has 2 DarkButtons — Log In and Sign Up
  final buttons = find.byType(DarkButton);
  // Log In is always the FIRST DarkButton in AuthOptionsScreen
  await tester.tap(buttons.first);
  await tester.pumpAndSettle();
  expect(find.byType(LoginScreen), findsOneWidget);
}

/// Navigate from AuthOptionsScreen to SignUpScreen
Future<void> goToSignUp(WidgetTester tester) async {
  // Find the Sign Up button specifically (not Google Sign Up)
  final signUpButton = find.widgetWithText(DarkButton, 'Sign Up');

  // Scroll to make the button visible
  await tester.dragUntilVisible(
    signUpButton,
    find.byType(SingleChildScrollView),
    const Offset(0, -100),
  );
  await tester.pumpAndSettle();

  // Tap the Sign Up button
  await tester.tap(signUpButton);
  await tester.pumpAndSettle();

  // Verify navigation
  expect(find.byType(SignUpScreen), findsOneWidget);
}

/// Fill login form with email and password
Future<void> fillLoginForm(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(
      find.widgetWithText(TextField, 'Masukan Email').first, email);
  await tester.enterText(
      find.widgetWithText(TextField, 'Masukan Sandi').first, password);
}

/// Fill signup form with email, password and confirm password
Future<void> fillSignUpForm(
  WidgetTester tester, {
  required String email,
  required String password,
  required String confirmPassword,
}) async {
  await tester.enterText(
      find.widgetWithText(TextField, 'Masukan Email').first, email);
  await tester.enterText(
      find
          .widgetWithText(TextField, 'Min. 6 karakter, 1 kapital, 1 angka')
          .first,
      password);
  await tester.enterText(
      find.widgetWithText(TextField, 'Ulangi sandi').first, confirmPassword);
}

/// Tap the single DarkButton on current screen
/// Use this only when there is exactly ONE DarkButton visible
Future<void> tapDarkButton(WidgetTester tester) async {
  // Find first DarkButton (the submit button on SignUpScreen)
  await tester.ensureVisible(find.byType(DarkButton).first);
  await tester.pumpAndSettle();

  await tester.tap(find.byType(DarkButton).first);
  await tester.pumpAndSettle();
}

/// Tap DarkButton by its label text
/// Use this when there are multiple DarkButtons on screen
Future<void> tapDarkButtonWithLabel(WidgetTester tester, String label) async {
  final button = find.widgetWithText(DarkButton, label).first;
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pump();
}

/// Go back using AuthBackButton
Future<void> goBack(WidgetTester tester) async {
  await tester.tap(find.byType(AuthBackButton).first);
  await tester.pumpAndSettle();
}

/// Tap DarkButton by its text
Future<void> tapDarkButtonWithText(WidgetTester tester,
    {String? buttonText}) async {
  // If buttonText is provided, find button by text
  if (buttonText != null) {
    await tester.ensureVisible(find.ancestor(
      of: find.text(buttonText),
      matching: find.byType(DarkButton),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.ancestor(
      of: find.text(buttonText),
      matching: find.byType(DarkButton),
    ));
  } else {
    // Default: find the first DarkButton on SignUpScreen
    final signUpButtons = find.byWidgetPredicate(
      (widget) => widget is DarkButton,
    );

    await tester.ensureVisible(signUpButtons.first);
    await tester.pumpAndSettle();

    await tester.tap(signUpButtons.first);
  }

  await tester.pumpAndSettle();
}
