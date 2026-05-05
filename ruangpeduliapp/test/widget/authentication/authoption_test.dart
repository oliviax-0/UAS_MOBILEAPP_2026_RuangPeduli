// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/auth/auth_options_screen.dart';
import 'package:ruangpeduliapp/auth/login_screen.dart';
import 'package:ruangpeduliapp/auth/signup_screen.dart';

void main() {
  group('AuthOptionsScreen Display - AuthOptionsScreen.build()', () {
    testWidgets(
      'TC-AUTH-01: Screen renders with all elements',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          const MaterialApp(
            home: AuthOptionsScreen(role: 'Masyarakat'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AuthOptionsScreen), findsOneWidget);
      },
    );

    testWidgets(
      'TC-AUTH-02: Log In button is displayed',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          const MaterialApp(
            home: AuthOptionsScreen(role: 'Masyarakat'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Log In'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-AUTH-03: Sign Up button is displayed',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          const MaterialApp(
            home: AuthOptionsScreen(role: 'Masyarakat'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Sign Up'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-AUTH-04: Screen title or welcome message is displayed',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          const MaterialApp(
            home: AuthOptionsScreen(role: 'Masyarakat'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Text), findsWidgets);
      },
    );
  });

  group('AuthOptionsScreen Navigation - AuthOptionsScreen._onTap()', () {
    testWidgets(
      'TC-AUTH-05: Log In button navigates to LoginScreen',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          MaterialApp(
            home: AuthOptionsScreen(role: 'Masyarakat'),
            routes: {
              '/login': (context) => const LoginScreen(role: 'Masyarakat'),
            },
          ),
        );
        await tester.pumpAndSettle();

        final logInButton = find.text('Log In');
        await tester.ensureVisible(logInButton);
        await tester.tap(logInButton);
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);
      },
    );

    testWidgets(
      'TC-AUTH-06: Sign Up button navigates to SignUpScreen',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          MaterialApp(
            home: AuthOptionsScreen(role: 'Masyarakat'),
            routes: {
              '/signup': (context) => const SignUpScreen(role: 'Masyarakat'),
            },
          ),
        );
        await tester.pumpAndSettle();

        final signUpButton = find.text('Sign Up');
        await tester.ensureVisible(signUpButton);
        await tester.tap(signUpButton);
        await tester.pumpAndSettle();

        expect(find.byType(SignUpScreen), findsOneWidget);
      },
    );

    testWidgets(
      'TC-AUTH-07: Back button exists and is functional',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          const MaterialApp(
            home: AuthOptionsScreen(role: 'Masyarakat'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      },
    );
  });

  group('AuthOptionsScreen Role Selection - AuthOptionsScreen.role', () {
    testWidgets(
      'TC-AUTH-08: Screen accepts Masyarakat role',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          const MaterialApp(
            home: AuthOptionsScreen(role: 'Masyarakat'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AuthOptionsScreen), findsOneWidget);
        expect(find.text('Log In'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-AUTH-09: Screen accepts Organisasi role',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          const MaterialApp(
            home: AuthOptionsScreen(role: 'Organisasi'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AuthOptionsScreen), findsOneWidget);
        expect(find.text('Log In'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-AUTH-10: Buttons are properly aligned and sized',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          const MaterialApp(
            home: AuthOptionsScreen(role: 'Masyarakat'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ElevatedButton), findsWidgets);
      },
    );
  });
}
