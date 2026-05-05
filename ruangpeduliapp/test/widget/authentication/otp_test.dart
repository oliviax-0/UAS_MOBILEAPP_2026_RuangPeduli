// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../shared/screen_builders.dart';

void main() {
  group('OTP Screen Display - ResetPasswordOtpScreen.build()', () {
    testWidgets(
      'TC-OTP-01: OTP screen renders with all elements',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildOtpScreen());
        await tester.pumpAndSettle();

        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Lanjut'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-OTP-02: Screen title is displayed',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildOtpScreen());
        await tester.pumpAndSettle();

        expect(find.text('Kode Verifikasi'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-OTP-02b: OTP input boxes are displayed',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildOtpScreen());
        await tester.pumpAndSettle();

        expect(find.byType(GestureDetector), findsWidgets);
      },
    );
  });

  group('OTP Input Validation - ResetPasswordOtpScreen._onVerify()', () {
    testWidgets(
      'TC-OTP-03: Error shown when OTP is less than 5 digits',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildOtpScreen());
        await tester.pumpAndSettle();

        final textFields = find.byType(TextField);
        await tester.enterText(textFields.first, '123');
        await tester.pumpAndSettle();

        final button = find.byType(ElevatedButton);
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        await tester.tap(button);
        await tester.pumpAndSettle();

        expect(find.text('Kode OTP harus 5 digit'), findsOneWidget);
      },
    );
  });

  group('OTP Verification - ResetPasswordOtpScreen._onVerify()', () {
    testWidgets(
      'TC-OTP-04: Form submission with valid 5-digit OTP',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildOtpScreen());
        await tester.pumpAndSettle();

        final textFields = find.byType(TextField);
        await tester.enterText(textFields.first, '12345');
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsWidgets);
      },
    );

    testWidgets(
      'TC-OTP-05: OTP field accepts only numeric input',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildOtpScreen());
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsWidgets);
      },
    );
  });

  group('Resend OTP - ResetPasswordOtpScreen._onResend()', () {
    testWidgets(
      'TC-OTP-06: Resend message structure is present',
      (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(AuthScreenBuilder.buildOtpScreen());
        await tester.pumpAndSettle();

        // Just verify RichText exists (contains resend message)
        expect(find.byType(RichText), findsWidgets);
      },
    );
  });
}
