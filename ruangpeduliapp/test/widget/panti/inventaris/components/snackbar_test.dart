import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Snackbar render test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Berhasil disimpan'),
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

    // tombol tampil
    expect(find.text('Show Snackbar'), findsOneWidget);

    // klik tombol
    await tester.tap(find.text('Show Snackbar'));
    await tester.pump();

    // snackbar tampil
    expect(find.byType(SnackBar), findsOneWidget);

    // text snackbar tampil
    expect(find.text('Berhasil disimpan'), findsOneWidget);
  });
}