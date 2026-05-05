import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/kebutuhan_tambah_panti.dart';

void main() {
  testWidgets('Tambah kebutuhan flow basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: KebutuhanTambahPantiPage(
          pantiId: 1,
          userId: 1,
        ),
      ),
    );

    // Halaman tampil
    expect(find.byType(KebutuhanTambahPantiPage), findsOneWidget);

    // Cari field input
    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets);

    // Isi field pertama (kalau ada)
    if (textFields.evaluate().isNotEmpty) {
      await tester.enterText(textFields.first, 'Beras');
      await tester.pump();
    }

    // Cari tombol simpan / tambah
    final saveButton = find.textContaining('Simpan').evaluate().isNotEmpty
        ? find.textContaining('Simpan')
        : find.textContaining('Tambah');

    if (saveButton.evaluate().isNotEmpty) {
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
    }

    // Pastikan tidak crash
    expect(find.byType(KebutuhanTambahPantiPage), findsOneWidget);
  });
}