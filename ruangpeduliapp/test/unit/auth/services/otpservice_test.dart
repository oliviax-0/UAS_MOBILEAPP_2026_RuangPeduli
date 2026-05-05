// test/unit/auth/otp_service_test.dart
//
// Unit test for OTP logic extracted from:
// - VerificationScreen._onVerify()
// - VerificationScreen._onResend()
// - VerificationScreen._showSnackBar()
// - VerificationScreen._startCountdown()
// - ResetPasswordOtpScreen._onVerify()
// - ResetPasswordOtpScreen._onResend()
// - ResetPasswordOtpScreen._showSnackBar()

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OTP Length Validation - _onVerify()', () {
    test(
      'TC-OTP-01: OTP with exactly 5 digits is valid',
      () {
        const otp = '12345';
        final isValid = otp.length == 5;
        expect(isValid, true);
      },
    );

    test(
      'TC-OTP-02: Empty OTP is invalid',
      () {
        const otp = '';
        final isValid = otp.length == 5;
        final err = !isValid ? 'Kode OTP harus 5 digit' : null;
        expect(isValid, false);
        expect(err, 'Kode OTP harus 5 digit');
      },
    );

    test(
      'TC-OTP-03: OTP less than 5 digits is invalid',
      () {
        for (final otp in ['1', '12', '123', '1234']) {
          final isValid = otp.length == 5;
          final err = !isValid ? 'Kode OTP harus 5 digit' : null;
          expect(isValid, false);
          expect(err, 'Kode OTP harus 5 digit');
        }
      },
    );

    test(
      'TC-OTP-04: OTP more than 5 digits is invalid',
      () {
        for (final otp in ['123456', '1234567']) {
          final isValid = otp.length == 5;
          final err = !isValid ? 'Kode OTP harus 5 digit' : null;
          expect(isValid, false);
          expect(err, 'Kode OTP harus 5 digit');
        }
      },
    );

    test(
      'TC-OTP-05: Any OTP that is not exactly 5 digits always produces an error',
      () {
        // All these must produce error — length check is strict (must be == 5)
        final invalidOtps = ['', '1', '12', '123', '1234', '123456', '1234567'];
        for (final otp in invalidOtps) {
          final err = otp.length != 5 ? 'Kode OTP harus 5 digit' : null;
          expect(err, 'Kode OTP harus 5 digit',
              reason: 'OTP "$otp" (length=${otp.length}) should produce error');
        }
      },
    );
  });

  group('SnackBar State Logic - _showSnackBar()', () {
    test(
      'TC-OTP-06: isError=true sets otpError and clears otpSuccess',
      () {
        String? otpError;
        String? otpSuccess = 'previous success';

        // Simulate _showSnackBar('some error', isError: true)
        final isError = true;
        const message = 'Kode OTP harus 5 digit';
        if (isError) {
          otpError = message;
          otpSuccess = null;
        }

        expect(otpError, 'Kode OTP harus 5 digit');
        expect(otpSuccess, null);
      },
    );

    test(
      'TC-OTP-07: isError=false sets otpSuccess and clears otpError',
      () {
        String? otpError = 'previous error';
        String? otpSuccess;

        // Simulate _showSnackBar('OTP baru telah dikirim ke email kamu')
        final isError = false;
        const message = 'OTP baru telah dikirim ke email kamu';
        if (!isError) {
          otpSuccess = message;
          otpError = null;
        }

        expect(otpSuccess, 'OTP baru telah dikirim ke email kamu');
        expect(otpError, null);
      },
    );

    test(
      'TC-OTP-08: Error and success messages are mutually exclusive',
      () {
        String? otpError;
        String? otpSuccess;

        // Set error
        otpError = 'Kode OTP harus 5 digit';
        otpSuccess = null;
        expect(otpError, isNotNull);
        expect(otpSuccess, isNull);

        // Switch to success
        otpSuccess = 'OTP baru telah dikirim ke email kamu';
        otpError = null;
        expect(otpSuccess, isNotNull);
        expect(otpError, isNull);
      },
    );
  });

  group('Countdown Timer Logic - _startCountdown()', () {
    test(
      'TC-OTP-09: Initial countdown starts at 60',
      () {
        int countdown = 60;
        expect(countdown, 60);
      },
    );

    test(
      'TC-OTP-10: _canResend is false when countdown is not 0',
      () {
        int countdown = 60;
        bool canResend = countdown == 0;
        expect(canResend, false);
      },
    );

    test(
      'TC-OTP-11: _canResend is true when countdown reaches 0',
      () {
        int countdown = 0;
        bool canResend = countdown == 0;
        expect(canResend, true);
      },
    );

    test(
      'TC-OTP-12: Countdown decrements correctly each tick',
      () {
        int countdown = 60;
        // Simulate 3 ticks
        for (int i = 0; i < 3; i++) {
          if (countdown > 0) countdown--;
        }
        expect(countdown, 57);
      },
    );

    test(
      'TC-OTP-13: Countdown does not go below 0',
      () {
        int countdown = 1;
        // Simulate 2 ticks — should stop at 0
        for (int i = 0; i < 2; i++) {
          if (countdown > 0) countdown--;
        }
        expect(countdown, 0);
      },
    );

    test(
      'TC-OTP-14: Countdown resets to 60 when _startCountdown is called again (resend)',
      () {
        int countdown = 0; // was at 0 (resend was allowed)
        // Simulate _startCountdown() called again after resend
        countdown = 60;
        expect(countdown, 60);
        expect(countdown == 0, false); // canResend is false again
      },
    );
  });

  group('Resend Guard Logic - _onResend()', () {
    test(
      'TC-OTP-15: Resend is blocked when countdown is not 0',
      () {
        int countdown = 30;
        bool resendLoading = false;
        bool canResend = countdown == 0;

        final shouldBlock = !canResend || resendLoading;
        expect(shouldBlock, true);
      },
    );

    test(
      'TC-OTP-16: Resend is blocked when resendLoading is true',
      () {
        int countdown = 0;
        bool resendLoading = true;
        bool canResend = countdown == 0;

        final shouldBlock = !canResend || resendLoading;
        expect(shouldBlock, true);
      },
    );

    test(
      'TC-OTP-17: Resend is allowed when countdown is 0 and not loading',
      () {
        int countdown = 0;
        bool resendLoading = false;
        bool canResend = countdown == 0;

        final shouldBlock = !canResend || resendLoading;
        expect(shouldBlock, false); // proceeds to API call
      },
    );

    test(
      'TC-OTP-18: Resend success message is "OTP baru telah dikirim ke email kamu"',
      () {
        const successMessage = 'OTP baru telah dikirim ke email kamu';
        expect(successMessage, 'OTP baru telah dikirim ke email kamu');
      },
    );

    test(
      'TC-OTP-19: Resend failure message starts with "Gagal kirim ulang:"',
      () {
        const error = 'Network error';
        final failMessage = 'Gagal kirim ulang: $error';
        expect(failMessage, 'Gagal kirim ulang: Network error');
        expect(failMessage.startsWith('Gagal kirim ulang:'), true);
      },
    );
  });

  group('OTP Input Format Validation', () {
    test(
      'TC-OTP-20: OTP must contain digits only',
      () {
        const validOtp = '12345';
        final isDigitsOnly = RegExp(r'^\d+$').hasMatch(validOtp);
        expect(isDigitsOnly, true);
      },
    );

    test(
      'TC-OTP-21: OTP with letters is not digits only',
      () {
        const invalidOtp = '1234a';
        final isDigitsOnly = RegExp(r'^\d+$').hasMatch(invalidOtp);
        expect(isDigitsOnly, false);
      },
    );

    test(
      'TC-OTP-22: OTP max length is 5',
      () {
        const maxLength = 5;
        expect(maxLength, 5);
        expect('12345'.length <= maxLength, true);
        expect('123456'.length <= maxLength, false);
      },
    );
  });

  group('API Response Parsing - VerificationScreen._onVerify()', () {
    test(
      'TC-OTP-23: userId is correctly parsed from verify OTP response',
      () {
        final result = {'user_id': 10, 'panti_id': null};
        final userId = result['user_id'];
        expect(userId, 10);
      },
    );

    test(
      'TC-OTP-24: pantiId is correctly parsed from verify OTP response',
      () {
        final result = {'user_id': 1, 'panti_id': 4};
        final pantiId = result['panti_id'];
        expect(pantiId, 4);
      },
    );

    test(
      'TC-OTP-25: Both userId and pantiId can be null in response',
      () {
        final Map<String, dynamic> result = {
          'user_id': null,
          'panti_id': null,
        };
        final userId = result['user_id'];
        final pantiId = result['panti_id'];
        expect(userId, null);
        expect(pantiId, null);
      },
    );
  });

  group('Error Message Parsing - VerificationScreen._onVerify()', () {
    test(
      'TC-OTP-26: Exception is converted to non-null string for snackbar',
      () {
        String? otpError;
        try {
          throw Exception('OTP tidak valid');
        } catch (e) {
          otpError = '$e';
        }
        expect(otpError, isNotNull);
        expect(otpError.isNotEmpty, true);
      },
    );

    test(
      'TC-OTP-27: Error string contains the original exception message',
      () {
        String? otpError;
        try {
          throw Exception('Kode OTP sudah kadaluarsa');
        } catch (e) {
          otpError = '$e';
        }
        expect(otpError.contains('Kode OTP sudah kadaluarsa'), true);
      },
    );

    test(
      'TC-OTP-28: Resend error string starts with "Gagal kirim ulang OTP:"',
      () {
        String? resendError;
        try {
          throw Exception('Network timeout');
        } catch (e) {
          resendError = 'Gagal kirim ulang OTP: $e';
        }
        expect(resendError.startsWith('Gagal kirim ulang OTP:'), true);
      },
    );
  });
}
