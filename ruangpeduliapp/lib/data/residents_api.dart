import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class PekerjaModel {
  final int id;
  final String nama;
  final String divisi;
  final String posisi;

  const PekerjaModel({
    required this.id,
    required this.nama,
    required this.divisi,
    required this.posisi,
  });

  factory PekerjaModel.fromJson(Map<String, dynamic> json) => PekerjaModel(
        id: json['id'],
        nama: json['nama'],
        divisi: json['divisi'],
        posisi: json['posisi'],
      );
}

class PenghuniModel {
  final int id;
  final String nama;
  final int tahunLahir;
  final String jenisKelamin;

  const PenghuniModel({
    required this.id,
    required this.nama,
    required this.tahunLahir,
    required this.jenisKelamin,
  });

  factory PenghuniModel.fromJson(Map<String, dynamic> json) => PenghuniModel(
        id: json['id'],
        nama: json['nama'],
        tahunLahir: json['tahun_lahir'],
        jenisKelamin: json['jenis_kelamin'],
      );
}

// ─── API ─────────────────────────────────────────────────────────────────────

class ResidentsApi {
  final String _base = AppConfig.baseUrl;

  // ── Pekerja ────────────────────────────────────────────────────────────────

  Future<List<PekerjaModel>> fetchPekerja(int userId, {String? search}) async {
    final params = {'user_id': userId.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final uri = Uri.parse('$_base/residents/pekerja/').replace(queryParameters: params);
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((e) => PekerjaModel.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat data pegawai');
  }

  Future<PekerjaModel> addPekerja(int userId, String nama, String divisi, String posisi) async {
    final uri = Uri.parse('$_base/residents/pekerja/');
    final res = await http
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId, 'nama': nama, 'divisi': divisi, 'posisi': posisi}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 201) return PekerjaModel.fromJson(jsonDecode(res.body));
    throw Exception('Gagal menambah pegawai');
  }

  Future<void> updatePekerja(int userId, int id, String nama, String divisi, String posisi) async {
    final uri = Uri.parse('$_base/residents/pekerja/$id/');
    final res = await http
        .put(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId, 'nama': nama, 'divisi': divisi, 'posisi': posisi}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('Gagal mengubah data pegawai');
  }

  Future<void> deletePekerja(int userId, int id) async {
    final uri = Uri.parse('$_base/residents/pekerja/$id/');
    final res = await http
        .delete(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 204) throw Exception('Gagal menghapus pegawai');
  }

  // ── Penghuni ───────────────────────────────────────────────────────────────

  Future<List<PenghuniModel>> fetchPenghuni(int userId, {String? search}) async {
    final params = {'user_id': userId.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final uri = Uri.parse('$_base/residents/penghuni/').replace(queryParameters: params);
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((e) => PenghuniModel.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat data penghuni');
  }

  Future<PenghuniModel> addPenghuni(int userId, String nama, int tahunLahir, String jenisKelamin) async {
    final uri = Uri.parse('$_base/residents/penghuni/');
    final res = await http
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId, 'nama': nama, 'tahun_lahir': tahunLahir, 'jenis_kelamin': jenisKelamin}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 201) return PenghuniModel.fromJson(jsonDecode(res.body));
    throw Exception('Gagal menambah penghuni');
  }

  Future<void> updatePenghuni(int userId, int id, String nama, int tahunLahir, String jenisKelamin) async {
    final uri = Uri.parse('$_base/residents/penghuni/$id/');
    final res = await http
        .put(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId, 'nama': nama, 'tahun_lahir': tahunLahir, 'jenis_kelamin': jenisKelamin}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('Gagal mengubah data penghuni');
  }

  Future<void> deletePenghuni(int userId, int id) async {
    final uri = Uri.parse('$_base/residents/penghuni/$id/');
    final res = await http
        .delete(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 204) throw Exception('Gagal menghapus penghuni');
  }
}
