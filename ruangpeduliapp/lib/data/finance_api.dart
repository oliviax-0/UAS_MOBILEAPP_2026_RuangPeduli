import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class FinanceDashboard {
  final double totalPemasukan;
  final double totalPengeluaran;
  final double saldo;

  const FinanceDashboard({
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.saldo,
  });

  factory FinanceDashboard.fromJson(Map<String, dynamic> json) => FinanceDashboard(
        totalPemasukan: double.parse(json['total_pemasukan'].toString()),
        totalPengeluaran: double.parse(json['total_pengeluaran'].toString()),
        saldo: double.parse(json['saldo'].toString()),
      );
}

class TransactionModel {
  final int id;
  final String category;
  final String subLabel;
  final double jumlah;
  final bool isIncome;
  final String tanggal;
  final String createdAt;

  const TransactionModel({
    required this.id,
    required this.category,
    required this.subLabel,
    required this.jumlah,
    required this.isIncome,
    required this.tanggal,
    required this.createdAt,
  });

  String get formattedAmount {
    final formatted = jumlah.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }
}

class JenisPemasukanModel {
  final int id;
  final String nama;
  const JenisPemasukanModel({required this.id, required this.nama});
  factory JenisPemasukanModel.fromJson(Map<String, dynamic> json) =>
      JenisPemasukanModel(id: json['id'], nama: json['nama']);
}

// ─── API ─────────────────────────────────────────────────────────────────────

class FinanceApi {
  final String _base = AppConfig.baseUrl;

  Future<FinanceDashboard> fetchDashboard(int userId) async {
    final uri = Uri.parse('$_base/finance/dashboard/').replace(
      queryParameters: {'user_id': userId.toString()},
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) return FinanceDashboard.fromJson(jsonDecode(res.body));
    throw Exception('Gagal memuat dashboard keuangan');
  }

  Future<List<TransactionModel>> fetchTransactions(int userId) async {
    final params = {'user_id': userId.toString()};
    final uriPemasukan   = Uri.parse('$_base/finance/pemasukan/').replace(queryParameters: params);
    final uriPengeluaran = Uri.parse('$_base/finance/pengeluaran/').replace(queryParameters: params);

    final results = await Future.wait([
      http.get(uriPemasukan).timeout(const Duration(seconds: 15)),
      http.get(uriPengeluaran).timeout(const Duration(seconds: 15)),
    ]);

    if (results[0].statusCode != 200 || results[1].statusCode != 200) {
      throw Exception('Gagal memuat transaksi');
    }

    final incomes = (jsonDecode(results[0].body) as List).map((e) => TransactionModel(
          id: e['id'],
          category: e['jenis_nama'] ?? 'Pemasukan',
          subLabel: e['catatan'] ?? '',
          jumlah: double.parse(e['jumlah'].toString()),
          isIncome: true,
          tanggal: e['tanggal'],
          createdAt: e['created_at'] ?? '',
        ));

    final expenses = (jsonDecode(results[1].body) as List).map((e) => TransactionModel(
          id: e['id'],
          category: e['kategori_nama'] ?? 'Pengeluaran',
          subLabel: e['catatan'] ?? '',
          jumlah: double.parse(e['jumlah'].toString()),
          isIncome: false,
          tanggal: e['tanggal'],
          createdAt: e['created_at'] ?? '',
        ));

    final all = [...incomes, ...expenses];
    all.sort((a, b) {
      final dateCmp = b.tanggal.compareTo(a.tanggal);
      if (dateCmp != 0) return dateCmp;
      return b.createdAt.compareTo(a.createdAt);
    });
    return all;
  }

  Future<List<JenisPemasukanModel>> fetchJenisPemasukan(int userId) async {
    final uri = Uri.parse('$_base/finance/jenis-pemasukan/').replace(
      queryParameters: {'user_id': userId.toString()},
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((e) => JenisPemasukanModel.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat jenis pemasukan');
  }

  Future<JenisPemasukanModel> addJenisPemasukan(int userId, String nama) async {
    final uri = Uri.parse('$_base/finance/jenis-pemasukan/');
    final res = await http
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId, 'nama': nama}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 201) return JenisPemasukanModel.fromJson(jsonDecode(res.body));
    final body = jsonDecode(res.body);
    throw Exception(body['error'] ?? 'Gagal menambah jenis pemasukan');
  }

  Future<void> addPemasukan(int userId, int jenisId, double jumlah, String catatan, String tanggal) async {
    final uri = Uri.parse('$_base/finance/pemasukan/');
    final res = await http
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId, 'jenis_pemasukan': jenisId, 'jumlah': jumlah, 'catatan': catatan, 'tanggal': tanggal}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 201) {
      final body = jsonDecode(res.body);
      throw Exception(body['error'] ?? 'Gagal menambah pemasukan');
    }
  }

  Future<void> deletePemasukan(int userId, int id) async {
    final uri = Uri.parse('$_base/finance/pemasukan/$id/');
    final res = await http
        .delete(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 204) throw Exception('Gagal menghapus pemasukan');
  }

  Future<void> addPengeluaran(int userId, int kategoriId, double jumlah, String catatan, String tanggal) async {
    final uri = Uri.parse('$_base/finance/pengeluaran/');
    final res = await http
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId, 'kategori': kategoriId, 'jumlah': jumlah, 'catatan': catatan, 'tanggal': tanggal}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 201) {
      final body = jsonDecode(res.body);
      throw Exception(body['error'] ?? 'Gagal menambah pengeluaran');
    }
  }

  Future<void> deletePengeluaran(int userId, int id) async {
    final uri = Uri.parse('$_base/finance/pengeluaran/$id/');
    final res = await http
        .delete(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 204) throw Exception('Gagal menghapus pengeluaran');
  }
}
