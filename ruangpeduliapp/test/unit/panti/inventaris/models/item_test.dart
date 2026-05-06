import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/inventaris/models/item_model.dart';

void main() {
  group('ItemModel Test', () {

    // =========================
    // FROM JSON
    // =========================
    test('fromJson berhasil', () {
      final json = {
        'id': 1,
        'nama': 'Beras',
        'kategori': 'Makanan',
        'stok': 20,
        'satuan': 'Kg',
      };

      final item = ItemModel.fromJson(Map<String, dynamic>.from(json));

      expect(item.id, 1);
      expect(item.nama, 'Beras');
      expect(item.kategori, 'Makanan');
      expect(item.stok, 20); // Pastikan ini sesuai dengan tipe di model (int/double)
      expect(item.satuan, 'Kg');
    });

    // =========================
    // TO JSON
    // =========================
    test('toJson berhasil', () {
      final item = ItemModel(
        id: 1,
        nama: 'Beras',
        kategori: 'Makanan',
        stok: 20,
        satuan: 'Kg',
      );

      final Map<String, dynamic> json = item.toJson();

      expect(json['id'], 1);
      expect(json['nama'], 'Beras');
      expect(json['kategori'], 'Makanan');
      expect(json['stok'], isA<num>()); // Mengantisipasi jika model mengembalikan num/double
      expect(json['satuan'], 'Kg');
    });

    // =========================
    // CONSISTENCY TEST
    // =========================
    test('fromJson -> toJson harus konsisten', () {
      final Map<String, dynamic> originalJson = {
        'id': 3,
        'nama': 'Minyak',
        'kategori': 'Sembako',
        'stok': 10,
        'satuan': 'Liter',
      };

      final model = ItemModel.fromJson(originalJson);
      final resultJson = model.toJson();

      // Menggunakan expect individu jika urutan key atau tipe numerik (int vs double) bermasalah
      expect(resultJson['id'], originalJson['id']);
      expect(resultJson['nama'], originalJson['nama']);
      expect(resultJson['stok'], originalJson['stok']);
    });

    // =========================
    // NULLABILITY TEST
    // =========================
    test('harus berhasil meskipun id null (item baru)', () {
      final json = {'id': null, 'nama': 'Garam', 'kategori': 'Bumbu', 'stok': 5, 'satuan': 'Bks'};
      final item = ItemModel.fromJson(json);
      expect(item.id, isNull);
      expect(item.nama, 'Garam');
    });
  });
}