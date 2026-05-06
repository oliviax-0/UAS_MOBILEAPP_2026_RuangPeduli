import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Search field test',
      (WidgetTester tester) async {

    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Cari barang',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {},
          ),
        ),
      ),
    );

    // TextField tampil
    expect(find.byType(TextField), findsOneWidget);

    // Icon search tampil
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Input text
    await tester.enterText(
      find.byType(TextField),
      'Beras',
    );

    await tester.pump();

    // Validasi text masuk
    expect(controller.text, 'Beras');
    expect(find.text('Beras'), findsOneWidget);
  });
}