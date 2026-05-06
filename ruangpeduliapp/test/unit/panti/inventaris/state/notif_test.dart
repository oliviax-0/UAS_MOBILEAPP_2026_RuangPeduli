import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/inventaris/state/inventory_state.dart';
import 'package:ruangpeduliapp/panti/inventaris/models/item_model.dart';

/// Fake API
class FakeInventoryApi {
  Future<List<ItemModel>> getLowStockItems() async {
    return [
      ItemModel(
        id: 1,
        nama: 'Minyak',
        kategori: 'Dapur',
        stok: 1,
        satuan: 'Botol',
      ),
    ];
  }
}

/// Error API
class ErrorInventoryApi {
  Future<List<ItemModel>> getLowStockItems() async {
    throw Exception('Error');
  }
}

void main() {
  group('NotifState Test', () {

    test('loadLowStock success', () async {
      final state = InventoryState(api: FakeInventoryApi());

      await state.loadLowStock();

      expect(state.lowStockItems.length, 1);
      expect(state.error, isNull);
      expect(state.isLoading, false);
    });

    test('loadLowStock error', () async {
      final state = InventoryState(api: ErrorInventoryApi());

      await state.loadLowStock();

      expect(state.lowStockItems.isEmpty, true);
      expect(state.error, isNotNull);
      expect(state.isLoading, false);
    });

  });
}
