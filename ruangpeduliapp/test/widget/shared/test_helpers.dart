import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/auth/login_screen.dart';
import 'package:ruangpeduliapp/auth/forgot_password_screen.dart';
import 'package:ruangpeduliapp/auth/role_selection_screen.dart';

/// Reusable widget builder for testing authentication screens
/// This helper consolidates all screen builders to avoid duplication
class AuthScreenBuilder {
  /// Build LoginScreen wrapped in MaterialApp
  static Widget buildLoginScreen({String role = 'Masyarakat'}) {
    return MaterialApp(
      home: LoginScreen(role: role),
    );
  }

  /// Build ForgotPasswordScreen wrapped in MaterialApp
  static Widget buildForgotPasswordScreen({String role = 'Masyarakat'}) {
    return MaterialApp(
      home: ForgotPasswordScreen(role: role),
    );
  }

  /// Build RoleSelectionScreen wrapped in MaterialApp
  static Widget buildRoleSelectionScreen() {
    return const MaterialApp(
      home: RoleSelectionScreen(),
    );
  }

  /// Build LoginScreen with navigation support for testing back button navigation
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

  /// Build ForgotPasswordScreen with navigation support for testing back button navigation
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
}
