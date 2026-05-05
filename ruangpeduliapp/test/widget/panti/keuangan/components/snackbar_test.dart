import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SnackBar show test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Berhasil'),
                    ),
                  );
                },
                child: const Text('Show Snackbar'),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Show Snackbar'), findsOneWidget);

    await tester.tap(find.text('Show Snackbar'));
    await tester.pump(); // start animation
    await tester.pump(const Duration(seconds: 1)); // tampilkan snackbar

    expect(find.text('Berhasil'), findsOneWidget);
  });
}