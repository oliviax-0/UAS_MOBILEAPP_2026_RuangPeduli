// test/mocks/mock_api.dart

import 'package:ruangpeduliapp/panti/homepage/models/berita_model.dart';
import 'package:test/test.dart';

class MockHomeApi {
  /// =========================
  /// GET BERITA
  /// =========================
  Future<List<BeritaModel>> getBerita() async {
    return [
      BeritaModel(
        id: 1,
        judul: 'Judul Mock',
        isi: 'Isi Mock',
        thumbnail: '',
        createdAt: '2024-01-01',
      ),
    ];
  }

  /// =========================
  /// SEARCH BERITA
  /// =========================
  Future<List<BeritaModel>> searchBerita(String query) async {
    return [
      BeritaModel(
        id: 1,
        judul: 'Hasil $query',
        isi: 'Isi Mock',
        thumbnail: '',
        createdAt: '2024-01-01',
      ),
    ];
  }

  /// =========================
  /// TAMBAH BERITA
  /// =========================
  Future<bool> tambahBerita(BeritaModel berita) async {
    return true;
  }

  /// =========================
  /// VOTE
  /// =========================
  Future<bool> upvote(int id) async {
    return true;
  }

  Future<bool> downvote(int id) async {
    return true;
  }
}

void main() {
  group('MockHomeApi', () {
    test('getBerita returns mock berita', () async {
      final api = MockHomeApi();

      final result = await api.getBerita();

      expect(result, hasLength(1));
      expect(result.first.judul, 'Judul Mock');
    });

    test('searchBerita returns query result', () async {
      final api = MockHomeApi();

      final result = await api.searchBerita('beras');

      expect(result, hasLength(1));
      expect(result.first.judul, 'Hasil beras');
    });

    test('tambahBerita and vote actions return true', () async {
      final api = MockHomeApi();
      final berita = BeritaModel(
        id: 1,
        judul: 'Judul',
        isi: 'Isi',
        thumbnail: '',
        createdAt: '2024-01-01',
      );

      expect(await api.tambahBerita(berita), true);
      expect(await api.upvote(1), true);
      expect(await api.downvote(1), true);
    });
  });
}
