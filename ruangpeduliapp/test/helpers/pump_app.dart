import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpApp(
  WidgetTester tester,
  Widget widget, {
  List<NavigatorObserver>? observers,
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: widget,
      navigatorObservers: observers ?? const [],
    ),
  );

  await tester.pump();
}

void main() {
  group('pumpApp helper', () {
    testWidgets('membungkus widget dengan MaterialApp', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: Text('Pump app test'),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Pump app test'), findsOneWidget);
    });

    testWidgets('menerapkan theme jika diberikan', (tester) async {
      await pumpApp(
        tester,
        Builder(
          builder: (context) {
            return Text(
              'Themed widget',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            );
          },
        ),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        ),
      );

      expect(find.text('Themed widget'), findsOneWidget);
      expect(Theme.of(tester.element(find.text('Themed widget'))), isA<ThemeData>());
    });
  });
}
