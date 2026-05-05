import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResetPassword Logic Tests', () {
    group('Password Validation', () {
      test('TC-RP-LG-01: Should return error when password is empty', () {
        final result = validatePassword('');
        expect(result, 'Sandi wajib diisi');
      });

      test(
          'TC-RP-LG-02: Should return error when password is less than 8 characters',
          () {
        final result = validatePassword('Pass123');
        expect(result, 'Sandi minimal 8 karakter');
      });

      test('TC-RP-LG-03: Should return null when password is valid', () {
        final result = validatePassword('Password123');
        expect(result, null);
      });

      test('TC-RP-LG-04: Should accept password with exactly 8 characters', () {
        final result = validatePassword('Pass1234');
        expect(result, null);
      });
    });

    group('Password Confirmation Validation', () {
      test('TC-RP-LG-05: Should return error when confirm password is empty',
          () {
        final result = validateConfirmPassword('');
        expect(result, 'Konfirmasi sandi wajib diisi');
      });

      test('TC-RP-LG-06: Should return error when passwords do not match', () {
        final result = validatePasswordMatch('Password123', 'Password456');
        expect(result, 'Sandi tidak cocok');
      });

      test('TC-RP-LG-07: Should return null when passwords match', () {
        final result = validatePasswordMatch('Password123', 'Password123');
        expect(result, null);
      });

      test('TC-RP-LG-08: Should be case-sensitive when matching', () {
        final result = validatePasswordMatch('Password123', 'password123');
        expect(result, 'Sandi tidak cocok');
      });
    });

    group('Form Submission', () {
      test(
          'TC-RP-LG-09: Should return success when both passwords are valid and match',
          () {
        final password = 'Password123';
        final confirmPassword = 'Password123';

        final passwordError = validatePassword(password);
        final confirmError = validateConfirmPassword(confirmPassword);
        final matchError = validatePasswordMatch(password, confirmPassword);

        expect(passwordError, null);
        expect(confirmError, null);
        expect(matchError, null);
      });

      test('TC-RP-LG-10: Should return errors for invalid form submission', () {
        final password = '';
        final confirmPassword = '';

        final passwordError = validatePassword(password);
        final confirmError = validateConfirmPassword(confirmPassword);

        expect(passwordError, isNotNull);
        expect(confirmError, isNotNull);
      });
    });
  });
}

// Validation functions
String? validatePassword(String password) {
  if (password.isEmpty) {
    return 'Sandi wajib diisi';
  }
  if (password.length < 8) {
    return 'Sandi minimal 8 karakter';
  }
  return null;
}

String? validateConfirmPassword(String confirmPassword) {
  if (confirmPassword.isEmpty) {
    return 'Konfirmasi sandi wajib diisi';
  }
  return null;
}

String? validatePasswordMatch(String password, String confirmPassword) {
  if (password != confirmPassword) {
    return 'Sandi tidak cocok';
  }
  return null;
}
