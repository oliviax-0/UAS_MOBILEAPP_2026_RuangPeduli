import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:ruangpeduliapp/panti/inventaris/api/residents_api.dart';
import 'package:ruangpeduliapp/panti/inventaris/models/anggota_model.dart';
import '../../../../utils/fake_http_client.dart';

void main() {
  group('ResidentsApi Test', () {

    test('getResidents success', () async {
      final client = FakeClient((request) {
        return http.Response(jsonEncode([
          {
            'id': 1,
            'nama': 'Budi',
            'divisi': 'Dapur',
            'telepon': '08123456789',
          }
        ]), 200);
      });

      final api = ResidentsApi(client: client);

      final result = await api.getResidents();

      expect(result, isA<List<AnggotaModel>>());
      expect(result.length, 1);
      expect(result.first.nama, 'Budi');
    });

    test('getResidents error', () async {
      final client = FakeClient((request) {
        return http.Response('Error', 500);
      });

      final api = ResidentsApi(client: client);

      expect(api.getResidents(), throwsException);
    });

    test('addResident success', () async {
      final client = FakeClient((request) {
        return http.Response('OK', 200);
      });

      final api = ResidentsApi(client: client);

      final anggota = AnggotaModel(
        id: 1,
        nama: 'Budi',
        divisi: 'Dapur',
        telepon: '08123456789',
      );

      final result = await api.addResident(anggota);

      expect(result, true);
    });

    test('deleteResident success', () async {
      final client = FakeClient((request) {
        return http.Response('OK', 200);
      });

      final api = ResidentsApi(client: client);

      final result = await api.deleteResident(1);

      expect(result, true);
    });

  });
}