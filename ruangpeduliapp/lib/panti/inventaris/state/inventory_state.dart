import 'package:flutter/foundation.dart';

class InventoryState extends ChangeNotifier {
  final dynamic api;
  
  int stokMasuk = 0;
  int stokKeluar = 0;
  int notifCount = 0;
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
}
