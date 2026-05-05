import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:ruangpeduliapp/data/content_api.dart';

/// Fake HTTP Client
class FakeClient extends http.BaseClient {
  final http.Response Function(http.Request request) handler;

  FakeClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final req = request as http.Request;
    final response = handler(req);

    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  group('ContentApi Test', () {

    test('fetchBeritas success', () async {
      final client = FakeClient((request) {
        return http.Response(jsonEncode([
          {
            'id': 1,
            'title': 'Judul Test',
            'content': 'Isi Test',
            'thumbnail': 'image.jpg',
            'author_name': 'Admin',
            'panti_name': 'Panti Test',
            'panti': 1,
            'panti_profile_picture': null,
            'created_at': '2024-01-01',
            'upvote_count': 3,
            'downvote_count': 1,
          }
        ]), 200);
      });

      final api = ContentApi(client: client);

      final result = await api.fetchBeritas();

      expect(result, isA<List<BeritaModel>>());
      expect(result.length, 1);
      expect(result.first.title, 'Judul Test');
      expect(result.first.content, 'Isi Test');
      expect(result.first.thumbnail, 'image.jpg');
    });

    test('fetchBeritas error', () async {
      final client = FakeClient((request) {
        return http.Response('Error', 500);
      });

      final api = ContentApi(client: client);

      expect(() => api.fetchBeritas(), throwsException);
    });

  });
}
