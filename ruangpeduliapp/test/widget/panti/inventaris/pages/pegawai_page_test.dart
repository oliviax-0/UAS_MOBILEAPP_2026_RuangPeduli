import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_anggota.dart';

void main() {
  testWidgets('Pegawai page render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DaftarPegawaiScreen(userId: null), // ✅ dummy mode (skip API)
      ),
    );

    await tester.pumpAndSettle();

    // page tampil
    expect(find.byType(DaftarPegawaiScreen), findsOneWidget);

    // scaffold tampil
    expect(find.byType(Scaffold), findsOneWidget);

    // title sesuai UI
    expect(find.text('Pegawai'), findsOneWidget);

    // state dummy harusnya empty
    expect(find.text('Belum ada pegawai.'), findsOneWidget);
  });
}
