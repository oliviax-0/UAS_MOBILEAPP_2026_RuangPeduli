import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/auth/login_screen.dart';
import 'package:ruangpeduliapp/auth/forgot_password_screen.dart';
import 'package:ruangpeduliapp/auth/role_selection_screen.dart';
import 'package:ruangpeduliapp/auth/signup_screen.dart';
import 'package:ruangpeduliapp/auth/reset_password_new_screen.dart';
import 'package:ruangpeduliapp/auth/reset_password_otp_screen.dart';
import 'package:ruangpeduliapp/auth/verification_screen.dart';

class AuthScreenBuilder {


  static Widget buildLoginScreen({String role = 'Masyarakat'}) {
    return MaterialApp(
      home: LoginScreen(role: role),
    );
  }

  static Widget buildForgotPasswordScreen({String role = 'Masyarakat'}) {
    return MaterialApp(
      home: ForgotPasswordScreen(role: role),
    );
  }

  static Widget buildRoleSelectionScreen() {
    return const MaterialApp(
      home: RoleSelectionScreen(),
    );
  }

  static Widget buildLoginScreenWithNavigation() {
    return MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(role: 'Masyarakat'),
            ),
          ),
          child: const Text('Go to Login'),
        ),
      ),
    );
  }

  static Widget buildForgotPasswordScreenWithNavigation() {
    return MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ForgotPasswordScreen(role: 'Masyarakat'),
            ),
          ),
          child: const Text('Go to Forgot Password'),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // NEW BUILDERS
  // ─────────────────────────────────────────────

  // ── SignUpScreen ──────────────────────────────
  static Widget buildSignUpScreen({String role = 'Masyarakat'}) {
    return MaterialApp(
      home: SignUpScreen(role: role),
    );
  }

  static Widget buildSignUpScreenWithNavigation({String role = 'Masyarakat'}) {
    return MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SignUpScreen(role: role),
            ),
          ),
          child: const Text('Go to Sign Up'),
        ),
      ),
    );
  }

  // ── ResetPasswordNewScreen ────────────────────
  static Widget buildResetPasswordNewScreen({
    String email = 'test@email.com',
    String otp = '12345',
    String role = 'Masyarakat',
  }) {
    return MaterialApp(
      home: ResetPasswordNewScreen(
        email: email,
        otp: otp,
        role: role,
      ),
    );
  }

  static Widget buildResetPasswordNewScreenWithNavigation({
    String email = 'test@email.com',
    String otp = '12345',
    String role = 'Masyarakat',
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResetPasswordNewScreen(
                email: email,
                otp: otp,
                role: role,
              ),
            ),
          ),
          child: const Text('Go to Reset Password'),
        ),
      ),
    );
  }

  // ── ResetPasswordOtpScreen ────────────────────
  static Widget buildResetPasswordOtpScreen({
    String email = 'test@email.com',
    String role = 'Masyarakat',
  }) {
    return MaterialApp(
      home: ResetPasswordOtpScreen(
        email: email,
        role: role,
      ),
    );
  }

  static Widget buildResetPasswordOtpScreenWithNavigation({
    String email = 'test@email.com',
    String role = 'Masyarakat',
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResetPasswordOtpScreen(
                email: email,
                role: role,
              ),
            ),
          ),
          child: const Text('Go to OTP Reset'),
        ),
      ),
    );
  }

  // ── VerificationScreen ────────────────────────
  static Widget buildVerificationScreen({
    String pendingId = 'pending_123',
    String email = 'test@email.com',
    String role = 'masyarakat',
  }) {
    return MaterialApp(
      home: VerificationScreen(
        pendingId: pendingId,
        email: email,
        role: role,
      ),
    );
  }

  static Widget buildVerificationScreenWithNavigation({
    String pendingId = 'pending_123',
    String email = 'test@email.com',
    String role = 'masyarakat',
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerificationScreen(
                pendingId: pendingId,
                email: email,
                role: role,
              ),
            ),
          ),
          child: const Text('Go to Verification'),
        ),
      ),
    );
  }
}