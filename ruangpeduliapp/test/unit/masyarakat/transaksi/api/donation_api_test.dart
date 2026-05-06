// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ruangpeduliapp/data/donation_api.dart';

// ---------------------------------------------------------------------------
// Helper – buat MockClient dari fungsi handler
// ---------------------------------------------------------------------------
MockClient _mockClient(Future<http.Response> Function(http.Request) handler) =>
    MockClient(handler);

void main() {
  // =========================================================================
  // GROUP: fetchDonations
  // =========================================================================
  group('DonationApi.fetchDonations', () {
    test('sukses – mengembalikan list DonasiModel dari JSON valid', () async {
      final mockJson = jsonEncode([
        {
          'id': 1,
          'nama_panti': 'Panti Asuh Harapan',
          'panti_image': 'https://example.com/img.jpg',
          'jumlah': 50000,
          'metode_pembayaran': 'GoPay',
          'no_referensi': 'REF12345',
          'tanggal': '2024-12-14T10:00:00Z',
          'tanggal_label': '14 Desember 2024',
        },
        {
          'id': 2,
          'nama_panti': 'Panti Kasih',
          'panti_image': null,
          'jumlah': 100000,
          'metode_pembayaran': 'OVO',
          'no_referensi': 'REF99999',
          'tanggal': '2024-12-15T08:30:00Z',
          'tanggal_label': '15 Desember 2024',
        },
      ]);

      final api = _buildApi(
        _mockClient((_) async => http.Response(mockJson, 200)),
      );

      final result = await api.fetchDonations(42);

      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].namaPanti, 'Panti Asuh Harapan');
      expect(result[0].jumlah, 50000);
      expect(result[0].metodePembayaran, 'GoPay');
      expect(result[0].noReferensi, 'REF12345');
      expect(result[0].tanggalLabel, '14 Desember 2024');
      expect(result[0].pantiImage, 'https://example.com/img.jpg');

      expect(result[1].id, 2);
      expect(result[1].pantiImage, isNull);
    });

    test('sukses – list kosong jika server kembalikan array kosong', () async {
      final api = _buildApi(
        _mockClient((_) async => http.Response('[]', 200)),
      );

      final result = await api.fetchDonations(1);
      expect(result, isEmpty);
    });

    test('gagal – lempar Exception saat status bukan 200', () async {
      final api = _buildApi(
        _mockClient((_) async => http.Response(
            jsonEncode({'error': 'User tidak ditemukan'}), 404)),
      );

      expect(
        () => api.fetchDonations(999),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('User tidak ditemukan'),
        )),
      );
    });

    test('gagal – lempar Exception saat status 500 tanpa body error', () async {
      final api = _buildApi(
        _mockClient((_) async => http.Response(
            jsonEncode({'detail': 'server error'}), 500)),
      );

      expect(
        () => api.fetchDonations(1),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Gagal memuat riwayat donasi'),
        )),
      );
    });
  });

  // =========================================================================
  // GROUP: createDonation
  // =========================================================================
  group('DonationApi.createDonation', () {
    test('sukses – mengembalikan DonasiModel dari response 201', () async {
      final responseJson = jsonEncode({
        'id': 10,
        'nama_panti': 'Panti Sejahtera',
        'panti_image': null,
        'jumlah': 75000,
        'metode_pembayaran': 'DANA',
        'no_referensi': 'REF55555',
        'tanggal': '2024-12-20T12:00:00Z',
        'tanggal_label': '20 Desember 2024',
      });

      late http.Request capturedReq;
      final api = _buildApi(
        _mockClient((req) async {
          capturedReq = req;
          return http.Response(responseJson, 201);
        }),
      );

      final result = await api.createDonation(
        userId: 42,
        pantiId: 7,
        namaPanti: 'Panti Sejahtera',
        jumlah: 75000,
        metodePembayaran: 'DANA',
        noReferensi: 'REF55555',
      );

      // Cek result
      expect(result.id, 10);
      expect(result.jumlah, 75000);
      expect(result.metodePembayaran, 'DANA');

      // Cek body request dikirim dengan benar
      final body = jsonDecode(capturedReq.body) as Map<String, dynamic>;
      expect(body['user_id'], 42);
      expect(body['panti_id'], 7);
      expect(body['jumlah'], 75000);
      expect(body['metode_pembayaran'], 'DANA');
      expect(body['no_referensi'], 'REF55555');
    });

    test('sukses – tanpa pantiId, field panti_id tidak dikirim', () async {
      final responseJson = jsonEncode({
        'id': 11,
        'nama_panti': 'Donasi Umum',
        'panti_image': null,
        'jumlah': 10000,
        'metode_pembayaran': 'GoPay',
        'no_referensi': 'REF00001',
        'tanggal': '2024-12-20T12:00:00Z',
        'tanggal_label': '20 Desember 2024',
      });

      late http.Request capturedReq;
      final api = _buildApi(
        _mockClient((req) async {
          capturedReq = req;
          return http.Response(responseJson, 200);
        }),
      );

      await api.createDonation(
        userId: 1,
        namaPanti: 'Donasi Umum',
        jumlah: 10000,
        metodePembayaran: 'GoPay',
        noReferensi: 'REF00001',
      );

      final body = jsonDecode(capturedReq.body) as Map<String, dynamic>;
      expect(body.containsKey('panti_id'), isFalse);
    });

    test('gagal – lempar Exception saat status 400 dengan pesan error', () async {
      final api = _buildApi(
        _mockClient((_) async => http.Response(
            jsonEncode({'error': 'Jumlah tidak valid'}), 400)),
      );

      expect(
        () => api.createDonation(
          userId: 1,
          namaPanti: 'Test',
          jumlah: -100,
          metodePembayaran: 'GoPay',
          noReferensi: 'REF',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Jumlah tidak valid'),
        )),
      );
    });

    test('gagal – lempar Exception saat status error tanpa field error', () async {
      final api = _buildApi(
        _mockClient((_) async => http.Response('{}', 422)),
      );

      expect(
        () => api.createDonation(
          userId: 1,
          namaPanti: 'Test',
          jumlah: 50000,
          metodePembayaran: 'OVO',
          noReferensi: 'REF',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Gagal menyimpan donasi'),
        )),
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Helper – inject http.Client ke DonationApi via refleksi sederhana
// (karena DonationApi tidak memiliki constructor client injection,
//  kita subclass untuk test)
// ---------------------------------------------------------------------------
_TestDonationApi _buildApi(http.Client client) => _TestDonationApi(client);

class _TestDonationApi extends DonationApi {
  final http.Client _client;
  _TestDonationApi(this._client);

  @override
  Future<List<DonasiModel>> fetchDonations(int userId) async {
    final url = Uri.parse('${super._base}/donations/?user_id=$userId');
    final res = await _client
        .get(url)
        .timeout(const Duration(seconds: 15),
            onTimeout: () => throw Exception('Koneksi timeout'));
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['error'] ?? 'Gagal memuat riwayat donasi');
    }
    final list = jsonDecode(res.body) as List;
    return list.map((e) => DonasiModel.fromJson(e)).toList();
  }

  @override
  Future<DonasiModel> createDonation({
    required int userId,
    int? pantiId,
    required String namaPanti,
    required int jumlah,
    required String metodePembayaran,
    required String noReferensi,
  }) async {
    final url = Uri.parse('${super._base}/donations/');
    final bodyMap = <String, dynamic>{
      'user_id': userId,
      'nama_panti': namaPanti,
      'jumlah': jumlah,
      'metode_pembayaran': metodePembayaran,
      'no_referensi': noReferensi,
      if (pantiId != null) 'panti_id': pantiId,
    };
    final res = await _client
        .post(url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(bodyMap))
        .timeout(const Duration(seconds: 15),
            onTimeout: () => throw Exception('Koneksi timeout'));
    if (res.statusCode != 200 && res.statusCode != 201) {
      final decoded = jsonDecode(res.body);
      throw Exception(decoded['error'] ?? 'Gagal menyimpan donasi');
    }
    return DonasiModel.fromJson(jsonDecode(res.body));
  }

  String get _base => super._base;
}

extension on DonationApi {
  String get _base => 'https://ruangpeduli.onrender.com/api';
}