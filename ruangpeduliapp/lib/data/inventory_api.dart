import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class CategoryModel {
  final int id;
  final String name;
  final int itemCount;
  final int availableCount;
  final int needsRestockCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.availableCount,
    this.needsRestockCount = 0,
  });

  /// True when any item is out of stock OR any item needs restocking based on PHRR.
  bool get hasAlert =>
      itemCount > 0 && (availableCount < itemCount || needsRestockCount > 0);

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'],
        name: json['name'],
        itemCount: json['item_count'] ?? 0,
        availableCount: json['available_count'] ?? 0,
        needsRestockCount: json['needs_restock_count'] ?? 0,
      );
}

class InventoryItemModel {
  final int id;
  final String name;
  final int quantity;
  final String unit;
  final String status;
  final double? dailyUsage;
  final int leadTimeDays;
  final double? daysUntilEmpty;
  final bool needsRestock;
  final String? description;

  const InventoryItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.status,
    this.dailyUsage,
    this.leadTimeDays = 1,
    this.daysUntilEmpty,
    this.needsRestock = false,
    this.description,
  });

  bool get isOutOfStock => status == 'out_of_stock';

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) => InventoryItemModel(
        id: json['id'],
        name: json['name'],
        quantity: json['quantity'] ?? 0,
        unit: json['unit'] ?? 'pcs',
        status: json['status'] ?? 'available',
        dailyUsage: json['daily_usage'] != null ? double.tryParse(json['daily_usage'].toString()) : null,
        leadTimeDays: json['lead_time_days'] ?? 1,
        daysUntilEmpty: json['days_until_empty'] != null ? double.tryParse(json['days_until_empty'].toString()) : null,
        needsRestock: json['needs_restock'] == true,
        description: json['description']?.toString(),
      );
}

class LowStockItemModel {
  final int id;
  final String name;
  final int quantity;
  final String unit;
  final double? dailyUsage;
  final int leadTimeDays;
  final double? daysUntilEmpty;
  final int categoryId;
  final String categoryName;
  final bool isOutOfStock;

  const LowStockItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.dailyUsage,
    required this.leadTimeDays,
    this.daysUntilEmpty,
    required this.categoryId,
    required this.categoryName,
    required this.isOutOfStock,
  });

  factory LowStockItemModel.fromJson(Map<String, dynamic> json) => LowStockItemModel(
        id: json['id'],
        name: json['name'],
        quantity: json['quantity'] ?? 0,
        unit: json['unit'] ?? 'pcs',
        dailyUsage: json['daily_usage'] != null ? double.tryParse(json['daily_usage'].toString()) : null,
        leadTimeDays: json['lead_time_days'] ?? 1,
        daysUntilEmpty: json['days_until_empty'] != null ? double.tryParse(json['days_until_empty'].toString()) : null,
        categoryId: json['category_id'],
        categoryName: json['category_name'] ?? '',
        isOutOfStock: json['is_out_of_stock'] == true,
      );
}

class OutOfStockItemModel {
  final int id;
  final String name;
  final String unit;
  final int categoryId;
  final String categoryName;

  const OutOfStockItemModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.categoryId,
    required this.categoryName,
  });

  factory OutOfStockItemModel.fromJson(Map<String, dynamic> json, {required int categoryId, required String categoryName}) =>
      OutOfStockItemModel(
        id: json['id'],
        name: json['name'],
        unit: json['unit'] ?? 'pcs',
        categoryId: categoryId,
        categoryName: categoryName,
      );
}

class LaporanItemModel {
  final String categoryName;
  final String productName;
  final int amount;
  final String unit;
  final bool isMasuk;
  final String tanggal; // YYYY-MM-DD extracted from created_at

  const LaporanItemModel({
    required this.categoryName,
    required this.productName,
    required this.amount,
    required this.unit,
    required this.isMasuk,
    required this.tanggal,
  });

  String get formattedAmount => '${isMasuk ? '+' : '-'}$amount$unit';

  factory LaporanItemModel.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at'] as String? ?? '';
    final tanggal = createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt;
    return LaporanItemModel(
      categoryName: json['category_name'] ?? '',
      productName: json['product_name'] ?? '',
      amount: json['amount'] ?? 0,
      unit: json['unit'] ?? 'pcs',
      isMasuk: json['type'] == 'masuk',
      tanggal: tanggal,
    );
  }
}

// ─── API ─────────────────────────────────────────────────────────────────────

class InventoryApi {
  final String _base = AppConfig.baseUrl;

  // ── Categories ─────────────────────────────────────────────────────────────

  Future<List<CategoryModel>> fetchCategories(int pantiId) async {
    final uri = Uri.parse('$_base/inventory/categories/').replace(
      queryParameters: {'panti': pantiId.toString()},
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((e) => CategoryModel.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat kategori');
  }

  Future<CategoryModel> addCategory(int userId, String name) async {
    final uri = Uri.parse('$_base/inventory/categories/');
    final res = await http
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId, 'name': name}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 201) return CategoryModel.fromJson(jsonDecode(res.body));
    final body = jsonDecode(res.body);
    throw Exception(body['error'] ?? 'Gagal menambah kategori');
  }

  Future<void> deleteCategory(int userId, int categoryId) async {
    final uri = Uri.parse('$_base/inventory/categories/$categoryId/');
    final res = await http
        .delete(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 204) throw Exception('Gagal menghapus kategori');
  }

  // ── Items ──────────────────────────────────────────────────────────────────

  Future<List<InventoryItemModel>> fetchItems(int categoryId) async {
    final uri = Uri.parse('$_base/inventory/categories/$categoryId/items/');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((e) => InventoryItemModel.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat produk');
  }

  Future<InventoryItemModel> addItem(
    int userId, int categoryId, String name, int quantity, String unit, {
    String? description,
    double? dailyUsage,
    int? leadTimeDays,
  }) async {
    final uri = Uri.parse('$_base/inventory/categories/$categoryId/items/');
    final bodyMap = <String, dynamic>{'user_id': userId, 'name': name, 'quantity': quantity, 'unit': unit};
    if (description != null && description.isNotEmpty) bodyMap['description'] = description;
    if (dailyUsage != null) bodyMap['daily_usage'] = dailyUsage;
    if (leadTimeDays != null) bodyMap['lead_time_days'] = leadTimeDays;
    final res = await http
        .post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(bodyMap))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 201) return InventoryItemModel.fromJson(jsonDecode(res.body));
    throw Exception('Gagal menambah produk');
  }

  Future<void> updateItem(int userId, int itemId, {
    String? name, int? quantity, String? unit, String? description,
    double? dailyUsage, int? leadTimeDays,
  }) async {
    final uri = Uri.parse('$_base/inventory/items/$itemId/');
    final body = <String, dynamic>{'user_id': userId};
    if (name != null) body['name'] = name;
    if (quantity != null) body['quantity'] = quantity;
    if (unit != null) body['unit'] = unit;
    if (description != null) body['description'] = description;
    if (dailyUsage != null) body['daily_usage'] = dailyUsage;
    if (leadTimeDays != null) body['lead_time_days'] = leadTimeDays;
    final res = await http
        .put(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('Gagal mengubah produk');
  }

  /// Calls Groq AI to predict daily usage for a product.
  /// Returns a list of suggestions (low / medium / high) sorted ascending.
  Future<List<({double dailyUsage, String reasoning})>> predictPhrr(int pantiId, String productName, String unit) async {
    final uri = Uri.parse('$_base/inventory/predict-phrr/');
    final res = await http
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'panti_id': pantiId, 'product_name': productName, 'unit': unit}))
        .timeout(const Duration(seconds: 30));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final list = (body['suggestions'] as List? ?? []);
      return list.map((s) => (
        dailyUsage: double.tryParse(s['daily_usage'].toString()) ?? 0,
        reasoning: s['reasoning']?.toString() ?? '',
      )).toList();
    }
    final body = jsonDecode(res.body);
    throw Exception(body['error'] ?? 'Gagal memprediksi PHRR');
  }

  Future<List<LowStockItemModel>> fetchLowStockItems(int pantiId) async {
    final uri = Uri.parse('$_base/inventory/low-stock/').replace(
      queryParameters: {'panti_id': pantiId.toString()},
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((e) => LowStockItemModel.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat notifikasi stok');
  }

  Future<List<OutOfStockItemModel>> fetchOutOfStockItems(int pantiId) async {
    final cats = await fetchCategories(pantiId);
    final futures = cats.map((cat) async {
      final uri = Uri.parse('$_base/inventory/categories/${cat.id}/items/').replace(
        queryParameters: {'status': 'out_of_stock'},
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return <OutOfStockItemModel>[];
      return (jsonDecode(res.body) as List)
          .map((e) => OutOfStockItemModel.fromJson(e, categoryId: cat.id, categoryName: cat.name))
          .toList();
    });
    final results = await Future.wait(futures);
    return results.expand((e) => e).toList();
  }

  Future<List<LaporanItemModel>> fetchLaporan(int pantiId) async {
    final uri = Uri.parse('$_base/inventory/laporan/').replace(
      queryParameters: {'panti': pantiId.toString()},
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((e) => LaporanItemModel.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat laporan');
  }

  Future<void> addLaporan(int userId, int itemId, int amount, bool isMasuk) async {
    final uri = Uri.parse('$_base/inventory/laporan/');
    final res = await http
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userId,
              'item_id': itemId,
              'amount': amount,
              'type': isMasuk ? 'masuk' : 'keluar',
            }))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 201) throw Exception('Gagal mencatat laporan');
  }

  Future<void> deleteItem(int userId, int itemId) async {
    final uri = Uri.parse('$_base/inventory/items/$itemId/');
    final res = await http
        .delete(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId}))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 204) throw Exception('Gagal menghapus produk');
  }
}
