import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_notifikasi.dart';

void main() {
  testWidgets('Notif page render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InventarisNotifikasiScreen(pantiId: null),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(InventarisNotifikasiScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    // Salah satu state harus muncul (loading/empty/list/error)
    expect(
      find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
          find.text('Semua stok aman!').evaluate().isNotEmpty ||
          find.byType(ListView).evaluate().isNotEmpty ||
          find.byIcon(Icons.refresh_rounded).evaluate().isNotEmpty,
      true,
    );
  });
}