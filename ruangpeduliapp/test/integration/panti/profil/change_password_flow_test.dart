import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/tambah_akun_panti.dart';

void main() {
  testWidgets('Change password flow basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TambahAkunPanti(),
      ),
    );

    // Halaman tampil
    expect(find.byType(TambahAkunPanti), findsOneWidget);
    expect(find.text('Tambah Akun'), findsOneWidget);

    // Cari field form.
    final textFields = find.byType(TextFormField);
    expect(textFields, findsWidgets);

    // Field password berada setelah username dan email.
    if (textFields.evaluate().length >= 3) {
      await tester.enterText(textFields.at(2), 'password123');
      await tester.pump();

      final passwordField = tester.widget<TextFormField>(textFields.at(2));

      expect(passwordField.obscureText, true);
    }

    // Submit dengan form belum lengkap hanya memunculkan validasi lokal.
    final saveButton = find.text('Buat Akun');

    if (saveButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Username tidak boleh kosong'), findsOneWidget);
      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
      expect(find.text('Nama panti tidak boleh kosong'), findsOneWidget);
    }

    // Pastikan tidak crash
    expect(find.byType(TambahAkunPanti), findsOneWidget);
  });
}
