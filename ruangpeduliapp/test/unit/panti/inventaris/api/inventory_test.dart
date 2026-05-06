import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:ruangpeduliapp/panti/inventaris/api/inventory_api.dart';
import 'package:ruangpeduliapp/panti/inventaris/models/item_model.dart';
import '../../../../utils/fake_http_client.dart'; // Import FakeClient dari file utilitas

// =========================
// INVENTORY API TEST
// =========================
void main() {
  group('InventoryApi Test', () {

    test('getItems success', () async {
      final client = FakeClient((request) {
        return http.Response(jsonEncode([
          {
            'id': 1,
            'nama': 'Beras',
            'kategori': 'Makanan',
            'stok': 20,
            'satuan': 'Kg',
          }
        ]), 200);
      });

      final api = InventoryApi(client: client);

      final result = await api.getItems();

      expect(result, isA<List<ItemModel>>()); // Menggunakan karakter '<' dan '>' yang benar
      expect(result.length, 1);
      expect(result.first.nama, 'Beras');
    });

    test('getItems error', () async {
      final client = FakeClient((request) {
        return http.Response('Error', 500);
      });

      final api = InventoryApi(client: client);

      expect(api.getItems(), throwsException);
    });

    test('addItem success', () async {
      final client = FakeClient((request) {
        return http.Response('OK', 200);
      });

      final api = InventoryApi(client: client);

      final item = ItemModel(
        id: 1,
        nama: 'Beras',
        kategori: 'Makanan',
        stok: 20,
        satuan: 'Kg',
      );

      final result = await api.addItem(item);

      expect(result, true);
    });

    test('deleteItem success', () async {
      final client = FakeClient((request) {
        return http.Response('OK', 200);
      });

      final api = InventoryApi(client: client);

      final result = await api.deleteItem(1);

      expect(result, true);
    });

  });
}