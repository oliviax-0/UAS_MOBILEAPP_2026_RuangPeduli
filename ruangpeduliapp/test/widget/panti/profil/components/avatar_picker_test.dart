import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/panti/profile_panti/edit_profile_panti.dart';

void main() {
  PantiProfileModel profile({String? profilePicture}) {
    return PantiProfileModel(
      id: 1,
      username: 'panti_test',
      email: 'panti@test.com',
      namaPanti: 'Panti Test',
      alamatPanti: 'Jl. Test No. 1',
      nomorPanti: '081234567890',
      description: 'Profil panti untuk widget test',
      profilePicture: profilePicture,
    );
  }

  Future<void> pumpEditProfile(
    WidgetTester tester, {
    String? profilePicture,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EditProfilePanti(
          pantiId: 1,
          userId: 1,
          initialProfile: profile(profilePicture: profilePicture),
        ),
      ),
    );
  }

  testWidgets('menampilkan avatar placeholder ketika belum ada foto', (
    tester,
  ) async {
    await pumpEditProfile(tester);

    expect(find.text('Ubah foto'), findsOneWidget);
    expect(find.byIcon(Icons.home_work_rounded), findsOneWidget);
  });

  testWidgets('tap avatar membuka pilihan ganti foto', (tester) async {
    await pumpEditProfile(tester);

    await tester.tap(find.text('Ubah foto'));
    await tester.pumpAndSettle();

    expect(find.text('Ganti Foto'), findsOneWidget);
    expect(find.text('Hapus Foto'), findsNothing);
  });

  testWidgets('menampilkan pilihan hapus foto jika profil punya foto', (
    tester,
  ) async {
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception is NetworkImageLoadException) {
        return;
      }
      previousOnError?.call(details);
    };

    try {
      await pumpEditProfile(
        tester,
        profilePicture: 'https://example.com/profile.jpg',
      );

      await tester.tap(find.text('Ubah foto'));
      await tester.pumpAndSettle();

      expect(find.text('Ganti Foto'), findsOneWidget);
      expect(find.text('Hapus Foto'), findsOneWidget);
    } finally {
      FlutterError.onError = previousOnError;
    }
  });
}
