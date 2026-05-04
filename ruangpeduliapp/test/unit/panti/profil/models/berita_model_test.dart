import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/models/berita_model.dart';

void main() {
  group('BeritaModel Test', () {

    // =========================
    // FROM JSON
    // =========================
    test('fromJson harus menghasilkan object yang benar', () {
      final json = {
        'id': 1,
        'judul': 'Kegiatan Panti',
        'deskripsi': 'Anak-anak belajar bersama',
        'gambar': 'image.jpg',
        'created_at': '2024-01-01',
      };

      final model = BeritaModel.fromJson(json);

      expect(model.id, 1);
      expect(model.judul, 'Kegiatan Panti');
      expect(model.deskripsi, 'Anak-anak belajar bersama');
      expect(model.gambar, 'image.jpg');
      expect(model.createdAt, '2024-01-01');
    });

    // =========================
    // TO JSON
    // =========================
    test('toJson harus menghasilkan map yang benar', () {
      final model = BeritaModel(
        id: 2,
        judul: 'Donasi Masuk',
        deskripsi: 'Terima kasih donatur',
        gambar: null,
        createdAt: '2024-01-02',
      );

      final json = model.toJson();

      expect(json['id'], 2);
      expect(json['judul'], 'Donasi Masuk');
      expect(json['deskripsi'], 'Terima kasih donatur');
      expect(json['gambar'], null);
      expect(json['created_at'], '2024-01-02');
    });

    // =========================
    // CONSISTENCY TEST
    // =========================
    test('fromJson -> toJson harus konsisten', () {
      final originalJson = {
        'id': 3,
        'judul': 'Acara Baru',
        'deskripsi': 'Event di panti',
        'gambar': 'event.png',
        'created_at': '2024-01-03',
      };

      final model = BeritaModel.fromJson(originalJson);
      final resultJson = model.toJson();

      expect(resultJson, originalJson);
    });

    // =========================
    // NULL IMAGE TEST
    // =========================
    test('gambar boleh null', () {
      final json = {
        'id': 4,
        'judul': 'Posting tanpa gambar',
        'deskripsi': 'Hanya teks',
        'gambar': null,
        'created_at': '2024-01-04',
      };

      final model = BeritaModel.fromJson(json);

      expect(model.gambar, null);
    });

  });
}