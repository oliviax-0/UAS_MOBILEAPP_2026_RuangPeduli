import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/panti/profile_panti/edit_profile_panti.dart';

void main() {
  testWidgets('Edit profile flow basic test', (WidgetTester tester) async {
    final mockProfile = PantiProfileModel(
      id: 1,
      username: 'testpanti',
      email: 'test@panti.com',
      namaPanti: 'Test Panti',
      alamatPanti: 'Jl. Test No. 1',
      nomorPanti: '081234567890',
      description: 'Test description',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: EditProfilePanti(
          pantiId: 1,
          userId: 1,
          initialProfile: mockProfile,
        ),
      ),
    );

    // Halaman tampil
    expect(find.byType(EditProfilePanti), findsOneWidget);

    // Cari field input (umum)
    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets);

    // Isi salah satu field jika ada
    if (textFields.evaluate().isNotEmpty) {
      await tester.enterText(textFields.first, 'Test Input');
      await tester.pump();
    }

    // Cari tombol simpan (fallback fleksibel)
    final saveButton = find.textContaining('Simpan');

    if (saveButton.evaluate().isNotEmpty) {
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
    }

    // Minimal halaman tetap tidak crash
    expect(find.byType(EditProfilePanti), findsOneWidget);
  });
}
