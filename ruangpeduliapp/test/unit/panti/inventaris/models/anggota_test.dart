import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/inventaris/models/anggota_model.dart';

void main() {
  group('AnggotaModel Test', () {

    // =========================
    // FROM JSON
    // =========================
    test('fromJson berhasil', () {
      final json = {
        'id': 1,
        'nama': 'Budi',
        'divisi': 'Dapur',
        'telepon': '08123456789',
      };

      // Menggunakan casting eksplisit untuk menghindari Type Error
      final anggota = AnggotaModel.fromJson(Map<String, dynamic>.from(json));

      expect(anggota.id, 1);
      expect(anggota.nama, 'Budi');
      expect(anggota.divisi, 'Dapur');
      expect(anggota.telepon, '08123456789');
    });

    // =========================
    // TO JSON
    // =========================
    test('toJson berhasil', () {
      final anggota = AnggotaModel(
        id: 1,
        nama: 'Budi',
        divisi: 'Dapur',
        telepon: '08123456789',
      );

      final Map<String, dynamic> json = anggota.toJson();

      expect(json['id'], 1);
      expect(json['nama'], 'Budi');
      expect(json['divisi'], 'Dapur');
      expect(json['telepon'], '08123456789');
    });

    // =========================
    // CONSISTENCY TEST
    // =========================
    test('fromJson -> toJson harus konsisten', () {
      final Map<String, dynamic> originalJson = {
        'id': 2,
        'nama': 'Ani',
        'divisi': 'Kebersihan',
        'telepon': '08987654321',
      };

      final model = AnggotaModel.fromJson(originalJson);
      final resultJson = model.toJson();

      // Pengecekan per-field lebih aman daripada membandingkan Map secara langsung
      expect(resultJson['id'], originalJson['id']);
      expect(resultJson['nama'], originalJson['nama']);
      expect(resultJson['divisi'], originalJson['divisi']);
      expect(resultJson['telepon'], originalJson['telepon']);
    });

    // =========================
    // NULLABILITY TEST
    // =========================
    test('harus berhasil meskipun id null (anggota baru)', () {
      final json = {'id': null, 'nama': 'Siti', 'divisi': 'Admin', 'telepon': '0811'};
      final model = AnggotaModel.fromJson(Map<String, dynamic>.from(json));
      expect(model.id, isNull);
      expect(model.nama, 'Siti');
    });
  });
}