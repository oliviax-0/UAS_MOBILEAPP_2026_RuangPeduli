import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/homepage/state/berita_baru_state.dart';
import 'package:ruangpeduliapp/panti/homepage/models/berita_model.dart';

/// Fake API
class FakeTambahApi {
  Future<bool> tambahBerita(BeritaModel berita) async {
    return true;
  }
}

/// Error API
class ErrorTambahApi {
  Future<bool> tambahBerita(BeritaModel berita) async {
    throw Exception('Error');
  }
}

void main() {
  group('TambahState Test', () {

    test('tambahBerita success', () async {
      final state = BeritaBaruState(api: FakeTambahApi());

      final berita = BeritaModel(
        id: 1,
        judul: 'Judul',
        isi: 'Isi',
        thumbnail: '',
        createdAt: '2024-01-01',
      );

      final result = await state.tambahBerita(berita);

      expect(result, true);
      expect(state.error, isNull);
    });

    test('tambahBerita error', () async {
      final state = BeritaBaruState(api: ErrorTambahApi());

      final berita = BeritaModel(
        id: 1,
        judul: 'Judul',
        isi: 'Isi',
        thumbnail: '',
        createdAt: '2024-01-01',
      );

      final result = await state.tambahBerita(berita);

      expect(result, false);
      expect(state.error, isNotNull);
    });

  });
}