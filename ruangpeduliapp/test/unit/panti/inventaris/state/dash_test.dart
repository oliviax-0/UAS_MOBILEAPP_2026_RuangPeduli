import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/inventaris/state/inventory_state.dart';

/// Fake API
class FakeInventoryApi {
  Future<Map<String, dynamic>> fetchDashboard() async {
    return {
      'stokMasuk': 10,
      'stokKeluar': 5,
      'notif': 2,
    };
  }
}

/// Error API
class ErrorInventoryApi {
  Future<Map<String, dynamic>> fetchDashboard() async {
    throw Exception('Error');
  }
}

void main() {
  group('DashboardState Test', () {

    test('loadDashboard success', () async {
      final state = InventoryState(api: FakeInventoryApi());

      await state.loadDashboard();

      expect(state.stokMasuk, 10);
      expect(state.stokKeluar, 5);
      expect(state.notifCount, 2);
      expect(state.error, isNull);
      expect(state.isLoading, false);
    });

    test('loadDashboard error', () async {
      final state = InventoryState(api: ErrorInventoryApi());

      await state.loadDashboard();

      expect(state.error, isNotNull);
      expect(state.isLoading, false);
    });

  });
}
