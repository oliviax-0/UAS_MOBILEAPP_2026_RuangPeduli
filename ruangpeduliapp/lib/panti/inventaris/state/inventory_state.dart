import 'package:flutter/foundation.dart';
import 'package:ruangpeduliapp/panti/inventaris/models/item_model.dart';

class InventoryState extends ChangeNotifier {
  final dynamic api;
  
  int stokMasuk = 0;
  int stokKeluar = 0;
  int notifCount = 0;
  List<ItemModel> items = [];
  String? error;
  bool isLoading = false;

  InventoryState({required this.api});

  /// Load dashboard data from API
  Future<void> loadDashboard() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final response = await api.fetchDashboard();

      stokMasuk = response['stokMasuk'] as int? ?? 0;
      stokKeluar = response['stokKeluar'] as int? ?? 0;
      notifCount = response['notif'] as int? ?? 0;
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load items from API
  Future<void> loadItems() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      items = await api.getItems();
      error = null;
    } catch (e) {
      error = e.toString();
      items = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Delete item by ID
  Future<bool> deleteItem(int id) async {
    try {
      final result = await api.deleteItem(id);
      error = null;
      return result;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }
}
