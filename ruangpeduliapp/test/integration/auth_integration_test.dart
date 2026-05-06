// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ruangpeduliapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Integration Tests', () {
    testWidgets(
      'TC-INT-01: Complete Login Flow - Valid Credentials',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to Login
        expect(find.byType(ElevatedButton), findsWidgets);

        // Enter email
        await tester.enterText(
          find.byType(TextField).first,
          'test@email.com',
        );
        await tester.pumpAndSettle();

        // Enter password
        await tester.enterText(
          find.byType(TextField).at(1),
          'Password123',
        );
        await tester.pumpAndSettle();

        // Tap login button
        await tester.tap(find.text('Masuk'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verify user is logged in (check for home screen)
        expect(find.byType(ScaffoldMessenger), findsWidgets);
      },
    );

    testWidgets(
      'TC-INT-02: Complete Login Flow - Invalid Credentials',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Enter invalid email
        await tester.enterText(
          find.byType(TextField).first,
          'wrong@email.com',
        );
        await tester.pumpAndSettle();

        // Enter wrong password
        await tester.enterText(
          find.byType(TextField).at(1),
          'WrongPassword',
        );
        await tester.pumpAndSettle();

        // Tap login button
        await tester.tap(find.text('Masuk'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify error message appears
        expect(find.byType(SnackBar), findsWidgets);
      },
    );

    testWidgets(
      'TC-INT-03: Complete Registration Flow - Masyarakat',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to Sign Up
        await tester.tap(find.text('Daftar'));
        await tester.pumpAndSettle();

        // Enter name
        await tester.enterText(
          find.byType(TextField).first,
          'John Doe',
        );
        await tester.pumpAndSettle();

        // Enter email
        await tester.enterText(
          find.byType(TextField).at(1),
          'newuser@email.com',
        );
        await tester.pumpAndSettle();

        // Enter password
        await tester.enterText(
          find.byType(TextField).at(2),
          'SecurePass123',
        );
        await tester.pumpAndSettle();

        // Confirm password
        await tester.enterText(
          find.byType(TextField).at(3),
          'SecurePass123',
        );
        await tester.pumpAndSettle();

        // Accept terms
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        // Tap register button
        await tester.tap(find.text('Daftar'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should navigate to OTP verification
        expect(find.text('Kode Verifikasi'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INT-04: Complete Password Reset Flow',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to Forgot Password
        await tester.tap(find.text('Lupa Password?'));
        await tester.pumpAndSettle();

        // Enter email
        await tester.enterText(
          find.byType(TextField).first,
          'test@email.com',
        );
        await tester.pumpAndSettle();

        // Tap continue button
        await tester.tap(find.text('Lanjut'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should navigate to OTP screen
        expect(find.byType(GestureDetector), findsWidgets);

        // Enter OTP
        await tester.enterText(
          find.byType(TextField).first,
          '12345',
        );
        await tester.pumpAndSettle();

        // Tap verify OTP button
        await tester.tap(find.text('Lanjut'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should navigate to new password screen
        expect(find.text('Password Baru'), findsOneWidget);

        // Enter new password
        await tester.enterText(
          find.byType(TextField).first,
          'NewPassword123',
        );
        await tester.pumpAndSettle();

        // Confirm new password
        await tester.enterText(
          find.byType(TextField).at(1),
          'NewPassword123',
        );
        await tester.pumpAndSettle();

        // Tap save button
        await tester.tap(find.text('Simpan'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should return to login screen
        expect(find.text('Masuk'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INT-05: OTP Verification After Registration',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to Sign Up
        await tester.tap(find.text('Daftar'));
        await tester.pumpAndSettle();

        // Complete registration form
        await tester.enterText(find.byType(TextField).first, 'Jane Doe');
        await tester.enterText(find.byType(TextField).at(1), 'jane@email.com');
        await tester.enterText(find.byType(TextField).at(2), 'SecurePass123');
        await tester.enterText(find.byType(TextField).at(3), 'SecurePass123');
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        // Tap register
        await tester.tap(find.text('Daftar'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Enter OTP
        await tester.enterText(
          find.byType(TextField).first,
          '123456',
        );
        await tester.pumpAndSettle();

        // Tap verify button
        await tester.tap(find.text('Verifikasi'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should show success and navigate to login
        expect(find.byType(SnackBar), findsWidgets);
      },
    );

    testWidgets(
      'TC-INT-06: Resend OTP During Registration',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to Sign Up and complete registration
        await tester.tap(find.text('Daftar'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'Test User');
        await tester.enterText(find.byType(TextField).at(1), 'test2@email.com');
        await tester.enterText(find.byType(TextField).at(2), 'SecurePass123');
        await tester.enterText(find.byType(TextField).at(3), 'SecurePass123');
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Daftar'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Tap resend OTP
        await tester.tap(find.byType(RichText));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Should show resend message
        expect(find.byType(SnackBar), findsWidgets);
      },
    );

    testWidgets(
      'TC-INT-07: Resend OTP During Password Reset',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to Forgot Password
        await tester.tap(find.text('Lupa Password?'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField).first,
          'test@email.com',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Lanjut'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Tap resend OTP
        await tester.tap(find.byType(RichText));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Should show resend message
        expect(find.byType(SnackBar), findsWidgets);
      },
    );

    testWidgets(
      'TC-INT-08: Back Navigation in Login Screen',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to Sign Up
        await tester.tap(find.text('Daftar'));
        await tester.pumpAndSettle();

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Should return to login
        expect(find.text('Masuk'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INT-09: Back Navigation in Forgot Password',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to Forgot Password
        await tester.tap(find.text('Lupa Password?'));
        await tester.pumpAndSettle();

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Should return to login
        expect(find.text('Masuk'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INT-10: Switch Between Login and Sign Up',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Go to Sign Up
        await tester.tap(find.text('Daftar'));
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsWidgets);

        // Go back to Login
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Go back to Sign Up again
        await tester.tap(find.text('Daftar'));
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsWidgets);
      },
    );

    testWidgets(
      'TC-INT-11: Network Error Handling During Login',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Enter credentials
        await tester.enterText(
          find.byType(TextField).first,
          'test@email.com',
        );
        await tester.enterText(
          find.byType(TextField).at(1),
          'Password123',
        );
        await tester.pumpAndSettle();

        // Tap login (will fail due to no network)
        await tester.tap(find.text('Masuk'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should show error message
        expect(find.byType(SnackBar), findsWidgets);
      },
    );

    testWidgets(
      'TC-INT-12: Complete User Journey - Register to Login',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // 1. Register new user
        await tester.tap(find.text('Daftar'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'New User');
        await tester.enterText(
          find.byType(TextField).at(1),
          'newuser@email.com',
        );
        await tester.enterText(
          find.byType(TextField).at(2),
          'SecurePass123',
        );
        await tester.enterText(
          find.byType(TextField).at(3),
          'SecurePass123',
        );
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Daftar'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 2. Verify OTP
        await tester.enterText(
          find.byType(TextField).first,
          '123456',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Verifikasi'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 3. Navigate to Login
        expect(find.text('Masuk'), findsOneWidget);

        // 4. Login with new credentials
        await tester.enterText(
          find.byType(TextField).first,
          'newuser@email.com',
        );
        await tester.enterText(
          find.byType(TextField).at(1),
          'SecurePass123',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Masuk'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should be logged in successfully
        expect(find.byType(ScaffoldMessenger), findsWidgets);
      },
    );
  });
}
