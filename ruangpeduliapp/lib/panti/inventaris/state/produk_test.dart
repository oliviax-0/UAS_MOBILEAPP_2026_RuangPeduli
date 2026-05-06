import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/inventaris/state/inventory_state.dart';
import 'package:ruangpeduliapp/panti/inventaris/models/item_model.dart';

/// Fake API
class FakeInventoryApi {
  Future<bool> addItem(ItemModel item) async {
    return true;
  }
}

/// Error API
class ErrorInventoryApi {
  Future<bool> addItem(ItemModel item) async {
    throw Exception('Error');
  }
}

void main() {
  group('ProdukState Test', () {

    test('addItem success', () async {
      final state = InventoryState(api: FakeInventoryApi());

      final item = ItemModel(
        id: 1,
        nama: 'Beras',
        kategori: 'Makanan',
        stok: 20,
        satuan: 'Kg',
      );

      final result = await state.addItem(item);

      expect(result, true);
      expect(state.error, isNull);
    });

    test('addItem error', () async {
      final state = InventoryState(api: ErrorInventoryApi());

      final item = ItemModel(
        id: 1,
        nama: 'Beras',
        kategori: 'Makanan',
        stok: 20,
        satuan: 'Kg',
      );

      final result = await state.addItem(item);

      expect(result, false);
      expect(state.error, isNotNull);
    });

  });
}