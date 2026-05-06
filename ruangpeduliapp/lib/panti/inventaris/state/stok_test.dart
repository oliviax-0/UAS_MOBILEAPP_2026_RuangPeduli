import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/inventaris/state/inventory_state.dart';
import 'package:ruangpeduliapp/panti/inventaris/models/item_model.dart';

/// Fake API
class FakeInventoryApi {
  Future<List<ItemModel>> getItems() async {
    return [
      ItemModel(
        id: 1,
        nama: 'Beras',
        kategori: 'Makanan',
        stok: 20,
        satuan: 'Kg',
      ),
    ];
  }

  Future<bool> deleteItem(int id) async {
    return true;
  }
}

/// Error API
class ErrorInventoryApi {
  Future<List<ItemModel>> getItems() async {
    throw Exception('Error');
  }

  Future<bool> deleteItem(int id) async {
    throw Exception('Error');
  }
}

void main() {
  group('StokState Test', () {

    test('loadItems success', () async {
      final state = InventoryState(api: FakeInventoryApi());

      await state.loadItems();

      expect(state.items.length, 1);
      expect(state.error, isNull);
      expect(state.isLoading, false);
    });

    test('loadItems error', () async {
      final state = InventoryState(api: ErrorInventoryApi());

      await state.loadItems();

      expect(state.items.isEmpty, true);
      expect(state.error, isNotNull);
      expect(state.isLoading, false);
    });

    test('deleteItem success', () async {
      final state = InventoryState(api: FakeInventoryApi());

      final result = await state.deleteItem(1);

      expect(result, true);
    });

    test('deleteItem error', () async {
      final state = InventoryState(api: ErrorInventoryApi());

      final result = await state.deleteItem(1);

      expect(result, false);
      expect(state.error, isNotNull);
    });

  });
}