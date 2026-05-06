import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/inventaris/models/kategori_model.dart';

void main() {
  group('KategoriModel Test', () {

    test('fromJson berhasil', () {
      final json = {
        'id': 1,
        'nama': 'Makanan',
      };

      final kategori = KategoriModel.fromJson(json);

      expect(kategori.id, 1);
      expect(kategori.nama, 'Makanan');
    });

    test('toJson berhasil', () {
      final kategori = KategoriModel(
        id: 1,
        nama: 'Makanan',
      );

      final json = kategori.toJson();

      expect(json['id'], 1);
      expect(json['nama'], 'Makanan');
    });

  });
}