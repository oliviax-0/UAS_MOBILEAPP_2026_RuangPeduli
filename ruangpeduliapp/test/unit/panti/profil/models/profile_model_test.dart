import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/models/profile_model.dart';

void main() {
  group('ProfileModel Test', () {

    // =========================
    // FROM JSON
    // =========================
    test('fromJson harus menghasilkan object yang benar', () {
      final json = {
        'id': 1,
        'nama_panti': 'Panti Kasih',
        'email': 'panti@mail.com',
        'no_telepon': '08123456789',
        'alamat': 'Jakarta',
        'deskripsi': 'Panti asuhan anak',
        'foto_profil': 'foto.jpg',
      };

      final model = ProfileModel.fromJson(json);

      expect(model.id, 1);
      expect(model.namaPanti, 'Panti Kasih');
      expect(model.email, 'panti@mail.com');
      expect(model.noTelepon, '08123456789');
      expect(model.alamat, 'Jakarta');
      expect(model.deskripsi, 'Panti asuhan anak');
      expect(model.fotoProfil, 'foto.jpg');
    });

    // =========================
    // TO JSON
    // =========================
    test('toJson harus menghasilkan map yang benar', () {
      final model = ProfileModel(
        id: 2,
        namaPanti: 'Panti Harapan',
        email: 'harapan@mail.com',
        noTelepon: '08987654321',
        alamat: 'Bandung',
        deskripsi: 'Panti untuk anak-anak',
        fotoProfil: null,
      );

      final json = model.toJson();

      expect(json['id'], 2);
      expect(json['nama_panti'], 'Panti Harapan');
      expect(json['email'], 'harapan@mail.com');
      expect(json['no_telepon'], '08987654321');
      expect(json['alamat'], 'Bandung');
      expect(json['deskripsi'], 'Panti untuk anak-anak');
      expect(json['foto_profil'], null);
    });

    // =========================
    // CONSISTENCY TEST
    // =========================
    test('fromJson -> toJson harus konsisten', () {
      final originalJson = {
        'id': 3,
        'nama_panti': 'Panti Sejahtera',
        'email': 'sejahtera@mail.com',
        'no_telepon': '08111111111',
        'alamat': 'Surabaya',
        'deskripsi': 'Panti sosial',
        'foto_profil': 'image.png',
      };

      final model = ProfileModel.fromJson(originalJson);
      final resultJson = model.toJson();

      expect(resultJson, originalJson);
    });

    // =========================
    // NULL FOTO TEST
    // =========================
    test('fotoProfil boleh null', () {
      final json = {
        'id': 4,
        'nama_panti': 'Panti Damai',
        'email': 'damai@mail.com',
        'no_telepon': '08222222222',
        'alamat': 'Yogyakarta',
        'deskripsi': 'Panti damai',
        'foto_profil': null,
      };

      final model = ProfileModel.fromJson(json);

      expect(model.fotoProfil, null);
    });

  });
}