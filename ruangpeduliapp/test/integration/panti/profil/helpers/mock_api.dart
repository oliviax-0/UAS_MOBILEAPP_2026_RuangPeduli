// test/mocks/mock_api.dart

import 'package:ruangpeduliapp/panti/profile_panti/models/profile_model.dart';
import 'package:ruangpeduliapp/panti/profile_panti/models/kebutuhan_model.dart';

class MockApi {
  /// =========================
  /// PROFILE
  /// =========================
  Future<ProfileModel> getProfile() async {
    return ProfileModel(
      id: 1,
      namaPanti: 'Panti Kasih',
      email: 'panti@test.com',
      noTelepon: '08123456789',
      alamat: 'Jakarta',
      deskripsi: 'Deskripsi Panti',
      fotoProfil: null,
    );
  }

  Future<bool> updateProfile(ProfileModel profile) async {
    return true;
  }

  /// =========================
  /// KEBUTUHAN
  /// =========================
  Future<List<KebutuhanModel>> getKebutuhan() async {
    return [
      KebutuhanModel(id: 1, nama: 'Beras', jumlah: 10, satuan: 'Kg'),
      KebutuhanModel(id: 2, nama: 'Air', jumlah: 5, satuan: 'Liter'),
    ];
  }

  Future<bool> addKebutuhan(KebutuhanModel item) async {
    return true;
  }

  Future<bool> deleteKebutuhan(int id) async {
    return true;
  }
}