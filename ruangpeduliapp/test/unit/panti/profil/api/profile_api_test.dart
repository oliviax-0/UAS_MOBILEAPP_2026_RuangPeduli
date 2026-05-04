import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:ruangpeduliapp/panti/profile_panti/models/profile_model.dart';
import 'package:ruangpeduliapp/panti/profile_panti/api/profile_api.dart';

// =========================
// FAKE CLIENT
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
  group('ProfileApi Test', () {

    // =========================
    // GET PROFILE SUCCESS
    // =========================
    test('getProfile return data jika sukses', () async {
      final client = FakeClient((request) {
        return http.Response(jsonEncode({
          'id': 1,
          'nama_panti': 'Panti Kasih',
          'email': 'panti@mail.com',
          'no_telepon': '08123456789',
          'alamat': 'Jakarta',
          'deskripsi': 'Panti asuhan',
          'foto_profil': 'foto.jpg',
        }), 200);
      });

      final api = ProfileApi(client: client);

      final result = await api.getProfile();

      expect(result.namaPanti, 'Panti Kasih');
      expect(result.email, 'panti@mail.com');
    });

    // =========================
    // GET PROFILE ERROR
    // =========================
    test('getProfile throw error jika gagal', () async {
      final client = FakeClient((request) {
        return http.Response('Error', 500);
      });

      final api = ProfileApi(client: client);

      expect(() => api.getProfile(), throwsException);
    });

    // =========================
    // UPDATE PROFILE SUCCESS
    // =========================
    test('updateProfile return true jika sukses', () async {
      final client = FakeClient((request) {
        return http.Response('OK', 200);
      });

      final api = ProfileApi(client: client);

      final profile = ProfileModel(
        id: 1,
        namaPanti: 'Panti Baru',
        email: 'baru@mail.com',
        noTelepon: '08111111111',
        alamat: 'Bandung',
        deskripsi: 'Deskripsi baru',
        fotoProfil: null,
      );

      final result = await api.updateProfile(profile);

      expect(result, true);
    });

    // =========================
    // UPDATE PROFILE ERROR
    // =========================
    test('updateProfile throw error jika gagal', () async {
      final client = FakeClient((request) {
        return http.Response('Error', 500);
      });

      final api = ProfileApi(client: client);

      final profile = ProfileModel(
        id: 1,
        namaPanti: 'Panti Baru',
        email: 'baru@mail.com',
        noTelepon: '08111111111',
        alamat: 'Bandung',
        deskripsi: 'Deskripsi baru',
        fotoProfil: null,
      );

      expect(() => api.updateProfile(profile), throwsException);
    });

  });
}