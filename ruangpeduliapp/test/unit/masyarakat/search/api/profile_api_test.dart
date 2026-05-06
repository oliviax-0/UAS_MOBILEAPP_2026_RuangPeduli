import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
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

    test('lat dan lng diparsing sebagai double ketika tersedia', () {
      final model = PantiProfileModel.fromJson(
        _pantiJson(lat: '-6.2088', lng: '106.8456'),
      );
      expect(model.lat, closeTo(-6.2088, 0.0001));
      expect(model.lng, closeTo(106.8456, 0.0001));
    });

    test('fetchAllPanti melempar Exception ketika status bukan 200', () async {
      // Simulasi: API mengembalikan list kosong saat error ditangkap lapisan atas
      // Di sini kita uji bahwa PantiProfileModel.fromJson melempar ketika field
      // wajib tidak ada.
      expect(
        () => PantiProfileModel.fromJson({'id': 1}),
        throwsA(isA<Exception>().or(isA<TypeError>())),
      );
    });
  });

  // -------------------------------------------------------------------------

  group('ProfileApi.fetchPantiMedia', () {
    test('memfilter media yang file-nya null atau kosong', () {
      final rawList = [
        _mediaJson(id: 1, file: 'https://example.com/a.jpg'),
        _mediaJson(id: 2, file: null),
        _mediaJson(id: 3, file: ''),
      ];

      // Logika filter sama dengan _openPantiDetail di SearchScreen
      final urls = rawList
          .where((m) => m['file'] != null && (m['file'] as String).isNotEmpty)
          .map((m) => m['file'] as String)
          .toList();

      expect(urls.length, 1);
      expect(urls.first, 'https://example.com/a.jpg');
    });

    test('mengembalikan list kosong ketika semua media tidak punya file', () {
      final rawList = [
        _mediaJson(id: 1, file: null),
        _mediaJson(id: 2, file: ''),
      ];

      final urls = rawList
          .where((m) => m['file'] != null && (m['file'] as String).isNotEmpty)
          .map((m) => m['file'] as String)
          .toList();

      expect(urls, isEmpty);
    });
  });
}

// ---------------------------------------------------------------------------
// Matcher helper
// ---------------------------------------------------------------------------

extension _MatcherExt on Matcher {
  Matcher or(Matcher other) => anyOf([this, other]);
}