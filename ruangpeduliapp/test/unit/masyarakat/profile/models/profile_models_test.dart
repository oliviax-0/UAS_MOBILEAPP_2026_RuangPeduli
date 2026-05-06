import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/data/donation_api.dart';

void main() {
  group('SocietyProfileModel', () {
    test('fromJson creates correct instance', () {
      final json = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'nama_pengguna': 'Test User',
        'alamat': 'Test Address',
        'nomor_telepon': '123456789',
        'jenis_kelamin': 'Laki-laki',
        'profile_picture': 'pic.jpg',
      };
      final model = SocietyProfileModel.fromJson(json);
      expect(model.id, 1);
      expect(model.username, 'testuser');
      expect(model.email, 'test@example.com');
      expect(model.namaPengguna, 'Test User');
      expect(model.alamat, 'Test Address');
      expect(model.nomorTelepon, '123456789');
      expect(model.jenisKelamin, 'Laki-laki');
      expect(model.profilePicture, 'pic.jpg');
    });

    test('fromJson handles null values', () {
      final json = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'nama_pengguna': 'Test User',
        'alamat': 'Test Address',
        'nomor_telepon': null,
        'jenis_kelamin': null,
        'profile_picture': null,
      };
      final model = SocietyProfileModel.fromJson(json);
      expect(model.nomorTelepon, '');
      expect(model.jenisKelamin, '');
      expect(model.profilePicture, null);
    });
  });


  group('DonasiModel', () {
    test('fromJson creates correct instance', () {
      final json = {
        'id': 1,
        'nama_panti': 'Panti Test',
        'panti_image': 'image.jpg',
        'jumlah': 100000,
        'metode_pembayaran': 'Transfer',
        'no_referensi': 'REF123',
        'tanggal': '2023-01-01T00:00:00Z',
        'tanggal_label': '1 Januari 2023',
      };
      final model = DonasiModel.fromJson(json);
      expect(model.id, 1);
      expect(model.namaPanti, 'Panti Test');
      expect(model.jumlah, 100000);
      expect(model.metodePembayaran, 'Transfer');
      expect(model.noReferensi, 'REF123');
      expect(model.tanggal, '2023-01-01T00:00:00Z');
      expect(model.tanggalLabel, '1 Januari 2023');
    });

    test('formattedJumlah formats correctly', () {
      final model = DonasiModel(
        id: 1,
        namaPanti: 'Test',
        jumlah: 1500000,
        metodePembayaran: 'Test',
        noReferensi: 'Test',
        tanggal: '2023-01-01T00:00:00Z',
        tanggalLabel: 'Test',
      );
      expect(model.formattedJumlah, 'Rp1.500.000');
    });

    test('tanggalDateTime parses correctly', () {
      final model = DonasiModel(
        id: 1,
        namaPanti: 'Test',
        jumlah: 1000,
        metodePembayaran: 'Test',
        noReferensi: 'Test',
        tanggal: '2023-01-01T12:00:00Z',
        tanggalLabel: 'Test',
      );
      expect(model.tanggalDateTime.year, 2023);
      expect(model.tanggalDateTime.month, 1);
      expect(model.tanggalDateTime.day, 1);
    });
  });
}