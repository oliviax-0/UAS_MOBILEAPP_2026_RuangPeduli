import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ sesuaikan dengan file asli kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti.dart';

void main() {
  testWidgets('Notif badge render test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotifBadge(
            count: 3,
          ),
        ),
      ),
    );

    // widget tampil
    expect(find.byType(NotifBadge), findsOneWidget);

    // badge count tampil
    expect(find.text('3'), findsOneWidget);

    // icon notif tampil
    expect(find.byIcon(Icons.notifications), findsOneWidget);
  });
}