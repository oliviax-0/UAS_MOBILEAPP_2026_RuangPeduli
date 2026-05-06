// test/mocks/mock_inventory_data.dart

import 'package:ruangpeduliapp/panti/inventory_panti/models/item_model.dart';
import 'package:ruangpeduliapp/panti/inventory_panti/models/anggota_model.dart';

/// =========================
/// DASHBOARD DATA
/// =========================
final mockDashboard = {
  'stokMasuk': 10,
  'stokKeluar': 5,
  'notif': 2,
};

/// =========================
/// SINGLE ITEM
/// =========================
final mockItem = ItemModel(
  id: 1,
  nama: 'Beras',
  kategori: 'Makanan',
  stok: 20,
  satuan: 'Kg',
);

/// =========================
/// LIST ITEMS
/// =========================
final mockItemList = [
  mockItem,
  ItemModel(
    id: 2,
    nama: 'Minyak',
    kategori: 'Dapur',
    stok: 5,
    satuan: 'Botol',
  ),
];

/// =========================
/// LOW STOCK ITEMS
/// =========================
final lowStockItems = [
  ItemModel(
    id: 3,
    nama: 'Gula',
    kategori: 'Makanan',
    stok: 1,
    satuan: 'Kg',
  ),
];

/// =========================
/// SINGLE PEGAWAI
/// =========================
final mockPegawai = AnggotaModel(
  id: 1,
  nama: 'Budi',
  divisi: 'Gudang',
  telepon: '08123456789',
);

/// =========================
/// LIST PEGAWAI
/// =========================
final mockPegawaiList = [
  mockPegawai,
];

/// =========================
/// SINGLE PENGHUNI
/// =========================
final mockPenghuni = AnggotaModel(
  id: 2,
  nama: 'Andi',
  divisi: 'Penghuni',
  telepon: '08111111111',
);

/// =========================
/// LIST PENGHUNI
/// =========================
final mockPenghuniList = [
  mockPenghuni,
];