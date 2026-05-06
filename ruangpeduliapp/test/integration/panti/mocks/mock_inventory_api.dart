// test/mocks/mock_inventory_api.dart

import 'package:ruangpeduliapp/panti/inventory_panti/models/item_model.dart';
import 'package:ruangpeduliapp/panti/inventory_panti/models/anggota_model.dart';

class MockInventoryApi {

  /// =========================
  /// DASHBOARD
  /// =========================
  Future<Map<String, dynamic>> fetchDashboard() async {
    return {
      'stokMasuk': 10,
      'stokKeluar': 5,
      'notif': 2,
    };
  }

  /// =========================
  /// ITEMS
  /// =========================
  Future<List<ItemModel>> getItems() async {
    return [
      ItemModel(
        id: 1,
        nama: 'Beras',
        kategori: 'Makanan',
        stok: 20,
        satuan: 'Kg',
      ),
      ItemModel(
        id: 2,
        nama: 'Minyak',
        kategori: 'Dapur',
        stok: 5,
        satuan: 'Botol',
      ),
    ];
  }

  /// =========================
  /// LOW STOCK
  /// =========================
  Future<List<ItemModel>> getLowStockItems() async {
    return [
      ItemModel(
        id: 3,
        nama: 'Gula',
        kategori: 'Makanan',
        stok: 1,
        satuan: 'Kg',
      ),
    ];
  }

  /// =========================
  /// ADD ITEM
  /// =========================
  Future<bool> addItem(ItemModel item) async {
    return true;
  }

  /// =========================
  /// UPDATE ITEM
  /// =========================
  Future<bool> updateItem(ItemModel item) async {
    return true;
  }

  /// =========================
  /// DELETE ITEM
  /// =========================
  Future<bool> deleteItem(int id) async {
    return true;
  }

  /// =========================
  /// PEGAWAI
  /// =========================
  Future<List<AnggotaModel>> getPegawai() async {
    return [
      AnggotaModel(
        id: 1,
        nama: 'Budi',
        divisi: 'Gudang',
        telepon: '08123456789',
      ),
    ];
  }

  /// =========================
  /// PENGHUNI
  /// =========================
  Future<List<AnggotaModel>> getResidents() async {
    return [
      AnggotaModel(
        id: 2,
        nama: 'Andi',
        divisi: 'Penghuni',
        telepon: '08111111111',
      ),
    ];
  }

  /// =========================
  /// ADD PEGAWAI
  /// =========================
  Future<bool> addPegawai(AnggotaModel anggota) async {
    return true;
  }

  /// =========================
  /// DELETE PEGAWAI
  /// =========================
  Future<bool> deletePegawai(int id) async {
    return true;
  }
}