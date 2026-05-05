import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/homepage/state/berita_detail_state.dart';

/// Fake API
class FakeDetailApi {
  Future<bool> upvote(int id) async {
    return true;
  }

  Future<bool> downvote(int id) async {
    return true;
  }
}

/// Error API
class ErrorDetailApi {
  Future<bool> upvote(int id) async {
    throw Exception('Error');
  }

  Future<bool> downvote(int id) async {
    throw Exception('Error');
  }
}

void main() {
  group('DetailState Test', () {

    test('upvote success', () async {
      final state = BeritaDetailState(api: FakeDetailApi());

      final result = await state.upvote(1);

      expect(result, true);
      expect(state.error, isNull);
    });

    test('downvote success', () async {
      final state = BeritaDetailState(api: FakeDetailApi());

      final result = await state.downvote(1);

      expect(result, true);
      expect(state.error, isNull);
    });

    test('upvote error', () async {
      final state = BeritaDetailState(api: ErrorDetailApi());

      final result = await state.upvote(1);

      expect(result, false);
      expect(state.error, isNotNull);
    });

    test('downvote error', () async {
      final state = BeritaDetailState(api: ErrorDetailApi());

      final result = await state.downvote(1);

      expect(result, false);
      expect(state.error, isNotNull);
    });

  });
}