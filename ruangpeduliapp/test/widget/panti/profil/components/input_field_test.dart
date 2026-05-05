import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/panti/profile_panti/edit_profile_panti.dart';

void main() {
  testWidgets('field nama di halaman edit profil tampil', (
    WidgetTester tester,
  ) async {
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

    expect(find.text('Nama'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Test Panti'), findsOneWidget);
  });
}
