import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/edit_profile_panti.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';

void main() {
  testWidgets('EditProfilePanti render test', (WidgetTester tester) async {
    // Create mock data
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

    expect(find.byType(EditProfilePanti), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);
  });
}