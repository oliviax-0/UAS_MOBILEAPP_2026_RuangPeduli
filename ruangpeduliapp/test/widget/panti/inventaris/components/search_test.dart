import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ sesuaikan dengan file asli kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_stokmasuk.dart';

void main() {
  testWidgets('Search widget input test',
      (WidgetTester tester) async {

    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchWidget(
            controller: controller,
            onChanged: (value) {},
          ),
        ),
      ),
    );

    // widget tampil
    expect(find.byType(SearchWidget), findsOneWidget);

    // textfield tampil
    expect(find.byType(TextField), findsOneWidget);

    // input text
    await tester.enterText(find.byType(TextField), 'Beras');
    await tester.pump();

    expect(controller.text, 'Beras');
  });
}