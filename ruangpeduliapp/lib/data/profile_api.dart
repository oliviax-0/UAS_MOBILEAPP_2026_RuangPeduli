import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ruangpeduliapp/data/data.dart';

// ─── MODELS ──────────────────────────────────────────────────────────────────

class SocietyProfileModel {
  final int id;
  final String username;
  final String email;
  final String namaPengguna;
  final String alamat;
  final String nomorTelepon;
  final String jenisKelamin;
  final String? profilePicture;

  SocietyProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.namaPengguna,
    required this.alamat,
    this.nomorTelepon = '',
    this.jenisKelamin = '',
    this.profilePicture,
  });

  factory SocietyProfileModel.fromJson(Map<String, dynamic> json) {
    return SocietyProfileModel(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      namaPengguna: json['nama_pengguna'] ?? '',
      alamat: json['alamat'] ?? '',
      nomorTelepon: json['nomor_telepon'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      profilePicture: json['profile_picture'],
    );
  }
}

class PantiProfileModel {
  final int id;
  final String username;
  final String email;
  final String namaPanti;
  final String alamatPanti;
  final String nomorPanti;
  final String? profilePicture;
  final String description;
  final int totalTerkumpul;
  final String provinsi;
  final String kabupatenKota;
  final String kecamatan;
  final String kelurahan;
  final String kodePos;
  final double? lat;
  final double? lng;

  PantiProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.namaPanti,
    required this.alamatPanti,
    required this.nomorPanti,
    this.profilePicture,
    required this.description,
    this.totalTerkumpul = 0,
    this.provinsi = '',
    this.kabupatenKota = '',
    this.kecamatan = '',
    this.kelurahan = '',
    this.kodePos = '',
    this.lat,
    this.lng,
  });

  /// Full address composed from all address parts
  String get fullAddress {
    final parts = [
      alamatPanti,
      if (kelurahan.isNotEmpty) 'Kel. $kelurahan',
      if (kecamatan.isNotEmpty) 'Kec. $kecamatan',
      if (kabupatenKota.isNotEmpty) kabupatenKota,
      if (provinsi.isNotEmpty) provinsi,
      if (kodePos.isNotEmpty) kodePos,
    ].where((s) => s.isNotEmpty).toList();
    return parts.join(', ');
  }

  factory PantiProfileModel.fromJson(Map<String, dynamic> json) {
    return PantiProfileModel(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      namaPanti: json['nama_panti'] ?? '',
      alamatPanti: json['alamat_panti'] ?? '',
      nomorPanti: json['nomor_panti'] ?? '',
      profilePicture: json['profile_picture'],
      description: json['description'] ?? '',
      totalTerkumpul: json['total_terkumpul'] ?? 0,
      provinsi: json['provinsi'] ?? '',
      kabupatenKota: json['kabupaten_kota'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      kelurahan: json['kelurahan'] ?? '',
      kodePos: json['kode_pos'] ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  String get formattedTotalTerkumpul {
    if (totalTerkumpul == 0) return 'Belum ada donasi';
    final s = totalTerkumpul.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return 'Rp${buffer.toString()} Terkumpul';
  }

  PantiProfileModel copyWith({
    String? username,
    String? email,
    String? namaPanti,
    String? alamatPanti,
    String? nomorPanti,
    String? profilePicture,
    bool clearProfilePicture = false,
    String? description,
    int? totalTerkumpul,
  }) {
    return PantiProfileModel(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      namaPanti: namaPanti ?? this.namaPanti,
      alamatPanti: alamatPanti ?? this.alamatPanti,
      nomorPanti: nomorPanti ?? this.nomorPanti,
      profilePicture: clearProfilePicture ? null : (profilePicture ?? this.profilePicture),
      description: description ?? this.description,
      totalTerkumpul: totalTerkumpul ?? this.totalTerkumpul,
    );
  }
}

class PantiMediaModel {
  final int id;
  final String mediaType; // 'photo' | 'video'
  final String? file;
  final String videoUrl;
  final int order;
  final String title;
  final String description;

  PantiMediaModel({
    required this.id,
    required this.mediaType,
    this.file,
    required this.videoUrl,
    required this.order,
    this.title = '',
    this.description = '',
  });

  bool get isVideo => mediaType == 'video';

  factory PantiMediaModel.fromJson(Map<String, dynamic> json) {
    return PantiMediaModel(
      id: json['id'],
      mediaType: json['media_type'] ?? 'photo',
      file: json['file'],
      videoUrl: json['video_url'] ?? '',
      order: json['order'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class PantiUploadedVideo {
  final int id;
  final int pantiId;
  final String pantiName;
  final String? file;
  final String videoUrl;
  final String title;
  final String description;

  PantiUploadedVideo({
    required this.id,
    required this.pantiId,
    required this.pantiName,
    this.file,
    required this.videoUrl,
    required this.title,
    required this.description,
  });

  factory PantiUploadedVideo.fromJson(Map<String, dynamic> json) {
    return PantiUploadedVideo(
      id: json['id'],
      pantiId: json['panti_id'],
      pantiName: json['panti_name'] ?? '',
      file: json['file'],
      videoUrl: json['video_url'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

// ─── API ─────────────────────────────────────────────────────────────────────

class ProfileApi {
  String get _base => AppConfig.baseUrl;

  Future<SocietyProfileModel?> fetchMasyarakatProfile(int userId) async {
    final uri = Uri.parse('$_base/profiles/masyarakat/?user_id=$userId');
    try {
      final res = await http.get(uri).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Koneksi timeout'),
      );
      if (res.statusCode != 200) return null;
      final List data = jsonDecode(res.body);
      if (data.isEmpty) return null;
      return SocietyProfileModel.fromJson(data[0] as Map<String, dynamic>);
    } on SocketException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<SocietyProfileModel> updateMasyarakatProfile(
    int profileId, {
    String? namaPengguna,
    String? alamat,
    String? username,
    String? email,
    String? nomorTelepon,
    String? jenisKelamin,
    File? profilePicture,
    bool removeProfilePicture = false,
  }) async {
    final uri = Uri.parse('$_base/profiles/masyarakat/$profileId/');
    try {
      final req = http.MultipartRequest('PATCH', uri);
      if (namaPengguna != null) req.fields['nama_pengguna'] = namaPengguna;
      if (alamat != null) req.fields['alamat'] = alamat;
      if (username != null) req.fields['username'] = username;
      if (email != null) req.fields['email'] = email;
      if (nomorTelepon != null) req.fields['nomor_telepon'] = nomorTelepon;
      if (jenisKelamin != null) req.fields['jenis_kelamin'] = jenisKelamin;
      if (removeProfilePicture) {
        req.fields['remove_profile_picture'] = 'true';
      } else if (profilePicture != null) {
        req.files.add(await http.MultipartFile.fromPath(
            'profile_picture', profilePicture.path));
      }
      final streamed = await req.send().timeout(const Duration(seconds: 30));
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode != 200) throw Exception('Gagal memperbarui profil');
      return SocietyProfileModel.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  Future<List<PantiProfileModel>> fetchAllPanti() async {
    final uri = Uri.parse('$_base/profiles/panti/');
    try {
      final res = await http.get(uri).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Koneksi timeout'),
      );
      if (res.statusCode != 200) throw Exception('Gagal memuat daftar panti');
      final List data = jsonDecode(res.body);
      return data
          .map((e) => PantiProfileModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  Future<PantiProfileModel> fetchPantiProfile(int pantiId) async {
    final uri = Uri.parse('$_base/profiles/panti/$pantiId/');
    try {
      final res = await http.get(uri).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Koneksi timeout'),
      );
      if (res.statusCode != 200) throw Exception('Gagal memuat profil panti');
      return PantiProfileModel.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  Future<PantiProfileModel> updatePantiProfile(
    int pantiId, {
    String? namaPanti,
    String? alamatPanti,
    String? nomorPanti,
    String? description,
    String? username,
    String? email,
    String? password,
    File? profilePicture,
    bool removeProfilePicture = false,
  }) async {
    final uri = Uri.parse('$_base/profiles/panti/$pantiId/');
    try {
      final req = http.MultipartRequest('PATCH', uri);

      if (namaPanti != null) req.fields['nama_panti'] = namaPanti;
      if (alamatPanti != null) req.fields['alamat_panti'] = alamatPanti;
      if (nomorPanti != null) req.fields['nomor_panti'] = nomorPanti;
      if (description != null) req.fields['description'] = description;
      if (username != null) req.fields['username'] = username;
      if (email != null) req.fields['email'] = email;
      if (password != null && password.isNotEmpty) {
        req.fields['password'] = password;
      }
      if (removeProfilePicture) {
        req.fields['remove_profile_picture'] = 'true';
      } else if (profilePicture != null) {
        req.files.add(await http.MultipartFile.fromPath(
            'profile_picture', profilePicture.path));
      }

      final streamed = await req.send().timeout(const Duration(seconds: 30));
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode != 200) throw Exception('Gagal memperbarui profil');
      return PantiProfileModel.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  Future<List<PantiMediaModel>> fetchPantiMedia(int pantiId) async {
    final uri = Uri.parse('$_base/profiles/panti/$pantiId/media/');
    try {
      final res = await http.get(uri).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Koneksi timeout'),
      );
      if (res.statusCode != 200) throw Exception('Gagal memuat media');
      final List data = jsonDecode(res.body);
      return data
          .map((e) => PantiMediaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  Future<PantiMediaModel> uploadPantiMedia(
    int pantiId, {
    File? file,
    String? videoUrl,
    String mediaType = 'photo',
    int order = 0,
    String title = '',
    String description = '',
  }) async {
    final uri = Uri.parse('$_base/profiles/panti/$pantiId/media/');
    try {
      final req = http.MultipartRequest('POST', uri);
      req.fields['media_type'] = mediaType;
      req.fields['order'] = order.toString();
      if (title.isNotEmpty) req.fields['title'] = title;
      if (description.isNotEmpty) req.fields['description'] = description;
      if (videoUrl != null && videoUrl.isNotEmpty) {
        req.fields['video_url'] = videoUrl;
      }
      if (file != null) {
        req.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      final timeout = mediaType == 'video'
          ? const Duration(seconds: 120)
          : const Duration(seconds: 30);
      final streamed = await req.send().timeout(timeout);
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode != 201) {
        debugPrint('❌ uploadPantiMedia ${res.statusCode}: ${res.body}');
        throw Exception('Gagal mengunggah media [${res.statusCode}]: ${res.body}');
      }
      return PantiMediaModel.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  Future<List<PantiUploadedVideo>> fetchAllPantiVideos() async {
    final uri = Uri.parse('$_base/profiles/media/videos/');
    try {
      final res = await http.get(uri).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Koneksi timeout'),
      );
      if (res.statusCode != 200) throw Exception('Gagal memuat video panti');
      final List data = jsonDecode(res.body);
      return data
          .map((e) => PantiUploadedVideo.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  Future<void> deletePantiMedia(int pantiId, int mediaId) async {
    final uri =
        Uri.parse('$_base/profiles/panti/$pantiId/media/$mediaId/');
    try {
      final res = await http.delete(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 204) throw Exception('Gagal menghapus media');
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }
}
