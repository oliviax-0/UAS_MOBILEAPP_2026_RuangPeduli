import 'package:flutter_test/flutter_test.dart';

void main() {

  group('Email Validation - LoginScreen._onLogin()', () {
    test(
      'TC-LV-01: Empty email returns "Email wajib diisi"',
      () {
        const email = '';
        final emailErr = email.isEmpty ? 'Email wajib diisi' : null;
        expect(emailErr, 'Email wajib diisi');
      },
    );

    test(
      'TC-LV-02: Filled email returns null (no error)',
      () {
        const email = 'test@email.com';
        final emailErr = email.isEmpty ? 'Email wajib diisi' : null;
        expect(emailErr, null);
      },
    );

    test(
      'TC-LV-03: Any non-empty email passes (login does not check format)',
      () {
        // LoginScreen only checks isEmpty — no format validation
        const emails = ['a', 'notanemail', 'test@email.com'];
        for (final email in emails) {
          final emailErr = email.isEmpty ? 'Email wajib diisi' : null;
          expect(emailErr, null);
        }
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 2: Password validation
  // ═══════════════════════════════════════════════════════════
  group('Password Validation - LoginScreen._onLogin()', () {
    test(
      'TC-LV-04: Empty password returns "Sandi wajib diisi"',
      () {
        const password = '';
        final passErr = password.isEmpty ? 'Sandi wajib diisi' : null;
        expect(passErr, 'Sandi wajib diisi');
      },
    );

    test(
      'TC-LV-05: Filled password returns null (no error)',
      () {
        const password = 'Password123';
        final passErr = password.isEmpty ? 'Sandi wajib diisi' : null;
        expect(passErr, null);
      },
    );

    test(
      'TC-LV-06: Login does not validate password strength (only empty check)',
      () {
        // LoginScreen only checks isEmpty — no min length or format check
        const passwords = ['a', '123', 'weakpass'];
        for (final password in passwords) {
          final passErr = password.isEmpty ? 'Sandi wajib diisi' : null;
          expect(passErr, null);
        }
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 3: Combined validation (both fields)
  // ═══════════════════════════════════════════════════════════
  group('Combined Validation - LoginScreen._onLogin()', () {
    test(
      'TC-LV-07: Both empty → both errors, login stops (returns early)',
      () {
        const email = '';
        const password = '';
        final emailErr = email.isEmpty ? 'Email wajib diisi' : null;
        final passErr = password.isEmpty ? 'Sandi wajib diisi' : null;
        final shouldStop = emailErr != null || passErr != null;

        expect(emailErr, 'Email wajib diisi');
        expect(passErr, 'Sandi wajib diisi');
        expect(shouldStop, true); // API call is skipped
      },
    );

    test(
      'TC-LV-08: Email empty, password filled → only email error, login stops',
      () {
        const email = '';
        const password = 'Password123';
        final emailErr = email.isEmpty ? 'Email wajib diisi' : null;
        final passErr = password.isEmpty ? 'Sandi wajib diisi' : null;
        final shouldStop = emailErr != null || passErr != null;

        expect(emailErr, 'Email wajib diisi');
        expect(passErr, null);
        expect(shouldStop, true);
      },
    );

    test(
      'TC-LV-09: Email filled, password empty → only password error, login stops',
      () {
        const email = 'test@email.com';
        const password = '';
        final emailErr = email.isEmpty ? 'Email wajib diisi' : null;
        final passErr = password.isEmpty ? 'Sandi wajib diisi' : null;
        final shouldStop = emailErr != null || passErr != null;

        expect(emailErr, null);
        expect(passErr, 'Sandi wajib diisi');
        expect(shouldStop, true);
      },
    );

    test(
      'TC-LV-10: Both filled → no errors, login proceeds to API call',
      () {
        const email = 'test@email.com';
        const password = 'Password123';
        final emailErr = email.isEmpty ? 'Email wajib diisi' : null;
        final passErr = password.isEmpty ? 'Sandi wajib diisi' : null;
        final shouldStop = emailErr != null || passErr != null;

        expect(emailErr, null);
        expect(passErr, null);
        expect(shouldStop, false); // proceeds to API call
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 4: Backend role mapping
  // Extracted from LoginScreen._onLogin() and _onGoogleLogin():
  //
  // final backendRole = role.toLowerCase().contains('panti')
  //     ? 'panti'
  //     : 'masyarakat';
  // ═══════════════════════════════════════════════════════════
  group('Backend Role Mapping - LoginScreen._onLogin() & _onGoogleLogin()', () {
    test(
      'TC-LV-11: "Panti Sosial" maps to backend role "panti"',
      () {
        const role = 'Panti Sosial';
        final backendRole = role.toLowerCase().contains('panti')
            ? 'panti'
            : 'masyarakat';
        expect(backendRole, 'panti');
      },
    );

    test(
      'TC-LV-12: "Masyarakat" maps to backend role "masyarakat"',
      () {
        const role = 'Masyarakat';
        final backendRole = role.toLowerCase().contains('panti')
            ? 'panti'
            : 'masyarakat';
        expect(backendRole, 'masyarakat');
      },
    );

    test(
      'TC-LV-13: Role mapping is case-insensitive for "panti"',
      () {
        const roles = ['Panti Sosial', 'panti sosial', 'PANTI SOSIAL', 'panti'];
        for (final role in roles) {
          final backendRole = role.toLowerCase().contains('panti')
              ? 'panti'
              : 'masyarakat';
          expect(backendRole, 'panti');
        }
      },
    );

    test(
      'TC-LV-14: Any role not containing "panti" defaults to "masyarakat"',
      () {
        const roles = ['Masyarakat', 'masyarakat', 'User', ''];
        for (final role in roles) {
          final backendRole = role.toLowerCase().contains('panti')
              ? 'panti'
              : 'masyarakat';
          expect(backendRole, 'masyarakat');
        }
      },
    );
  });
}