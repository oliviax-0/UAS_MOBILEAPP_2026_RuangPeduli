import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Summary widget test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Stok Mendesak',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('Critical: 2'),
                  Text('Warning: 5'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Title tampil
    expect(find.text('Stok Mendesak'), findsOneWidget);

    // Summary tampil
    expect(find.text('Critical: 2'), findsOneWidget);
    expect(find.text('Warning: 5'), findsOneWidget);

    // Card tampil
    expect(find.byType(Card), findsOneWidget);
  });
}