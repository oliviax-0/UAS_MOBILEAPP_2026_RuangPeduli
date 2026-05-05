import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/panti/profile_panti/profile_panti.dart';
import 'package:ruangpeduliapp/panti/profile_panti/edit_profile_panti.dart';

void main() {
  testWidgets('Profile flow basic navigation test', (WidgetTester tester) async {
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
        home: Scaffold(
          body: Column(
            children: [
              const Expanded(child: ProfilePanti()),
              Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePanti(
                            pantiId: 1,
                            userId: 1,
                            initialProfile: mockProfile,
                          ),
                        ),
                      );
                    },
                    child: const Text('Buka Edit Profil'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

    // Halaman profile tampil
    expect(find.byType(ProfilePanti), findsOneWidget);

    await tester.tap(find.text('Buka Edit Profil'));
    await tester.pumpAndSettle();

    // Cek apakah navigasi berhasil
    expect(find.byType(EditProfilePanti), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);
  });
}
