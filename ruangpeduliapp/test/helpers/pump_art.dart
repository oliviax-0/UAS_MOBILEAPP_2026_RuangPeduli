// test/helpers/pump_app.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpApp(
  WidgetTester tester,
  Widget widget, {
  List<NavigatorObserver>? observers,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: widget,
      navigatorObservers: observers ?? [],
    ),
  );

  await tester.pump(); // initial render
}