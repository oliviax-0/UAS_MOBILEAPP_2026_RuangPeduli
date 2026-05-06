import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Square menu widget test',
      (WidgetTester tester) async {

    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GestureDetector(
            onTap: () {
              tapped = true;
            },
            child: Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.inventory),
                  SizedBox(height: 8),
                  Text('Stok Masuk'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Icon tampil
    expect(find.byIcon(Icons.inventory), findsOneWidget);

    // Text tampil
    expect(find.text('Stok Masuk'), findsOneWidget);

    // Tap widget
    await tester.tap(find.text('Stok Masuk'));
    await tester.pump();

    // Validasi tap
    expect(tapped, true);
  });
}