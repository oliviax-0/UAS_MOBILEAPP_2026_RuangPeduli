import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSnackBarTestApp({
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: backgroundColor,
                          duration: duration,
                        ),
                      );
                    },
                    child: const Text('Tampilkan SnackBar'),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                    child: const Text('Tutup SnackBar'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  group('SnackBar Widget', () {
    testWidgets(
      'TC-SB-01: snackbar tampil saat tombol ditekan',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildSnackBarTestApp(message: 'Data berhasil disimpan'),
        );

        await tester.tap(find.text('Tampilkan SnackBar'));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Data berhasil disimpan'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-SB-02: snackbar error memakai warna merah',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildSnackBarTestApp(
            message: 'Terjadi kesalahan',
            backgroundColor: Colors.red,
          ),
        );

        await tester.tap(find.text('Tampilkan SnackBar'));
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));

        expect(find.text('Terjadi kesalahan'), findsOneWidget);
        expect(snackBar.backgroundColor, Colors.red);
      },
    );

    testWidgets(
      'TC-SB-03: snackbar dapat ditutup manual',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildSnackBarTestApp(
            message: 'Pesan sementara',
          ),
        );

        await tester.tap(find.text('Tampilkan SnackBar'));
        await tester.pump();

        expect(find.text('Pesan sementara'), findsOneWidget);

        await tester.tap(find.text('Tutup SnackBar'));
        await tester.pumpAndSettle();

        expect(find.text('Pesan sementara'), findsNothing);
      },
    );
  });
}
