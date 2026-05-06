import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Input field test',
      (WidgetTester tester) async {

    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Masukkan nama barang',
            ),
          ),
        ),
      ),
    );

    // textfield tampil
    expect(find.byType(TextField), findsOneWidget);

    // hint tampil
    expect(find.text('Masukkan nama barang'), findsOneWidget);

    // input text
    await tester.enterText(find.byType(TextField), 'Beras');
    await tester.pump();

    // validasi text masuk
    expect(controller.text, 'Beras');
    expect(find.text('Beras'), findsOneWidget);
  });
}