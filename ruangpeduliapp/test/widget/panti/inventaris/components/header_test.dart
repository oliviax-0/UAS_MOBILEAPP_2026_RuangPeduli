import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ sesuaikan dengan file asli kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti.dart';

void main() {
  testWidgets('Header widget render test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HeaderWidget(
            title: 'Inventaris',
            onNotifTap: () {},
          ),
        ),
      ),
    );

    // widget tampil
    expect(find.byType(HeaderWidget), findsOneWidget);

    // title tampil
    expect(find.text('Inventaris'), findsOneWidget);

    // notif icon tampil
    expect(find.byIcon(Icons.notifications), findsOneWidget);
  });
}