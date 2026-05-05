import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/homepage/state/home_panti_state.dart';
import 'package:ruangpeduliapp/panti/homepage/models/berita_model.dart';

/// Fake API
class FakeHomeApi {
  Future<List<BeritaModel>> getBerita() async {
    return [
      BeritaModel(
        id: 1,
        judul: 'Test',
        isi: 'Isi',
        thumbnail: '',
        createdAt: '2024-01-01',
      ),
    ];
  }
}

/// Error API
class ErrorHomeApi {
  Future<List<BeritaModel>> getBerita() async {
    throw Exception('Error');
  }
}

void main() {
  group('HomeState Test', () {

    test('loadBerita success', () async {
      final state = HomePantiState(api: FakeHomeApi());

      await state.loadBerita();

      expect(state.beritaList.length, 1);
      expect(state.error, isNull);
      expect(state.isLoading, false);
    });

    test('loadBerita error', () async {
      final state = HomePantiState(api: ErrorHomeApi());

      await state.loadBerita();

      expect(state.beritaList.isEmpty, true);
      expect(state.error, isNotNull);
      expect(state.isLoading, false);
    });

  });
}