import 'package:flutter/material.dart';
import '../models/kebutuhan_model.dart';
import '../api/kebutuhan_api.dart';

class KebutuhanState extends ChangeNotifier {
  final KebutuhanApi api;

  KebutuhanState({required this.api});

  List<KebutuhanModel> kebutuhanList = [];
  bool isLoading = false;
  String? error;

  Future<void> loadKebutuhan() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await api.getKebutuhan();
      kebutuhanList = result;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}