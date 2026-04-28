import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ruangpeduliapp/data/data.dart';

// ─── BERITA MODEL ─────────────────────────────────────────────────────────────

class BeritaModel {
  final int id;
  final String title;
  final String content;
  final String? thumbnail;
  final String authorName;
  final String pantiName;
  final int? pantiId;
  final String? pantiProfilePicture;
  final String createdAt;
  final int upvoteCount;
  final int downvoteCount;

  BeritaModel({
    required this.id,
    required this.title,
    required this.content,
    this.thumbnail,
    required this.authorName,
    required this.pantiName,
    this.pantiId,
    this.pantiProfilePicture,
    required this.createdAt,
    required this.upvoteCount,
    required this.downvoteCount,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      thumbnail: json['thumbnail'],
      authorName: json['author_name'] ?? '',
      pantiName: json['panti_name'] ?? '',
      pantiId: json['panti'] as int?,
      pantiProfilePicture: json['panti_profile_picture'],
      createdAt: json['created_at'] ?? '',
      upvoteCount: json['upvote_count'] ?? 0,
      downvoteCount: json['downvote_count'] ?? 0,
    );
  }

  String get formattedDate {
    if (createdAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

}

// ─── VIDEO MODEL ──────────────────────────────────────────────────────────────

class VideoModel {
  final int id;
  final String title;
  final String description;
  final String videoUrl;
  final String? thumbnail;
  final String pantiName;
  final int? pantiId;
  final String authorName;
  final String createdAt;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    this.thumbnail,
    required this.pantiName,
    this.pantiId,
    required this.authorName,
    required this.createdAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      videoUrl: json['video_url'],
      thumbnail: json['thumbnail'],
      pantiName: json['panti_name'] ?? '',
      pantiId: json['panti'] as int?,
      authorName: json['author_name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

}

// ─── KEBUTUHAN MODEL ─────────────────────────────────────────────────────────

class KebutuhanItemModel {
  final int id;
  final int pantiId;
  final String pantiName;
  final String nama;
  final String satuan;
  final int jumlah;

  const KebutuhanItemModel({
    required this.id,
    required this.pantiId,
    required this.pantiName,
    required this.nama,
    required this.satuan,
    required this.jumlah,
  });

  factory KebutuhanItemModel.fromJson(Map<String, dynamic> json) =>
      KebutuhanItemModel(
        id:        json['id'],
        pantiId:   json['panti_id'],
        pantiName: json['panti_name'] ?? '',
        nama:      json['nama'] ?? '',
        satuan:    json['satuan'] ?? '',
        jumlah:    json['jumlah'] ?? 0,
      );
}

// ─── KEBUTUHAN API ────────────────────────────────────────────────────────────

class KebutuhanApi {
  String get _base => AppConfig.baseUrl;

  /// Fetch all kebutuhan across every panti in one request.
  Future<List<KebutuhanItemModel>> fetchAllKebutuhan() async {
    final uri = Uri.parse('$_base/kebutuhan/all/');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) throw Exception('Gagal memuat kebutuhan');
      final List data = jsonDecode(res.body);
      return data.map((e) => KebutuhanItemModel.fromJson(e as Map<String, dynamic>)).toList();
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  /// Fetch kebutuhan for a single panti.
  Future<List<KebutuhanItemModel>> fetchKebutuhanByPanti(int pantiId) async {
    final uri = Uri.parse('$_base/kebutuhan/').replace(
      queryParameters: {'panti': pantiId.toString()},
    );
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) throw Exception('Gagal memuat kebutuhan');
      final List data = jsonDecode(res.body);
      return data.map((e) {
        final m = e as Map<String, dynamic>;
        return KebutuhanItemModel(
          id:        m['id'],
          pantiId:   pantiId,
          pantiName: '',
          nama:      m['nama'] ?? '',
          satuan:    m['satuan'] ?? '',
          jumlah:    m['jumlah'] ?? 0,
        );
      }).toList();
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }
}

// ─── CONTENT API ──────────────────────────────────────────────────────────────

class ContentApi {
  String get _base => AppConfig.baseUrl;

  /// Fetch published beritas. Pass [pantiId] to filter by panti,
  /// [search] to filter by keyword (title / content / panti name).
  Future<List<BeritaModel>> fetchBeritas({int? pantiId, String? search}) async {
    final params = <String, String>{};
    if (pantiId != null) params['panti'] = '$pantiId';
    if (search != null && search.isNotEmpty) params['search'] = search;
    final uri = Uri.parse('$_base/content/berita/').replace(queryParameters: params.isEmpty ? null : params);

    try {
      final res = await http.get(uri).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Koneksi timeout'),
      );
      if (res.statusCode != 200) throw Exception('Gagal memuat berita');
      final List data = jsonDecode(res.body);
      return data
          .map((e) => BeritaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  /// Fetch published videos. Pass [pantiId] to filter by panti.
  Future<List<VideoModel>> fetchVideos({int? pantiId}) async {
    final params = <String, String>{};
    if (pantiId != null) params['panti'] = '$pantiId';
    final uri = Uri.parse('$_base/content/video/').replace(queryParameters: params.isEmpty ? null : params);

    try {
      final res = await http.get(uri).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Koneksi timeout'),
      );
      if (res.statusCode != 200) throw Exception('Gagal memuat video');
      final List data = jsonDecode(res.body);
      return data
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  /// Get the current user's vote state for a berita.
  /// Returns { upvote_count, downvote_count, user_vote: 'up'|'down'|null }.
  Future<Map<String, dynamic>> fetchUserVote(int beritaId, int userId) async {
    final uri = Uri.parse('$_base/content/berita/$beritaId/vote/').replace(
      queryParameters: {'user_id': userId.toString()},
    );
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
      return {};
    } on SocketException {
      return {};
    }
  }

  /// Toggle vote on a berita. [voteType] must be 'up' or 'down'.
  /// Returns { action, upvote_count, downvote_count, user_vote }.
  Future<Map<String, dynamic>> voteBerita(
      int beritaId, int userId, String voteType) async {
    final uri = Uri.parse('$_base/content/berita/$beritaId/vote/');

    try {
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId, 'vote_type': voteType}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Koneksi timeout'),
          );
      if (res.statusCode != 200) throw Exception('Gagal vote');
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  /// Create a new berita. [thumbnail] is optional.
  /// Returns the created [BeritaModel].
  Future<BeritaModel> createBerita({
    required int userId,
    required String title,
    required String content,
    File? thumbnail,
  }) async {
    final uri = Uri.parse('$_base/content/berita/');
    try {
      final req = http.MultipartRequest('POST', uri)
        ..fields['user_id'] = userId.toString()
        ..fields['title']   = title
        ..fields['content'] = content;

      if (thumbnail != null) {
        req.files.add(await http.MultipartFile.fromPath('thumbnail', thumbnail.path));
      }

      final streamed = await req.send().timeout(const Duration(seconds: 30));
      final res      = await http.Response.fromStream(streamed);
      if (res.statusCode == 201) {
        return BeritaModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
      final err = jsonDecode(res.body);
      if (err is Map) {
        final msg = err['error'] ?? err['detail'];
        if (msg != null) throw Exception(msg.toString());
        // Serializer validation errors: { field: [msg, ...] }
        final firstField = err.values.first;
        final firstMsg = firstField is List ? firstField.first : firstField;
        throw Exception(firstMsg.toString());
      }
      throw Exception('Gagal membuat berita');
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }

  Future<void> deleteBerita(int beritaId, int userId) async {
    final uri = Uri.parse('$_base/content/berita/$beritaId/');
    try {
      final res = await http.delete(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      ).timeout(const Duration(seconds: 15));
      if (res.statusCode != 204) throw Exception('Gagal menghapus postingan');
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }
}
