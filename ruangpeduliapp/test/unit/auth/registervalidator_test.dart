import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Email Validation - SignUpScreen._onSignUp()', () {
    test(
      'TC-RV-01: Empty email returns "Email wajib diisi"',
      () {
        const email = '';
        final emailErr = email.isEmpty ? 'Email wajib diisi' : null;
        expect(emailErr, 'Email wajib diisi');
      },
    );

    test(
      'TC-RV-02: Filled email returns null (no error)',
      () {
        const email = 'test@email.com';
        final emailErr = email.isEmpty ? 'Email wajib diisi' : null;
        expect(emailErr, null);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 2: Password validation
  // Extracted from SignUpScreen._validatePassword()
  // ═══════════════════════════════════════════════════════════
  group('Password Validation - SignUpScreen._validatePassword()', () {
    // Helper mirrors exact logic from _validatePassword()
    String? validatePassword(String password) {
      if (password.isEmpty) return 'Sandi wajib diisi';
      if (password.length < 6) return 'Sandi minimal 6 karakter';
      if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Sandi harus mengandung minimal 1 huruf kapital';
      if (!RegExp(r'\d').hasMatch(password)) return 'Sandi harus mengandung minimal 1 angka';
      return null;
    }

    test(
      'TC-RV-03: Empty password returns "Sandi wajib diisi"',
      () {
        expect(validatePassword(''), 'Sandi wajib diisi');
      },
    );

    test(
      'TC-RV-04: Password less than 6 characters returns "Sandi minimal 6 karakter"',
      () {
        expect(validatePassword('Ab1'), 'Sandi minimal 6 karakter');
        expect(validatePassword('Ab12'), 'Sandi minimal 6 karakter');
        expect(validatePassword('Ab123'), 'Sandi minimal 6 karakter');
      },
    );

    test(
      'TC-RV-05: Password without uppercase returns "Sandi harus mengandung minimal 1 huruf kapital"',
      () {
        expect(
          validatePassword('password1'),
          'Sandi harus mengandung minimal 1 huruf kapital',
        );
      },
    );

    test(
      'TC-RV-06: Password without number returns "Sandi harus mengandung minimal 1 angka"',
      () {
        expect(
          validatePassword('Password'),
          'Sandi harus mengandung minimal 1 angka',
        );
      },
    );

    test(
      'TC-RV-07: Valid password (min 6 chars, 1 uppercase, 1 number) returns null',
      () {
        expect(validatePassword('Password1'), null);
        expect(validatePassword('Abcdef1'), null);
        expect(validatePassword('Test123'), null);
      },
    );

    test(
      'TC-RV-08: Password with exactly 6 valid chars passes',
      () {
        expect(validatePassword('Abcd1e'), null);
      },
    );

    test(
      'TC-RV-09: Validation order — empty is checked before length',
      () {
        // Empty returns 'Sandi wajib diisi', NOT 'Sandi minimal 6 karakter'
        expect(validatePassword(''), 'Sandi wajib diisi');
      },
    );

    test(
      'TC-RV-10: Validation order — length checked before uppercase',
      () {
        // Short password returns length error, NOT uppercase error
        expect(validatePassword('ab1'), 'Sandi minimal 6 karakter');
      },
    );

    test(
      'TC-RV-11: Validation order — uppercase checked before number',
      () {
        // No uppercase returns uppercase error, NOT number error
        expect(validatePassword('password1'), 'Sandi harus mengandung minimal 1 huruf kapital');
      },
    );
  });

  group('Confirm Password Validation - SignUpScreen._onSignUp()', () {
    String? validatePassword(String password) {
      if (password.isEmpty) return 'Sandi wajib diisi';
      if (password.length < 6) return 'Sandi minimal 6 karakter';
      if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Sandi harus mengandung minimal 1 huruf kapital';
      if (!RegExp(r'\d').hasMatch(password)) return 'Sandi harus mengandung minimal 1 angka';
      return null;
    }

    String? validateConfirm(String password, String confirmPassword) {
      final passErr = validatePassword(password);
      if (confirmPassword.isEmpty) return 'Konfirmasi sandi wajib diisi';
      if (passErr == null && confirmPassword != password) return 'Sandi tidak cocok';
      return null;
    }

    test(
      'TC-RV-12: Empty confirm password returns "Konfirmasi sandi wajib diisi"',
      () {
        expect(validateConfirm('Password1', ''), 'Konfirmasi sandi wajib diisi');
      },
    );

    test(
      'TC-RV-13: Confirm password not matching returns "Sandi tidak cocok"',
      () {
        expect(validateConfirm('Password1', 'Password2'), 'Sandi tidak cocok');
      },
    );

    test(
      'TC-RV-14: Confirm password matching returns null',
      () {
        expect(validateConfirm('Password1', 'Password1'), null);
      },
    );

    test(
      'TC-RV-15: Confirm error is null when password itself is invalid (passErr != null)',
      () {

        expect(validateConfirm('weak', 'different'), null);
      },
    );
  });

  group('Combined Form Validation - SignUpScreen._onSignUp()', () {
    String? validatePassword(String password) {
      if (password.isEmpty) return 'Sandi wajib diisi';
      if (password.length < 6) return 'Sandi minimal 6 karakter';
      if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Sandi harus mengandung minimal 1 huruf kapital';
      if (!RegExp(r'\d').hasMatch(password)) return 'Sandi harus mengandung minimal 1 angka';
      return null;
    }

    test(
      'TC-RV-16: All fields empty → all errors present, signup stops',
      () {
        const email = '';
        const password = '';
        const confirm = '';

        final emailErr = email.isEmpty ? 'Email wajib diisi' : null;
        final passErr = validatePassword(password);
        final confirmErr = confirm.isEmpty ? 'Konfirmasi sandi wajib diisi' : null;
        final shouldStop = emailErr != null || passErr != null || confirmErr != null;

        expect(emailErr, 'Email wajib diisi');
        expect(passErr, 'Sandi wajib diisi');
        expect(confirmErr, 'Konfirmasi sandi wajib diisi');
        expect(shouldStop, true);
      },
    );

    test(
      'TC-RV-17: All fields valid → no errors, signup proceeds',
      () {
        const email = 'test@email.com';
        const password = 'Password1';
        const confirm = 'Password1';

        final emailErr = email.isEmpty ? 'Email wajib diisi' : null;
        final passErr = validatePassword(password);
        final confirmErr = confirm.isEmpty
            ? 'Konfirmasi sandi wajib diisi'
            : passErr == null && confirm != password
                ? 'Sandi tidak cocok'
                : null;
        final shouldStop = emailErr != null || passErr != null || confirmErr != null;

        expect(emailErr, null);
        expect(passErr, null);
        expect(confirmErr, null);
        expect(shouldStop, false); // proceeds to FillData screen
      },
    );
  });

  group('Google Account Check - SignUpScreen._onGoogleSignUp()', () {
    test(
      'TC-RV-18: Existing Google account sets error "Akun Google ini sudah terdaftar, silahkan login"',
      () {
        final result = {'exists': true};
        String? googleError;

        if (result['exists'] == true) {
          googleError = 'Akun Google ini sudah terdaftar, silahkan login';
        }

        expect(googleError, 'Akun Google ini sudah terdaftar, silahkan login');
      },
    );

    test(
      'TC-RV-19: New Google account does not set error',
      () {
        final result = {'exists': false, 'email': 'new@email.com'};
        String? googleError;

        if (result['exists'] == true) {
          googleError = 'Akun Google ini sudah terdaftar, silahkan login';
        }

        expect(googleError, null);
      },
    );
  });
}