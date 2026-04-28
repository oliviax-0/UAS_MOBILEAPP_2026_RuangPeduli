import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data.dart';

class KebutuhanModel {
  final int id;
  final String nama;
  final String satuan;
  final int jumlah;

  const KebutuhanModel({
    required this.id,
    required this.nama,
    required this.satuan,
    required this.jumlah,
  });

  factory KebutuhanModel.fromJson(Map<String, dynamic> json) => KebutuhanModel(
        id: json['id'],
        nama: json['nama'] ?? '',
        satuan: json['satuan'] ?? '',
        jumlah: json['jumlah'] ?? 0,
      );
}

class KebutuhanApi {
  final String _base = AppConfig.baseUrl;

  Future<List<KebutuhanModel>> fetchKebutuhan(int pantiId) async {
    final uri = Uri.parse('$_base/kebutuhan/').replace(
      queryParameters: {'panti': pantiId.toString()},
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((e) => KebutuhanModel.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat kebutuhan');
  }

  Future<KebutuhanModel> addKebutuhan(int userId, String nama, String satuan, int jumlah) async {
    final uri = Uri.parse('$_base/kebutuhan/');
    final res = await http
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId, 'nama': nama, 'satuan': satuan, 'jumlah': jumlah}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 201) return KebutuhanModel.fromJson(jsonDecode(res.body));
    final body = jsonDecode(res.body);
    throw Exception(body['error'] ?? 'Gagal menambah kebutuhan');
  }

  Future<void> deleteKebutuhan(int userId, int itemId) async {
    final uri = Uri.parse('$_base/kebutuhan/$itemId/');
    final res = await http
        .delete(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 204) throw Exception('Gagal menghapus kebutuhan');
  }
}
