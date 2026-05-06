import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ sesuaikan dengan file asli kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti.dart';

void main() {
  testWidgets('Square widget render test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SquareWidget(
            title: 'Stok Masuk',
            icon: Icons.inventory,
            color: Colors.blue,
            onTap: () {},
          ),
        ),
      ),
    );

    // widget tampil
    expect(find.byType(SquareWidget), findsOneWidget);

    // title tampil
    expect(find.text('Stok Masuk'), findsOneWidget);

    // icon tampil
    expect(find.byIcon(Icons.inventory), findsOneWidget);
  });
}