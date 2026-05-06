// integration_test/helpers/test_helpers.dart
//
// Shared helpers and utilities for all integration tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';
import 'package:ruangpeduliapp/auth/role_selection_screen.dart';
import 'package:ruangpeduliapp/auth/auth_options_screen.dart';
import 'package:ruangpeduliapp/auth/login_screen.dart';
import 'package:ruangpeduliapp/auth/signup_screen.dart';
import 'package:ruangpeduliapp/auth/forgot_password_screen.dart';
import 'package:ruangpeduliapp/auth/reset_password_otp_screen.dart';
import 'package:ruangpeduliapp/auth/reset_password_new_screen.dart';
import 'package:ruangpeduliapp/auth/verification_screen.dart';

// ─────────────────────────────────────────────────────────────
// App builder — starts from RoleSelectionScreen
// (skipping SplashScreen animation for faster tests)
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
  await tester.tap(find.text(role));
  await tester.pumpAndSettle();
  expect(find.byType(AuthOptionsScreen), findsOneWidget);
}

/// Navigate from AuthOptionsScreen to LoginScreen
Future<void> goToLogin(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(DarkButton, 'Log In'));
  await tester.pumpAndSettle();
  expect(find.byType(LoginScreen), findsOneWidget);
}

/// Navigate from AuthOptionsScreen to SignUpScreen
Future<void> goToSignUp(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(DarkButton, 'Sign Up'));
  await tester.pumpAndSettle();
  expect(find.byType(SignUpScreen), findsOneWidget);
}

/// Fill login form with email and password
Future<void> fillLoginForm(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(
      find.widgetWithText(TextField, 'Masukan Email'), email);
  await tester.enterText(
      find.widgetWithText(TextField, 'Masukan Sandi'), password);
}

/// Fill signup form with email, password and confirm password
Future<void> fillSignUpForm(
  WidgetTester tester, {
  required String email,
  required String password,
  required String confirmPassword,
}) async {
  await tester.enterText(
      find.widgetWithText(TextField, 'Masukan Email'), email);
  await tester.enterText(
      find.widgetWithText(TextField, 'Min. 6 karakter, 1 kapital, 1 angka'),
      password);
  await tester.enterText(
      find.widgetWithText(TextField, 'Ulangi sandi'), confirmPassword);
}

/// Tap DarkButton and settle
Future<void> tapDarkButton(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(DarkButton));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(DarkButton));
  await tester.pump();
}

/// Go back using AuthBackButton
Future<void> goBack(WidgetTester tester) async {
  await tester.tap(find.byType(AuthBackButton));
  await tester.pumpAndSettle();
}
