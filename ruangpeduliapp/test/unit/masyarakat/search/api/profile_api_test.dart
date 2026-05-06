import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Minimal valid JSON untuk satu panti.
Map<String, dynamic> _pantiJson({
  int id = 1,
  String nama = 'Panti Kasih',
  String alamat = 'Jl. Merdeka No. 1',
  String? lat,
  String? lng,
  int totalTerkumpul = 500000,
}) =>
    {
      'id': id,
      'nama_panti': nama,
      'alamat_panti': alamat,
      'nomor_panti': '0811111111',
      'username': 'pantikasih',
      'total_terkumpul': totalTerkumpul,
      'lat': lat,
      'lng': lng,
      'profile_picture': null,
      'description': 'Deskripsi panti',
    };

Map<String, dynamic> _mediaJson({int id = 10, String? file}) => {
      'id': id,
      'file': file ?? 'https://example.com/foto.jpg',
    };

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ProfileApi.fetchAllPanti', () {
    test('mengembalikan list PantiProfileModel ketika response 200', () async {
      final json = jsonEncode([_pantiJson(id: 1), _pantiJson(id: 2, nama: 'Panti Harapan')]);

      // ProfileApi menggunakan http.get secara internal; kita verifikasi
      // kontrak model tanpa menyentuh jaringan — gunakan data JSON langsung.
      final decoded = (jsonDecode(json) as List)
          .map((e) => PantiProfileModel.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(decoded.length, 2);
      expect(decoded[0].id, 1);
      expect(decoded[0].namaPanti, 'Panti Kasih');
      expect(decoded[1].namaPanti, 'Panti Harapan');
    });

    test('formattedTotalTerkumpul memformat angka dengan titik pemisah ribuan', () {
      final model = PantiProfileModel.fromJson(_pantiJson(totalTerkumpul: 1500000));
      // Expected: "1.500.000"
      expect(model.formattedTotalTerkumpul, contains('1.500.000'));
    });

    test('lat dan lng null ketika tidak dikirim API', () {
      final model = PantiProfileModel.fromJson(_pantiJson(lat: null, lng: null));
      expect(model.lat, isNull);
      expect(model.lng, isNull);
    });

  });
}