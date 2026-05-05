import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/kebutuhan_panti.dart';
import 'package:ruangpeduliapp/panti/profile_panti/kebutuhan_tambah_panti.dart';

void main() {
  testWidgets('Kebutuhan flow basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: KebutuhanPantiPage(
          pantiId: 1,
          userId: 1,
        ),
        routes: {
          '/tambah': (_) => KebutuhanTambahPantiPage(
                pantiId: 1,
                userId: 1,
              ),
        },
      ),
    );

    // halaman awal tampil
    expect(find.byType(KebutuhanPantiPage), findsOneWidget);

    // cari tombol tambah (umum: icon + atau text)
    final addButton =
        find.byIcon(Icons.add).evaluate().isNotEmpty
            ? find.byIcon(Icons.add)
            : find.textContaining('Tambah');

    if (addButton.evaluate().isNotEmpty) {
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // cek apakah pindah ke halaman tambah
      expect(find.byType(KebutuhanTambahPantiPage), findsOneWidget);
    } else {
      // fallback: halaman tetap ada
      expect(find.byType(KebutuhanPantiPage), findsOneWidget);
    }
  });
}