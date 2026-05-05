import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/homepage/state/search_state.dart';
import 'package:ruangpeduliapp/panti/homepage/models/berita_model.dart';

/// Fake API
class FakeSearchApi {
  Future<List<BeritaModel>> searchBerita(String query) async {
    return [
      BeritaModel(
        id: 1,
        judul: 'Test $query',
        isi: 'Isi',
        thumbnail: '',
        createdAt: '2024-01-01',
      ),
    ];
  }
}

/// Error API
class ErrorSearchApi {
  Future<List<BeritaModel>> searchBerita(String query) async {
    throw Exception('Error');
  }
}

void main() {
  group('SearchState Test', () {

    test('search success', () async {
      final state = SearchState(api: FakeSearchApi());

      await state.search('beras');

      expect(state.result.length, 1);
      expect(state.result.first.judul.contains('beras'), true);
      expect(state.error, isNull);
      expect(state.isLoading, false);
    });

    test('search error', () async {
      final state = SearchState(api: ErrorSearchApi());

      await state.search('beras');

      expect(state.result.isEmpty, true);
      expect(state.error, isNotNull);
      expect(state.isLoading, false);
    });

  });
}