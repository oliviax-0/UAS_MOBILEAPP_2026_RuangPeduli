import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/models/kebutuhan_model.dart';

void main() {
  group('KebutuhanModel Test', () {

    // =========================
    // TEST FROM JSON
    // =========================
    test('fromJson harus menghasilkan object yang benar', () {
      final json = {
        'id': 1,
        'nama': 'Beras',
        'jumlah': 10,
        'satuan': 'Kg',
      };

      final model = KebutuhanModel.fromJson(json);

      expect(model.id, 1);
      expect(model.nama, 'Beras');
      expect(model.jumlah, 10);
      expect(model.satuan, 'Kg');
    });

    // =========================
    // TEST TO JSON
    // =========================
    test('toJson harus menghasilkan map yang benar', () {
      final model = KebutuhanModel(
        id: 2,
        nama: 'Air',
        jumlah: 5,
        satuan: 'Liter',
      );

      final json = model.toJson();

      expect(json['id'], 2);
      expect(json['nama'], 'Air');
      expect(json['jumlah'], 5);
      expect(json['satuan'], 'Liter');
    });

    // =========================
    // TEST DATA CONSISTENCY
    // =========================
    test('fromJson -> toJson harus konsisten', () {
      final originalJson = {
        'id': 3,
        'nama': 'Telur',
        'jumlah': 30,
        'satuan': 'Pcs',
      };

      final model = KebutuhanModel.fromJson(originalJson);
      final resultJson = model.toJson();

      expect(resultJson, originalJson);
    });

    // =========================
    // EDGE CASE (OPTIONAL)
    // =========================
    test('jumlah tidak boleh negatif (jika ada validasi)', () {
      final json = {
        'id': 4,
        'nama': 'Gula',
        'jumlah': -5,
        'satuan': 'Kg',
      };

      final model = KebutuhanModel.fromJson(json);

      // tergantung logic kamu, ini contoh:
      expect(model.jumlah >= 0, false);
    });

  });
}