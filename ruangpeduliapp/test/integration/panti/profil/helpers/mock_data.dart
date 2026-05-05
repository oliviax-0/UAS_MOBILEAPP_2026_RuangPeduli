// test/mocks/mock_data.dart

import 'package:ruangpeduliapp/panti/profile_panti/models/profile_model.dart';
import 'package:ruangpeduliapp/panti/profile_panti/models/kebutuhan_model.dart';

/// =========================
/// PROFILE DUMMY DATA
/// =========================
final mockProfile = ProfileModel(
  id: 1,
  namaPanti: 'Panti Kasih',
  email: 'panti@test.com',
  noTelepon: '08123456789',
  alamat: 'Jakarta',
  deskripsi: 'Panti asuhan anak',
  fotoProfil: null,
);

/// =========================
/// LIST PROFILE (optional)
/// =========================
final mockProfiles = [
  mockProfile,
  ProfileModel(
    id: 2,
    namaPanti: 'Panti Harapan',
    email: 'harapan@test.com',
    noTelepon: '08987654321',
    alamat: 'Bandung',
    deskripsi: 'Panti sosial',
    fotoProfil: null,
  ),
];

/// =========================
/// KEBUTUHAN DUMMY DATA
/// =========================
final mockKebutuhanList = [
  KebutuhanModel(
    id: 1,
    nama: 'Beras',
    jumlah: 10,
    satuan: 'Kg',
  ),
  KebutuhanModel(
    id: 2,
    nama: 'Air',
    jumlah: 5,
    satuan: 'Liter',
  ),
];

/// =========================
/// SINGLE KEBUTUHAN
/// =========================
final mockKebutuhan = KebutuhanModel(
  id: 3,
  nama: 'Telur',
  jumlah: 30,
  satuan: 'Pcs',
);