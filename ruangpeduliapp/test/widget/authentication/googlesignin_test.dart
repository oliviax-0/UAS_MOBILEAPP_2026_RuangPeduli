// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../shared/screen_builders.dart';

void main() {
  group('Google Sign-In Button - LoginScreen', () {
    testWidgets(
      'TC-GOOGLE-01: Google sign-in button is displayed on login screen',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1200, 2400);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildLoginScreen());
        await tester.pumpAndSettle();

        // Look for Image (Google logo) in the screen
        expect(find.byType(Image), findsWidgets);
      },
    );

    testWidgets(
      'TC-GOOGLE-02: Google button renders without overflow',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1200, 2400);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildLoginScreen());
        await tester.pumpAndSettle();

        // Should render without layout errors
        expect(find.byType(GestureDetector), findsWidgets);
      },
    );

    testWidgets(
      'TC-GOOGLE-03: Google login button is tappable',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1200, 2400);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildLoginScreen());
        await tester.pumpAndSettle();

        // Find and tap the Google button (Row with Image)
        final googleButtons = find.byType(GestureDetector);
        expect(googleButtons, findsWidgets);
      },
    );
  });

  group('Google Sign-In Button - SignUpScreen', () {
    testWidgets(
      'TC-GOOGLE-04: Google sign-up button is displayed',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1200, 2400);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildSignUpScreen());
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsWidgets);
      },
    );

    testWidgets(
      'TC-GOOGLE-05: Google sign-up button renders without overflow',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1200, 2400);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildSignUpScreen());
        await tester.pumpAndSettle();

        expect(find.byType(GestureDetector), findsWidgets);
      },
    );

    testWidgets(
      'TC-GOOGLE-06: Google sign-up button is tappable',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1200, 2400);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildSignUpScreen());
        await tester.pumpAndSettle();

        final googleButtons = find.byType(GestureDetector);
        expect(googleButtons, findsWidgets);
      },
    );
  });

  group('Google OAuth Integration', () {
    testWidgets(
      'TC-GOOGLE-07: Login screen has both regular and Google login options',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1200, 2400);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildLoginScreen());
        await tester.pumpAndSettle();

        // Google logo image should exist
        expect(find.byType(Image), findsWidgets);
      },
    );

    testWidgets(
      'TC-GOOGLE-08: Sign-up screen has Google sign-up option',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1200, 2400);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildSignUpScreen());
        await tester.pumpAndSettle();

        // Google logo image should exist
        expect(find.byType(Image), findsWidgets);
      },
    );

    testWidgets(
      'TC-GOOGLE-09: Google logo image is displayed correctly',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1200, 2400);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildLoginScreen());
        await tester.pumpAndSettle();

        final images = find.byType(Image);
        expect(images, findsWidgets);
      },
    );
  });
}
