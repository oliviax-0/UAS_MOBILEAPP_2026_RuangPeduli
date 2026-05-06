// test/unit/api/search_api_test.dart
//
// Unit tests untuk lapisan API yang digunakan fitur Search Masyarakat.
// Mencakup: ContentApi (berita, video), ProfileApi (panti, media),
//           KebutuhanApi, serta SearchApi wrapper (jika ada).
//
// Dependency: mockito + build_runner, atau manual stub class.
// Jalankan: flutter test test/unit/api/search_api_test.dart

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart'; // package:http/testing.dart

// ---------------------------------------------------------------------------
// STUB MODELS (duplikat minimal agar test dapat berdiri sendiri)
// Sesuaikan path import dengan struktur proyek Anda.
// ---------------------------------------------------------------------------

class BeritaModel {
  final int id;
  final String title;
  final String content;
  final String pantiName;
  final int? pantiId;
  final String? thumbnail;
  final String? pantiProfilePicture;

  BeritaModel({
    required this.id,
    required this.title,
    required this.content,
    required this.pantiName,
    this.pantiId,
    this.thumbnail,
    this.pantiProfilePicture,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) => BeritaModel(
        id: json['id'] as int,
        title: json['title'] as String,
        content: json['content'] as String,
        pantiName: json['panti_name'] as String? ?? '',
        pantiId: json['panti_id'] as int?,
        thumbnail: json['thumbnail'] as String?,
        pantiProfilePicture: json['panti_profile_picture'] as String?,
      );
}

class VideoModel {
  final int id;
  final String title;
  final String description;
  final String videoUrl;
  final String pantiName;
  final int? pantiId;
  final String? thumbnail;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.pantiName,
    this.pantiId,
    this.thumbnail,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        videoUrl: json['video_url'] as String,
        pantiName: json['panti_name'] as String? ?? '',
        pantiId: json['panti_id'] as int?,
        thumbnail: json['thumbnail'] as String?,
      );
}

class PantiProfileModel {
  final int id;
  final String namaPanti;
  final String username;
  final String nomorPanti;
  final String alamatPanti;
  final String description;
  final String? profilePicture;
  final double totalTerkumpul;

  PantiProfileModel({
    required this.id,
    required this.namaPanti,
    required this.username,
    required this.nomorPanti,
    required this.alamatPanti,
    required this.description,
    this.profilePicture,
    this.totalTerkumpul = 0,
  });

  String get formattedTotalTerkumpul => 'Rp ${totalTerkumpul.toStringAsFixed(0)}';

  factory PantiProfileModel.fromJson(Map<String, dynamic> json) => PantiProfileModel(
        id: json['id'] as int,
        namaPanti: json['nama_panti'] as String,
        username: json['username'] as String,
        nomorPanti: json['nomor_panti'] as String? ?? '',
        alamatPanti: json['alamat_panti'] as String? ?? '',
        description: json['description'] as String? ?? '',
        profilePicture: json['profile_picture'] as String?,
        totalTerkumpul: (json['total_terkumpul'] as num?)?.toDouble() ?? 0,
      );
}

class KebutuhanModel {
  final int id;
  final String nama;
  final int jumlah;
  final String satuan;

  KebutuhanModel({
    required this.id,
    required this.nama,
    required this.jumlah,
    required this.satuan,
  });

  factory KebutuhanModel.fromJson(Map<String, dynamic> json) => KebutuhanModel(
        id: json['id'] as int,
        nama: json['nama'] as String,
        jumlah: json['jumlah'] as int,
        satuan: json['satuan'] as String? ?? 'pcs',
      );
}

// ---------------------------------------------------------------------------
// FAKE API IMPLEMENTATIONS (menggantikan implementasi asli dengan http mock)
// ---------------------------------------------------------------------------

/// Simulasi ContentApi dengan http.Client yang bisa di-inject.
class FakeContentApi {
  final http.Client client;
  final String baseUrl;

  FakeContentApi({required this.client, this.baseUrl = 'https://api.ruangpeduli.test'});

  Future<List<BeritaModel>> fetchBeritas({int? pantiId}) async {
    final uri = pantiId != null
        ? Uri.parse('$baseUrl/berita/?panti_id=$pantiId')
        : Uri.parse('$baseUrl/berita/');
    final resp = await client.get(uri);
    if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');
    final List data = jsonDecode(resp.body) as List;
    return data.map((e) => BeritaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<VideoModel>> fetchVideos({int? pantiId}) async {
    final uri = pantiId != null
        ? Uri.parse('$baseUrl/videos/?panti_id=$pantiId')
        : Uri.parse('$baseUrl/videos/');
    final resp = await client.get(uri);
    if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');
    final List data = jsonDecode(resp.body) as List;
    return data.map((e) => VideoModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

/// Simulasi ProfileApi.
class FakeProfileApi {
  final http.Client client;
  final String baseUrl;

  FakeProfileApi({required this.client, this.baseUrl = 'https://api.ruangpeduli.test'});

  Future<PantiProfileModel> fetchPantiProfile(int pantiId) async {
    final uri = Uri.parse('$baseUrl/panti/$pantiId/');
    final resp = await client.get(uri);
    if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');
    return PantiProfileModel.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }
}

/// Simulasi KebutuhanApi.
class FakeKebutuhanApi {
  final http.Client client;
  final String baseUrl;

  FakeKebutuhanApi({required this.client, this.baseUrl = 'https://api.ruangpeduli.test'});

  Future<List<KebutuhanModel>> fetchKebutuhan(int pantiId) async {
    final uri = Uri.parse('$baseUrl/kebutuhan/?panti_id=$pantiId');
    final resp = await client.get(uri);
    if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');
    final List data = jsonDecode(resp.body) as List;
    return data.map((e) => KebutuhanModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

// ---------------------------------------------------------------------------
// HELPER – membuat MockClient dari handler function
// ---------------------------------------------------------------------------
http.Client _mockClient(
    Future<http.Response> Function(http.Request request) handler,
) =>
    MockClient(handler);

// ---------------------------------------------------------------------------
// TESTS
// ---------------------------------------------------------------------------

void main() {
  // ════════════════════════════════════════════════════════════════════
  // GROUP 1 – ContentApi.fetchBeritas
  // ════════════════════════════════════════════════════════════════════
  group('ContentApi.fetchBeritas', () {
    test('mengembalikan list BeritaModel saat respons 200', () async {
      final mockData = [
        {
          'id': 1,
          'title': 'Donasi Ramadhan',
          'content': 'Kegiatan donasi selama Ramadhan.',
          'panti_name': 'Panti Asuhan Al-Ikhlas',
          'panti_id': 10,
          'thumbnail': 'https://example.com/thumb.jpg',
          'panti_profile_picture': null,
        }
      ];
      final api = FakeContentApi(
        client: _mockClient(
          (_) async => http.Response(jsonEncode(mockData), 200),
        ),
      );

      final result = await api.fetchBeritas();

      expect(result, hasLength(1));
      expect(result.first.id, 1);
      expect(result.first.title, 'Donasi Ramadhan');
      expect(result.first.pantiName, 'Panti Asuhan Al-Ikhlas');
      expect(result.first.pantiId, 10);
    });

    test('mengembalikan list kosong saat respons 200 dengan array kosong', () async {
      final api = FakeContentApi(
        client: _mockClient((_) async => http.Response('[]', 200)),
      );

      final result = await api.fetchBeritas();

      expect(result, isEmpty);
    });

    test('melempar Exception saat respons bukan 200', () async {
      final api = FakeContentApi(
        client: _mockClient((_) async => http.Response('Internal Server Error', 500)),
      );

      expect(() => api.fetchBeritas(), throwsException);
    });

    test('filter by pantiId menggunakan query param yang benar', () async {
      String? capturedUrl;
      final api = FakeContentApi(
        client: _mockClient((req) async {
          capturedUrl = req.url.toString();
          return http.Response('[]', 200);
        }),
      );

      await api.fetchBeritas(pantiId: 42);

      expect(capturedUrl, contains('panti_id=42'));
    });

    test('tanpa pantiId tidak mengirim query param panti_id', () async {
      String? capturedUrl;
      final api = FakeContentApi(
        client: _mockClient((req) async {
          capturedUrl = req.url.toString();
          return http.Response('[]', 200);
        }),
      );

      await api.fetchBeritas();

      expect(capturedUrl, isNot(contains('panti_id')));
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 2 – ContentApi.fetchVideos
  // ════════════════════════════════════════════════════════════════════
  group('ContentApi.fetchVideos', () {
    test('mengembalikan list VideoModel saat respons 200', () async {
      final mockData = [
        {
          'id': 5,
          'title': 'Video Kegiatan',
          'description': 'Deskripsi video.',
          'video_url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          'panti_name': 'Panti Sejahtera',
          'panti_id': 7,
          'thumbnail': null,
        }
      ];
      final api = FakeContentApi(
        client: _mockClient((_) async => http.Response(jsonEncode(mockData), 200)),
      );

      final result = await api.fetchVideos();

      expect(result, hasLength(1));
      expect(result.first.id, 5);
      expect(result.first.videoUrl, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
    });

    test('melempar Exception saat respons 404', () async {
      final api = FakeContentApi(
        client: _mockClient((_) async => http.Response('Not Found', 404)),
      );

      expect(() => api.fetchVideos(), throwsException);
    });

    test('filter by pantiId mengirim query param yang benar', () async {
      String? capturedUrl;
      final api = FakeContentApi(
        client: _mockClient((req) async {
          capturedUrl = req.url.toString();
          return http.Response('[]', 200);
        }),
      );

      await api.fetchVideos(pantiId: 99);

      expect(capturedUrl, contains('panti_id=99'));
    });

    test('VideoModel.description nullable – default ke string kosong', () async {
      final mockData = [
        {
          'id': 2,
          'title': 'Video Tanpa Deskripsi',
          'video_url': 'https://youtu.be/abc123',
          'panti_name': 'Panti X',
        }
      ];
      final api = FakeContentApi(
        client: _mockClient((_) async => http.Response(jsonEncode(mockData), 200)),
      );

      final result = await api.fetchVideos();

      expect(result.first.description, '');
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 3 – ProfileApi.fetchPantiProfile
  // ════════════════════════════════════════════════════════════════════
  group('ProfileApi.fetchPantiProfile', () {
    test('mengembalikan PantiProfileModel lengkap saat respons 200', () async {
      final mockData = {
        'id': 10,
        'nama_panti': 'Panti Asuhan Al-Ikhlas',
        'username': 'alikhlas',
        'nomor_panti': '021-555-1234',
        'alamat_panti': 'Jl. Mawar No.1, Jakarta',
        'description': 'Panti terpercaya sejak 1990.',
        'profile_picture': 'https://example.com/pp.jpg',
        'total_terkumpul': 5000000,
      };
      final api = FakeProfileApi(
        client: _mockClient((_) async => http.Response(jsonEncode(mockData), 200)),
      );

      final result = await api.fetchPantiProfile(10);

      expect(result.id, 10);
      expect(result.namaPanti, 'Panti Asuhan Al-Ikhlas');
      expect(result.username, 'alikhlas');
      expect(result.totalTerkumpul, 5000000);
    });

    test('formattedTotalTerkumpul memformat angka dengan benar', () async {
      final mockData = {
        'id': 1,
        'nama_panti': 'Panti X',
        'username': 'pantix',
        'nomor_panti': '',
        'alamat_panti': '',
        'description': '',
        'total_terkumpul': 1500000,
      };
      final api = FakeProfileApi(
        client: _mockClient((_) async => http.Response(jsonEncode(mockData), 200)),
      );

      final result = await api.fetchPantiProfile(1);

      expect(result.formattedTotalTerkumpul, contains('1500000'));
    });

    test('melempar Exception saat panti tidak ditemukan (404)', () async {
      final api = FakeProfileApi(
        client: _mockClient((_) async => http.Response('Not Found', 404)),
      );

      expect(() => api.fetchPantiProfile(9999), throwsException);
    });

    test('profilePicture nullable – boleh null', () async {
      final mockData = {
        'id': 2,
        'nama_panti': 'Panti Y',
        'username': 'pantiy',
        'nomor_panti': '',
        'alamat_panti': '',
        'description': '',
      };
      final api = FakeProfileApi(
        client: _mockClient((_) async => http.Response(jsonEncode(mockData), 200)),
      );

      final result = await api.fetchPantiProfile(2);

      expect(result.profilePicture, isNull);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 4 – KebutuhanApi.fetchKebutuhan
  // ════════════════════════════════════════════════════════════════════
  group('KebutuhanApi.fetchKebutuhan', () {
    test('mengembalikan list KebutuhanModel saat respons 200', () async {
      final mockData = [
        {'id': 1, 'nama': 'Beras', 'jumlah': 50, 'satuan': 'kg'},
        {'id': 2, 'nama': 'Susu', 'jumlah': 20, 'satuan': 'kaleng'},
      ];
      final api = FakeKebutuhanApi(
        client: _mockClient((_) async => http.Response(jsonEncode(mockData), 200)),
      );

      final result = await api.fetchKebutuhan(1);

      expect(result, hasLength(2));
      expect(result[0].nama, 'Beras');
      expect(result[0].jumlah, 50);
      expect(result[0].satuan, 'kg');
      expect(result[1].nama, 'Susu');
    });

    test('mengembalikan list kosong saat tidak ada kebutuhan', () async {
      final api = FakeKebutuhanApi(
        client: _mockClient((_) async => http.Response('[]', 200)),
      );

      final result = await api.fetchKebutuhan(1);

      expect(result, isEmpty);
    });

    test('melempar Exception saat server error (500)', () async {
      final api = FakeKebutuhanApi(
        client: _mockClient((_) async => http.Response('Error', 500)),
      );

      expect(() => api.fetchKebutuhan(1), throwsException);
    });

    test('satuan nullable – default ke "pcs"', () async {
      final mockData = [
        {'id': 3, 'nama': 'Obat', 'jumlah': 100},
      ];
      final api = FakeKebutuhanApi(
        client: _mockClient((_) async => http.Response(jsonEncode(mockData), 200)),
      );

      final result = await api.fetchKebutuhan(1);

      expect(result.first.satuan, 'pcs');
    });

    test('query param panti_id dikirim dengan benar', () async {
      String? capturedUrl;
      final api = FakeKebutuhanApi(
        client: _mockClient((req) async {
          capturedUrl = req.url.toString();
          return http.Response('[]', 200);
        }),
      );

      await api.fetchKebutuhan(55);

      expect(capturedUrl, contains('panti_id=55'));
    });
  });
}