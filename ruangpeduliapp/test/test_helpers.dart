import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper function untuk membuild widget dengan MaterialApp wrapper
Widget buildTestableWidget(Widget widget) {
  return MaterialApp(
    home: widget,
  );
}

/// Helper function untuk membuild widget dengan custom theme
Widget buildTestableWidgetWithTheme({
  required Widget widget,
  ThemeData? theme,
}) {
  return MaterialApp(
    home: widget,
    theme: theme ?? ThemeData.light(),
  );
}

/// Helper function untuk pump widget and frame
Future<void> pumpWidgetAndSettle(
  WidgetTester tester,
  Widget widget,
) async {
  await tester.pumpWidget(buildTestableWidget(widget));
  await tester.pumpAndSettle();
}

/// Helper function untuk find text exact match
Finder findText(String text) {
  return find.text(text);
}

/// Helper function untuk find button
Finder findButton(String label) {
  return find.widgetWithText(ElevatedButton, label);
}

/// Helper function untuk tap widget
Future<void> tapWidget(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Helper function untuk enter text
Future<void> enterText(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
}

/// Helper function untuk scroll to widget
Future<void> scrollToWidget(
  WidgetTester tester,
  Finder finder, {
  Offset offset = const Offset(0, 0),
}) async {
  await tester.scrollUntilVisible(finder, offset.dy);
  await tester.pumpAndSettle();
}

/// Helper function untuk wait for widget
Future<void> waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  await tester.pumpAndSettle(timeout);
  expect(finder, findsOneWidget);
}
