// test/unit/validators/password_validator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/auth/validator/passvalidator.dart';

void main() {
  group('PasswordValidator', () {
    test('TC-PV-01: Should return false when password < 6 chars', () {
      expect(PasswordValidator.validate('Pass1'), false);
    });

    test('TC-PV-02: Should return false when no uppercase', () {
      expect(PasswordValidator.validate('password1'), false);
    });

    test('TC-PV-03: Should return false when no number', () {
      expect(PasswordValidator.validate('Password'), false);
    });

    test('TC-PV-04: Should return true when all conditions met', () {
      expect(PasswordValidator.validate('Password1'), true);
    });
  });
}

// lib/auth/validators/password_validator.dart
class PasswordValidator {
  static String? validate(String password) {
    if (password.isEmpty) return 'Sandi wajib diisi';
    if (password.length < 6) return 'Sandi minimal 6 karakter';
    if (!password.contains(RegExp(r'[A-Z]'))) return 'Sandi harus memiliki 1 huruf kapital';
    if (!password.contains(RegExp(r'[0-9]'))) return 'Sandi harus memiliki 1 angka';
    return null; // Valid
  }
}

// main.dart
String? error = PasswordValidator.validate(_passwordController.text);
if (error != null) {
  // show error
}
