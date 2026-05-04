import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:ruangpeduliapp/panti/profile_panti/models/kebutuhan_model.dart';
import 'package:ruangpeduliapp/panti/profile_panti/api/kebutuhan_api.dart';

// =========================
// FAKE CLIENT (TANPA MOCKITO)
// =========================
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
  group('KebutuhanApi Test (tanpa mockito)', () {

    // =========================
    // SUCCESS TEST
    // =========================
    test('getKebutuhan return list jika sukses', () async {
      final client = FakeClient((request) {
        return http.Response(jsonEncode([
          {
            'id': 1,
            'nama': 'Beras',
            'jumlah': 10,
            'satuan': 'Kg'
          },
          {
            'id': 2,
            'nama': 'Air',
            'jumlah': 5,
            'satuan': 'Liter'
          }
        ]), 200);
      });

      final api = KebutuhanApi(client: client);

      final result = await api.getKebutuhan();

      expect(result.length, 2);
      expect(result.first.nama, 'Beras');
      expect(result[1].nama, 'Air');
    });

    // =========================
    // ERROR TEST
    // =========================
    test('getKebutuhan throw error jika gagal', () async {
      final client = FakeClient((request) {
        return http.Response('Error', 500);
      });

      final api = KebutuhanApi(client: client);

      expect(() => api.getKebutuhan(), throwsException);
    });

  });
}