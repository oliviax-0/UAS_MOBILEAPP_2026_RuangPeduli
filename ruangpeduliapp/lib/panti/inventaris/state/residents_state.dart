import 'package:flutter/foundation.dart';
import 'package:ruangpeduliapp/panti/inventaris/models/anggota_model.dart';

class ResidentsState extends ChangeNotifier {
  final dynamic api;
  
  List<AnggotaModel> pegawaiList = [];
  String? error;
  bool isLoading = false;

  ResidentsState({required this.api});

  /// Load pegawai list from API
  Future<void> loadPegawai() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      pegawaiList = await api.getPegawai();
      error = null;
    } catch (e) {
      error = e.toString();
      pegawaiList = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Add new pegawai
  Future<bool> addPegawai(AnggotaModel anggota) async {
    try {
      final result = await api.addPegawai(anggota);
      error = null;
      return result;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }

  /// Delete pegawai by ID
  Future<bool> deletePegawai(int id) async {
    try {
      final result = await api.deletePegawai(id);
      error = null;
      return result;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }
}
