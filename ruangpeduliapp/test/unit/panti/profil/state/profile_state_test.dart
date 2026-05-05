import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ruangpeduliapp/panti/profile_panti/state/profile_state.dart';
import 'package:ruangpeduliapp/panti/profile_panti/models/profile_model.dart';
import 'package:ruangpeduliapp/panti/profile_panti/api/profile_api.dart';

/// =========================
/// FAKE API (SUCCESS)
/// =========================
class FakeProfileApi extends ProfileApi {  FakeProfileApi() : super(client: http.Client());
  @override
  Future<ProfileModel> getProfile() async {
    return ProfileModel(
      id: 1,
      namaPanti: 'Panti Kasih',
      email: 'test@mail.com',
      noTelepon: '08123456789',
      alamat: 'Jakarta',
      deskripsi: 'Test',
      fotoProfil: null,
    );
  }

  @override
  Future<bool> updateProfile(ProfileModel profile) async {
    return true;
  }
}

/// =========================
/// FAKE API (ERROR)
/// =========================
class ErrorProfileApi extends ProfileApi {  ErrorProfileApi() : super(client: http.Client());
  @override
  Future<ProfileModel> getProfile() async {
    throw Exception('Error');
  }

  @override
  Future<bool> updateProfile(ProfileModel profile) async {
    throw Exception('Error');
  }
}

void main() {
  group('ProfileState Test', () {

    test('loadProfile berhasil', () async {
      final state = ProfileState(api: FakeProfileApi());

      await state.loadProfile();

      expect(state.profile, isNotNull);
      expect(state.error, isNull);
      expect(state.isLoading, false);
    });

    test('loadProfile gagal', () async {
      final state = ProfileState(api: ErrorProfileApi());

      await state.loadProfile();

      expect(state.profile, isNull);
      expect(state.error, isNotNull);
      expect(state.isLoading, false);
    });

    test('updateProfile berhasil', () async {
      final state = ProfileState(api: FakeProfileApi());

      final newProfile = ProfileModel(
        id: 1,
        namaPanti: 'Updated',
        email: 'updated@mail.com',
        noTelepon: '08111111111',
        alamat: 'Bandung',
        deskripsi: 'Updated',
        fotoProfil: null,
      );

      final result = await state.updateProfile(newProfile);

      expect(result, true);
      expect(state.profile?.namaPanti, 'Updated');
    });

    test('updateProfile gagal', () async {
      final state = ProfileState(api: ErrorProfileApi());

      final newProfile = ProfileModel(
        id: 1,
        namaPanti: 'Updated',
        email: 'updated@mail.com',
        noTelepon: '08111111111',
        alamat: 'Bandung',
        deskripsi: 'Updated',
        fotoProfil: null,
      );

      final result = await state.updateProfile(newProfile);

      expect(result, false);
      expect(state.error, isNotNull);
    });

  });
}