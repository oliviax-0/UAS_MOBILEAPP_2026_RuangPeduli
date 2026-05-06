import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ import sesuai struktur asli kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_anggota.dart';

void main() {
  testWidgets('Penghuni page render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DaftarPenghuniScreen(userId: null), // ✅ dummy mode (skip API)
      ),
    );

    await tester.pumpAndSettle();

    // page tampil
    expect(find.byType(DaftarPenghuniScreen), findsOneWidget);

    // scaffold tampil
    expect(find.byType(Scaffold), findsOneWidget);

    // title sesuai UI (kalau di lib judulnya "Penghuni")
    expect(find.text('Penghuni'), findsOneWidget);

    // state dummy harusnya empty (sesuaikan dengan text di UI lib)usnya empty (sesuaikan dengan text di UI lib)
    expect(find.text('Belum ada penghuni.'), findsOneWidget);
  });
}
