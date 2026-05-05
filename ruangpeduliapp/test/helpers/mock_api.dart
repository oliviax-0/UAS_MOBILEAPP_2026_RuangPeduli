import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/models/kebutuhan_model.dart';
import 'package:ruangpeduliapp/panti/profile_panti/models/profile_model.dart';

class MockApi {
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

void main() {
  group('MockApi helper', () {
    test('getProfile mengembalikan data profil dummy', () async {
      final api = MockApi();
      final profile = await api.getProfile();

      expect(profile.id, 1);
      expect(profile.namaPanti, 'Panti Kasih');
      expect(profile.email, 'panti@test.com');
    });

    test('getKebutuhan mengembalikan daftar kebutuhan dummy', () async {
      final api = MockApi();
      final kebutuhan = await api.getKebutuhan();

      expect(kebutuhan, hasLength(2));
      expect(kebutuhan.first.nama, 'Beras');
      expect(kebutuhan.first.satuan, 'Kg');
    });

    test('aksi mutasi dummy mengembalikan true', () async {
      final api = MockApi();
      final profile = await api.getProfile();
      final kebutuhan = KebutuhanModel(
        id: 3,
        nama: 'Susu',
        jumlah: 4,
        satuan: 'Pcs',
      );

      expect(await api.updateProfile(profile), true);
      expect(await api.addKebutuhan(kebutuhan), true);
      expect(await api.deleteKebutuhan(3), true);
    });
  });
}
