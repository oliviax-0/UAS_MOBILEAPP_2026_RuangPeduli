import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/tambah_akun_panti.dart';

void main() {
  testWidgets('Change email flow basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TambahAkunPanti(),
      ),
    );

    // Halaman tampil
    expect(find.byType(TambahAkunPanti), findsOneWidget);
    expect(find.text('Tambah Akun'), findsOneWidget);

    // Cari field input.
    final textFields = find.byType(TextFormField);
    expect(textFields, findsWidgets);

    // Isi salah satu field untuk memastikan input menerima teks.
    if (textFields.evaluate().isNotEmpty) {
      await tester.enterText(textFields.first, 'test@email.com');
      await tester.pump();

      expect(find.text('test@email.com'), findsOneWidget);
    }

    // Submit dengan form belum lengkap hanya memunculkan validasi lokal.
    final saveButton = find.text('Buat Akun');

    if (saveButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
      expect(find.text('Nama panti tidak boleh kosong'), findsOneWidget);
    }

    // Pastikan tidak crash
    expect(find.byType(TambahAkunPanti), findsOneWidget);
  });
}
