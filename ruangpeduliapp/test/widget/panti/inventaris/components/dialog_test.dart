import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dialog render test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: const Text('Tambah Data'),
                        content: const TextField(),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Simpan'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // tombol tampil
    expect(find.text('Open Dialog'), findsOneWidget);

    // buka dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // dialog tampil
    expect(find.byType(AlertDialog), findsOneWidget);

    // title tampil
    expect(find.text('Tambah Data'), findsOneWidget);

    // textfield tampil
    expect(find.byType(TextField), findsOneWidget);

    // tombol simpan tampil
    expect(find.text('Simpan'), findsOneWidget);
  });
}