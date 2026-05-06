import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ruangpeduliapp/panti/inventaris/models/item_model.dart';

class InventoryApi {
  final http.Client client;
  final String baseUrl = 'http://api.example.com';

  InventoryApi({required this.client});

  /// Get list of items
  Future<List<ItemModel>> getItems() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/items'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => ItemModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Add new item
  Future<bool> addItem(ItemModel item) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to add item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Delete item by ID
  Future<bool> deleteItem(int id) async {
    try {
      final response = await client.delete(Uri.parse('$baseUrl/items/$id'));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
