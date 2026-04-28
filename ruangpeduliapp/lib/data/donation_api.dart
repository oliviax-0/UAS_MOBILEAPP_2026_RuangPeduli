import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class DonasiModel {
  final int id;
  final String namaPanti;
  final String? pantiImage;
  final int jumlah;
  final String metodePembayaran;
  final String noReferensi;
  final String tanggal;       // ISO datetime
  final String tanggalLabel;  // "14 Desember 2026"

  const DonasiModel({
    required this.id,
    required this.namaPanti,
    this.pantiImage,
    required this.jumlah,
    required this.metodePembayaran,
    required this.noReferensi,
    required this.tanggal,
    required this.tanggalLabel,
  });

  factory DonasiModel.fromJson(Map<String, dynamic> json) => DonasiModel(
        id: json['id'],
        namaPanti: json['nama_panti'] ?? '',
        pantiImage: json['panti_image'],
        jumlah: json['jumlah'] ?? 0,
        metodePembayaran: json['metode_pembayaran'] ?? '',
        noReferensi: json['no_referensi'] ?? '',
        tanggal: json['tanggal'] ?? '',
        tanggalLabel: json['tanggal_label'] ?? '',
      );

  String get formattedJumlah {
    final s = jumlah.toString();
    final buffer = StringBuffer('Rp');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  DateTime get tanggalDateTime => DateTime.tryParse(tanggal) ?? DateTime.now();
}

// ─── API ─────────────────────────────────────────────────────────────────────

class DonationApi {
  final String _base = AppConfig.baseUrl;

  // GET /api/donations/?user_id=X
  Future<List<DonasiModel>> fetchDonations(int userId) async {
    final url = Uri.parse('$_base/donations/?user_id=$userId');
    final res = await http
        .get(url)
        .timeout(const Duration(seconds: 15), onTimeout: () => throw Exception('Koneksi timeout'));
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['error'] ?? 'Gagal memuat riwayat donasi');
    }
    final list = jsonDecode(res.body) as List;
    return list.map((e) => DonasiModel.fromJson(e)).toList();
  }

  // POST /api/donations/
  Future<DonasiModel> createDonation({
    required int userId,
    int? pantiId,
    required String namaPanti,
    required int jumlah,
    required String metodePembayaran,
    required String noReferensi,
  }) async {
    final url = Uri.parse('$_base/donations/');
    final body = <String, dynamic>{
      'user_id': userId,
      'nama_panti': namaPanti,
      'jumlah': jumlah,
      'metode_pembayaran': metodePembayaran,
      'no_referensi': noReferensi,
      if (pantiId != null) 'panti_id': pantiId,
    };
    final res = await http
        .post(url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body))
        .timeout(const Duration(seconds: 15), onTimeout: () => throw Exception('Koneksi timeout'));
    if (res.statusCode != 200 && res.statusCode != 201) {
      final decoded = jsonDecode(res.body);
      throw Exception(decoded['error'] ?? 'Gagal menyimpan donasi');
    }
    return DonasiModel.fromJson(jsonDecode(res.body));
  }
}
