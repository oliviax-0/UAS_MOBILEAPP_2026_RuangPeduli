import 'package:flutter/material.dart';
import 'package:ruangpeduliapp/auth/login_screen.dart';
import 'package:ruangpeduliapp/auth/forgot_password_screen.dart';
import 'package:ruangpeduliapp/auth/role_selection_screen.dart';

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
}
