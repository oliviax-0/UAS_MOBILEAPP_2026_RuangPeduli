// test/unit/models/search_models_test.dart
//
// Unit tests untuk semua Model yang digunakan dalam fitur Search Masyarakat.
// Mencakup: BeritaModel, VideoModel, PantiProfileModel, KebutuhanModel,
//           PantiUploadedVideo, PantiMediaModel.
//
// Tidak memerlukan Flutter runtime – murni Dart unit test.
// Jalankan: flutter test test/unit/models/search_models_test.dart

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// MODEL DEFINITIONS
// (Salin/import dari lib/data/*.dart Anda – ini versi standalone untuk test)
// ---------------------------------------------------------------------------

// ── BeritaModel ─────────────────────────────────────────────────────────────
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'panti_name': pantiName,
        'panti_id': pantiId,
        'thumbnail': thumbnail,
        'panti_profile_picture': pantiProfilePicture,
      };
}

// ── VideoModel ───────────────────────────────────────────────────────────────
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

// ── PantiProfileModel ────────────────────────────────────────────────────────
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

  String get formattedTotalTerkumpul =>
      'Rp ${totalTerkumpul.toStringAsFixed(0)}';

  factory PantiProfileModel.fromJson(Map<String, dynamic> json) =>
      PantiProfileModel(
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

// ── KebutuhanModel ───────────────────────────────────────────────────────────
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

// ── PantiUploadedVideo ───────────────────────────────────────────────────────
class PantiUploadedVideo {
  final int id;
  final int pantiId;
  final String pantiName;
  final String title;
  final String videoUrl;

  PantiUploadedVideo({
    required this.id,
    required this.pantiId,
    required this.pantiName,
    required this.title,
    required this.videoUrl,
  });

  factory PantiUploadedVideo.fromJson(Map<String, dynamic> json) =>
      PantiUploadedVideo(
        id: json['id'] as int,
        pantiId: json['panti_id'] as int,
        pantiName: json['panti_name'] as String? ?? '',
        title: json['title'] as String? ?? '',
        videoUrl: json['video_url'] as String,
      );
}

// ── PantiMediaModel ──────────────────────────────────────────────────────────
class PantiMediaModel {
  final int id;
  final String? file;
  final String? videoUrl;
  final String title;
  final String description;

  PantiMediaModel({
    required this.id,
    this.file,
    this.videoUrl,
    this.title = '',
    this.description = '',
  });

  bool get isVideo {
    final f = file ?? '';
    final v = videoUrl ?? '';
    return f.endsWith('.mp4') ||
        f.endsWith('.mov') ||
        f.endsWith('.avi') ||
        v.isNotEmpty;
  }

  factory PantiMediaModel.fromJson(Map<String, dynamic> json) =>
      PantiMediaModel(
        id: json['id'] as int,
        file: json['file'] as String?,
        videoUrl: json['video_url'] as String?,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );
}

// ---------------------------------------------------------------------------
// TESTS
// ---------------------------------------------------------------------------

void main() {
  // ════════════════════════════════════════════════════════════════════
  // GROUP 1 – BeritaModel
  // ════════════════════════════════════════════════════════════════════
  group('BeritaModel', () {
    test('fromJson memetakan semua field dengan benar', () {
      final json = {
        'id': 1,
        'title': 'Berita Donasi',
        'content': 'Isi berita donasi.',
        'panti_name': 'Panti Asuhan Al-Ikhlas',
        'panti_id': 10,
        'thumbnail': 'https://example.com/thumb.jpg',
        'panti_profile_picture': 'https://example.com/pp.jpg',
      };

      final model = BeritaModel.fromJson(json);

      expect(model.id, 1);
      expect(model.title, 'Berita Donasi');
      expect(model.content, 'Isi berita donasi.');
      expect(model.pantiName, 'Panti Asuhan Al-Ikhlas');
      expect(model.pantiId, 10);
      expect(model.thumbnail, 'https://example.com/thumb.jpg');
      expect(model.pantiProfilePicture, 'https://example.com/pp.jpg');
    });

    test('fromJson menangani field nullable (thumbnail, panti_id, picture) → null', () {
      final json = {
        'id': 2,
        'title': 'Berita Tanpa Gambar',
        'content': 'Konten.',
        'panti_name': 'Panti X',
      };

      final model = BeritaModel.fromJson(json);

      expect(model.pantiId, isNull);
      expect(model.thumbnail, isNull);
      expect(model.pantiProfilePicture, isNull);
    });

    test('fromJson menangani panti_name null → string kosong', () {
      final json = {
        'id': 3,
        'title': 'T',
        'content': 'C',
      };

      final model = BeritaModel.fromJson(json);

      expect(model.pantiName, '');
    });

    test('toJson menghasilkan map yang konsisten dengan fromJson', () {
      final original = {
        'id': 4,
        'title': 'Round Trip Test',
        'content': 'Konten.',
        'panti_name': 'Panti Y',
        'panti_id': 5,
        'thumbnail': null,
        'panti_profile_picture': null,
      };

      final model = BeritaModel.fromJson(original);
      final result = model.toJson();

      expect(result['id'], original['id']);
      expect(result['title'], original['title']);
      expect(result['panti_name'], original['panti_name']);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 2 – VideoModel
  // ════════════════════════════════════════════════════════════════════
  group('VideoModel', () {
    test('fromJson memetakan semua field dengan benar', () {
      final json = {
        'id': 10,
        'title': 'Video Kegiatan',
        'description': 'Deskripsi video.',
        'video_url': 'https://youtu.be/abc123',
        'panti_name': 'Panti Sejahtera',
        'panti_id': 7,
        'thumbnail': 'https://example.com/yt.jpg',
      };

      final model = VideoModel.fromJson(json);

      expect(model.id, 10);
      expect(model.title, 'Video Kegiatan');
      expect(model.description, 'Deskripsi video.');
      expect(model.videoUrl, 'https://youtu.be/abc123');
      expect(model.pantiName, 'Panti Sejahtera');
      expect(model.pantiId, 7);
      expect(model.thumbnail, 'https://example.com/yt.jpg');
    });

    test('fromJson description null → string kosong', () {
      final json = {
        'id': 11,
        'title': 'T',
        'video_url': 'https://youtu.be/xyz',
        'panti_name': 'P',
      };

      final model = VideoModel.fromJson(json);

      expect(model.description, '');
    });

    test('fromJson panti_id null → null', () {
      final json = {
        'id': 12,
        'title': 'T',
        'video_url': 'https://youtu.be/xyz',
        'panti_name': 'P',
      };

      final model = VideoModel.fromJson(json);

      expect(model.pantiId, isNull);
    });

    test('fromJson thumbnail null → null', () {
      final json = {
        'id': 13,
        'title': 'T',
        'video_url': 'https://youtu.be/xyz',
        'panti_name': 'P',
      };

      final model = VideoModel.fromJson(json);

      expect(model.thumbnail, isNull);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 3 – PantiProfileModel
  // ════════════════════════════════════════════════════════════════════
  group('PantiProfileModel', () {
    test('fromJson memetakan semua field dengan benar', () {
      final json = {
        'id': 20,
        'nama_panti': 'Panti Asuhan Al-Ikhlas',
        'username': 'alikhlas',
        'nomor_panti': '021-555-1234',
        'alamat_panti': 'Jl. Mawar No.1, Jakarta',
        'description': 'Panti terpercaya.',
        'profile_picture': 'https://example.com/pp.jpg',
        'total_terkumpul': 7500000,
      };

      final model = PantiProfileModel.fromJson(json);

      expect(model.id, 20);
      expect(model.namaPanti, 'Panti Asuhan Al-Ikhlas');
      expect(model.username, 'alikhlas');
      expect(model.nomorPanti, '021-555-1234');
      expect(model.alamatPanti, 'Jl. Mawar No.1, Jakarta');
      expect(model.description, 'Panti terpercaya.');
      expect(model.profilePicture, 'https://example.com/pp.jpg');
      expect(model.totalTerkumpul, 7500000);
    });

    test('formattedTotalTerkumpul mengandung angka terkumpul', () {
      final model = PantiProfileModel(
        id: 1,
        namaPanti: 'X',
        username: 'x',
        nomorPanti: '',
        alamatPanti: '',
        description: '',
        totalTerkumpul: 2500000,
      );

      expect(model.formattedTotalTerkumpul, contains('2500000'));
    });

    test('totalTerkumpul default 0 saat field tidak ada di JSON', () {
      final json = {
        'id': 21,
        'nama_panti': 'P',
        'username': 'p',
      };

      final model = PantiProfileModel.fromJson(json);

      expect(model.totalTerkumpul, 0);
    });

    test('profilePicture nullable → null saat tidak ada di JSON', () {
      final json = {
        'id': 22,
        'nama_panti': 'P',
        'username': 'p',
      };

      final model = PantiProfileModel.fromJson(json);

      expect(model.profilePicture, isNull);
    });

    test('nomor/alamat/description nullable → string kosong saat tidak ada', () {
      final json = {
        'id': 23,
        'nama_panti': 'P',
        'username': 'p',
      };

      final model = PantiProfileModel.fromJson(json);

      expect(model.nomorPanti, '');
      expect(model.alamatPanti, '');
      expect(model.description, '');
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 4 – KebutuhanModel
  // ════════════════════════════════════════════════════════════════════
  group('KebutuhanModel', () {
    test('fromJson memetakan semua field dengan benar', () {
      final json = {
        'id': 1,
        'nama': 'Beras',
        'jumlah': 50,
        'satuan': 'kg',
      };

      final model = KebutuhanModel.fromJson(json);

      expect(model.id, 1);
      expect(model.nama, 'Beras');
      expect(model.jumlah, 50);
      expect(model.satuan, 'kg');
    });

    test('satuan null → default "pcs"', () {
      final json = {'id': 2, 'nama': 'Obat', 'jumlah': 10};

      final model = KebutuhanModel.fromJson(json);

      expect(model.satuan, 'pcs');
    });

    test('berbagai nama kebutuhan diterima dengan benar', () {
      final items = ['Susu', 'Telur', 'Minyak', 'Sabun', 'Baju', 'Buku'];
      for (var i = 0; i < items.length; i++) {
        final json = {'id': i + 1, 'nama': items[i], 'jumlah': i + 1};
        final model = KebutuhanModel.fromJson(json);
        expect(model.nama, items[i]);
      }
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 5 – PantiUploadedVideo
  // ════════════════════════════════════════════════════════════════════
  group('PantiUploadedVideo', () {
    test('fromJson memetakan semua field dengan benar', () {
      final json = {
        'id': 30,
        'panti_id': 5,
        'panti_name': 'Panti Harapan',
        'title': 'Kegiatan Tahun Baru',
        'video_url': 'https://youtu.be/vid123',
      };

      final model = PantiUploadedVideo.fromJson(json);

      expect(model.id, 30);
      expect(model.pantiId, 5);
      expect(model.pantiName, 'Panti Harapan');
      expect(model.title, 'Kegiatan Tahun Baru');
      expect(model.videoUrl, 'https://youtu.be/vid123');
    });

    test('panti_name null → string kosong', () {
      final json = {
        'id': 31,
        'panti_id': 6,
        'video_url': 'https://youtu.be/abc',
      };

      final model = PantiUploadedVideo.fromJson(json);

      expect(model.pantiName, '');
    });

    test('title null → string kosong', () {
      final json = {
        'id': 32,
        'panti_id': 7,
        'video_url': 'https://youtu.be/def',
      };

      final model = PantiUploadedVideo.fromJson(json);

      expect(model.title, '');
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 6 – PantiMediaModel
  // ════════════════════════════════════════════════════════════════════
  group('PantiMediaModel', () {
    test('fromJson memetakan semua field dengan benar', () {
      final json = {
        'id': 40,
        'file': 'https://example.com/foto.jpg',
        'video_url': null,
        'title': 'Foto Kegiatan',
        'description': 'Kegiatan donasi baju.',
      };

      final model = PantiMediaModel.fromJson(json);

      expect(model.id, 40);
      expect(model.file, 'https://example.com/foto.jpg');
      expect(model.videoUrl, isNull);
      expect(model.title, 'Foto Kegiatan');
    });

    test('isVideo = false untuk file foto (jpg/png)', () {
      final model = PantiMediaModel(
        id: 1,
        file: 'https://example.com/foto.jpg',
      );

      expect(model.isVideo, false);
    });

    test('isVideo = true untuk file mp4', () {
      final model = PantiMediaModel(
        id: 2,
        file: 'https://example.com/video.mp4',
      );

      expect(model.isVideo, true);
    });

    test('isVideo = true untuk file mov', () {
      final model = PantiMediaModel(
        id: 3,
        file: 'https://example.com/video.mov',
      );

      expect(model.isVideo, true);
    });

    test('isVideo = true saat videoUrl tidak kosong', () {
      final model = PantiMediaModel(
        id: 4,
        file: null,
        videoUrl: 'https://youtu.be/xyz',
      );

      expect(model.isVideo, true);
    });

    test('isVideo = false saat file null dan videoUrl kosong', () {
      final model = PantiMediaModel(id: 5);

      expect(model.isVideo, false);
    });

    test('title dan description nullable → string kosong', () {
      final json = {'id': 41};

      final model = PantiMediaModel.fromJson(json);

      expect(model.title, '');
      expect(model.description, '');
    });
  });
}