import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/masyarakat/profile/edit_profil_screen.dart';
import '../transaksi/konfirmasi_metode_screen_test.mocks.dart';

@GenerateMocks([ProfileApi])
void main() {
  // ── Dummy profile ──
  final dummyProfile = SocietyProfileModel(
    id: 1,
    namaPengguna: 'Budi Santoso',
    username: 'budi_s',
    email: 'budi@email.com',
    nomorTelepon: '081234567890',
    jenisKelamin: 'Laki-laki',
    alamat: 'Jl. Merdeka No. 1',
    profilePicture: null,
  );

  Widget buildWidget({
    SocietyProfileModel? profile,
    int? userId = 1,
    ProfileApi? profileApi,
  }) {
    final userProfile = profile ?? dummyProfile;
    return MaterialApp(
      home: EditProfilScreen(
        profile: userProfile,
        userId: userId,
        profileApi: profileApi,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 1. GestureDetector (Avatar) — Tap untuk buka opsi foto profil
  //    Metode: EditProfilScreen._showPhotoOptions(),
  //            EditProfilScreen._pickImage(),
  //            EditProfilScreen._removeProfilePhoto()
  // ─────────────────────────────────────────────────────────────
  group('GestureDetector Avatar — tap untuk buka opsi foto profil', () {
    testWidgets('Avatar dan teks "Ubah foto" ditampilkan',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Ubah foto'), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('Tap avatar membuka ModalBottomSheet opsi foto',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.tap(find.text('Ubah foto'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 2. ModalBottomSheet — Opsi ganti/hapus foto profil
  //    Metode: EditProfilScreen._showPhotoOptions(),
  //            EditProfilScreen._pickImage(),
  //            EditProfilScreen._removeProfilePhoto()
  // ─────────────────────────────────────────────────────────────
  group('ModalBottomSheet — opsi ganti/hapus foto profil', () {
    testWidgets('BottomSheet menampilkan opsi "Ganti Foto"',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.tap(find.text('Ubah foto'));
      await tester.pumpAndSettle();

      expect(find.text('Ganti Foto'), findsOneWidget);
    });

    testWidgets(
        'BottomSheet tidak menampilkan "Hapus Foto" saat tidak ada foto profil',
        (WidgetTester tester) async {
      // Profile tanpa foto
      final profileNoPhoto = SocietyProfileModel(
        id: 1,
        namaPengguna: 'Budi',
        username: 'budi_s',
        email: 'budi@email.com',
        nomorTelepon: '08123',
        jenisKelamin: 'Laki-laki',
        alamat: 'Jakarta',
        profilePicture: null,
      );

      await tester.pumpWidget(buildWidget(profile: profileNoPhoto));
      await tester.pump();

      await tester.tap(find.text('Ubah foto'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Foto'), findsNothing);
    });

    testWidgets('Tap "Ganti Foto" menutup BottomSheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.tap(find.text('Ubah foto'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ganti Foto'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 3. TextField (Nama Pengguna) — Input nama lengkap user
  //    Metode: EditProfilScreen._onSimpan(), EditProfilScreen.initState()
  // ─────────────────────────────────────────────────────────────
  group('TextField Nama Pengguna — input nama lengkap user', () {
    testWidgets('TextField nama pengguna ditampilkan dengan label yang benar',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Nama Pengguna'), findsOneWidget);
    });

    testWidgets('TextField nama pengguna terisi dengan data profil awal',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.widgetWithText(TextField, 'Budi Santoso'), findsOneWidget);
    });

    testWidgets('TextField nama pengguna bisa diubah oleh user',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      final field = find.widgetWithText(TextField, 'Budi Santoso');
      await tester.ensureVisible(field);
      await tester.tap(field);
      await tester.enterText(field, 'Andi Wijaya');
      await tester.pump();

      expect(find.text('Andi Wijaya'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 4. TextField (Username) — Input username user
  //    Metode: EditProfilScreen._onSimpan(), EditProfilScreen.initState()
  // ─────────────────────────────────────────────────────────────
  group('TextField Username — input username user', () {
    testWidgets('TextField username ditampilkan dengan label yang benar',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('TextField username terisi dengan data profil awal',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.widgetWithText(TextField, 'budi_s'), findsOneWidget);
    });

    testWidgets('TextField username bisa diubah oleh user',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      final field = find.widgetWithText(TextField, 'budi_s');
      await tester.ensureVisible(field);
      await tester.tap(field);
      await tester.enterText(field, 'andi_w');
      await tester.pump();

      expect(find.text('andi_w'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 5. TextField (Nomor Telepon) — Input nomor telepon user
  //    Metode: EditProfilScreen._onSimpan(), EditProfilScreen.initState()
  // ─────────────────────────────────────────────────────────────
  group('TextField Nomor Telepon — input nomor telepon user', () {
    testWidgets('TextField nomor telepon ditampilkan dengan label yang benar',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Nomor Telepon'), findsOneWidget);
    });

    testWidgets('TextField nomor telepon terisi dengan data profil awal',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.widgetWithText(TextField, '081234567890'), findsOneWidget);
    });

    testWidgets('TextField nomor telepon bisa diubah oleh user',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      final field = find.widgetWithText(TextField, '081234567890');
      await tester.ensureVisible(field);
      await tester.tap(field);
      await tester.enterText(field, '089999999999');
      await tester.pump();

      expect(find.text('089999999999'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 6. TextField (Jenis Kelamin) — Input jenis kelamin user
  //    Metode: EditProfilScreen._onSimpan(), EditProfilScreen.initState()
  // ─────────────────────────────────────────────────────────────
  group('TextField Jenis Kelamin — input jenis kelamin user', () {
    testWidgets('TextField jenis kelamin ditampilkan dengan label yang benar',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Jenis Kelamin'), findsOneWidget);
    });

    testWidgets('TextField jenis kelamin terisi dengan data profil awal',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.widgetWithText(TextField, 'Laki-laki'), findsOneWidget);
    });

    testWidgets('TextField jenis kelamin bisa diubah oleh user',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      final field = find.widgetWithText(TextField, 'Laki-laki');
      await tester.ensureVisible(field);
      await tester.tap(field);
      await tester.enterText(field, 'Perempuan');
      await tester.pump();

      expect(find.text('Perempuan'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 7. GestureDetector ("Ganti Email") — Buka dialog ganti email
  //    Metode: EditProfilScreen._openChangeEmail(),
  //            EditProfilScreen._showError()
  // ─────────────────────────────────────────────────────────────
  group('GestureDetector Ganti Email — buka dialog ganti email', () {
    testWidgets('Teks "Ganti email" tersedia di halaman',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Ganti email'), findsOneWidget);
    });

    testWidgets('Label "Alamat Email" ditampilkan',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Alamat Email'), findsOneWidget);
    });

    testWidgets('Email saat ini ditampilkan dalam field terkunci',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('budi@email.com'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon &&
              widget.icon == Icons.lock_outline_rounded &&
              widget.size == 16,
        ),
        findsOneWidget,
      );
    });

    testWidgets('Tap "Ganti email" membuka _ChangeEmailDialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      final button = find.text('Ganti email');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text('Ganti Email'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('Error SnackBar muncul saat userId null dan ganti email di-tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(userId: null));
      await tester.pump();

      final button = find.text('Ganti email');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();

      expect(find.text('Sesi tidak valid, silakan login ulang'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 8. GestureDetector ("Ganti Password") — Buka dialog ganti password
  //    Metode: EditProfilScreen._openChangePassword(),
  //            EditProfilScreen._showError()
  // ─────────────────────────────────────────────────────────────
  group('GestureDetector Ganti Password — buka dialog ganti password', () {
    testWidgets('Tombol "Ganti Kata Sandi" tersedia di halaman',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Ganti Kata Sandi'), findsOneWidget);
    });

    testWidgets('Tap "Ganti Kata Sandi" membuka _ChangePasswordDialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      final button = find.widgetWithText(OutlinedButton, 'Ganti Kata Sandi');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('Error SnackBar muncul saat userId null dan ganti password di-tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(userId: null));
      await tester.pump();

      final button = find.widgetWithText(OutlinedButton, 'Ganti Kata Sandi');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();

      expect(find.text('Sesi tidak valid, silakan login ulang'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 9. _ChangeEmailDialog — Dialog untuk ganti email
  //    Metode: EditProfilScreen._openChangeEmail(),
  //            _ChangeEmailDialog._onSimpan()
  // ─────────────────────────────────────────────────────────────
  group('_ChangeEmailDialog — dialog untuk ganti email', () {
    testWidgets('Dialog "Ganti Email" memiliki judul yang benar',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.tap(find.text('Ganti email'));
      await tester.pumpAndSettle();

      expect(find.text('Ganti Email'), findsOneWidget);
    });

    testWidgets('Dialog memiliki tombol close (ikon X)',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.tap(find.text('Ganti email'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('Tap ikon X menutup dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.tap(find.text('Ganti email'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 10. _ChangePasswordDialog — Dialog ganti password (3 mode: change, OTP, reset)
  //     Metode: EditProfilScreen._openChangePassword(),
  //             _ChangePasswordDialog._saveChange(),
  //             _ChangePasswordDialog._sendForgotOtp(),
  //             _ChangePasswordDialog._resetPassword()
  // ─────────────────────────────────────────────────────────────
  group('_ChangePasswordDialog — dialog ganti password dengan 3 mode', () {
    testWidgets('Dialog menampilkan field kata sandi saat ini (mode change)',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      final button = find.widgetWithText(OutlinedButton, 'Ganti Kata Sandi');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text('Kata sandi saat ini'), findsOneWidget);
    });

    testWidgets('Dialog menampilkan field kata sandi baru (mode change)',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      final button = find.widgetWithText(OutlinedButton, 'Ganti Kata Sandi');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text('Kata sandi baru'), findsOneWidget);
    });

    testWidgets('Dialog menampilkan tombol "Simpan" pada mode change',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      final button = find.widgetWithText(OutlinedButton, 'Ganti Kata Sandi');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.widgetWithText(ElevatedButton, 'Simpan'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Tap "Lupa kata sandi?" berpindah ke mode forgotSendOtp',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      final button = find.widgetWithText(OutlinedButton, 'Ganti Kata Sandi');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      final forgotButton = find.text('Lupa kata sandi?');
      await tester.ensureVisible(forgotButton);
      await tester.tap(forgotButton);
      await tester.pumpAndSettle();

      expect(find.text('Kirim Kode OTP'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 11. ElevatedButton ("Simpan") — Tombol simpan perubahan profil
  //     Metode: EditProfilScreen._onSimpan(),
  //             ProfileApi.updateMasyarakatProfile()
  // ─────────────────────────────────────────────────────────────
  group('ElevatedButton Simpan — tombol simpan perubahan profil', () {
    testWidgets('Tombol "Simpan" tersedia di halaman',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      // Tombol Simpan utama pada halaman edit profil
      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Simpan'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Tombol "Simpan" menampilkan SnackBar error saat profileId null',
        (WidgetTester tester) async {
      // Profile tanpa id (null scenario)
      await tester.pumpWidget(buildWidget(profile: null));
      await tester.pump();

      final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Profil tidak ditemukan'), findsOneWidget);
    });

    testWidgets('Tombol "Simpan" menampilkan CircularProgressIndicator saat _saving',
        (WidgetTester tester) async {
      final mockProfileApi = MockProfileApi();
      final saveCompleter = Completer<SocietyProfileModel>();
      when(mockProfileApi.updateMasyarakatProfile(any))
          .thenAnswer((_) => saveCompleter.future);

      await tester.pumpWidget(buildWidget(profileApi: mockProfileApi));
      await tester.pump();

      final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        saveButton,
        100,
        scrollable: find.byType(SingleChildScrollView),
      );
      await tester.tap(saveButton);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 12. SnackBar — Menampilkan pesan sukses/error
  //     Metode: EditProfilScreen._showError(), EditProfilScreen._onSimpan()
  // ─────────────────────────────────────────────────────────────
  group('SnackBar — menampilkan pesan sukses/error', () {
    testWidgets('SnackBar error "Profil tidak ditemukan" muncul saat profileId null',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(profile: null));
      await tester.pump();

      final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        saveButton,
        100,
        scrollable: find.byType(SingleChildScrollView),
      );
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Profil tidak ditemukan'), findsOneWidget);
    });

    testWidgets('SnackBar error muncul saat userId null dan tap Ganti Email',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(userId: null));
      await tester.pump();

      final changeEmailButton = find.text('Ganti email');
      await tester.ensureVisible(changeEmailButton);
      await tester.pumpAndSettle();
      await tester.tap(changeEmailButton);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Sesi tidak valid, silakan login ulang'), findsOneWidget);
    });

    testWidgets('SnackBar error muncul saat userId null dan tap Ganti Kata Sandi',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(userId: null));
      await tester.pump();

      final changePasswordButton = find.widgetWithText(OutlinedButton, 'Ganti Kata Sandi');
      await tester.ensureVisible(changePasswordButton);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        changePasswordButton,
        100,
        scrollable: find.byType(SingleChildScrollView),
      );
      await tester.tap(changePasswordButton);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Sesi tidak valid, silakan login ulang'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 13. AuthBackButton — Tombol kembali ke Profile Screen
  //     Metode: EditProfilScreen.build()
  // ─────────────────────────────────────────────────────────────
  group('AuthBackButton — tombol kembali ke Profile Screen', () {
    testWidgets('AppBar dengan tombol back tersedia',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('AppBar menampilkan judul "Edit Profil"',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Edit Profil'), findsOneWidget);
    });

    testWidgets('Tap tombol back melakukan Navigator.pop',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => EditProfilScreen(
                    profile: dummyProfile,
                    userId: 1,
                  ),
                ),
              ),
              child: const Text('Go'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Kembali ke halaman sebelumnya
      expect(find.text('Go'), findsOneWidget);
    });
  });
}