import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/models/berita_model.dart';

void main() {
  group('BeritaModel Test', () {

    test('fromJson berhasil', () {
      final json = {
        'id': 1,
        'judul': 'Judul Test',
        'deskripsi': 'Isi Test',
        'gambar': 'image.jpg',
        'created_at': '2024-01-01',
      };

      final model = BeritaModel.fromJson(json);

      expect(model.id, 1);
      expect(model.judul, 'Judul Test');
      expect(model.deskripsi, 'Isi Test');
      expect(model.gambar, 'image.jpg');
    });

    test('toJson berhasil', () {
      final model = BeritaModel(
        id: 1,
        judul: 'Judul Test',
        deskripsi: 'Isi Test',
        gambar: 'image.jpg',
        createdAt: '2024-01-01',
      );

      final json = model.toJson();

      expect(json['judul'], 'Judul Test');
      expect(json['deskripsi'], 'Isi Test');
      expect(json['gambar'], 'image.jpg');
    });

  });
}
