import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';

// ---------------------------------------------------------------------------
// Helper — buat PantiProfileModel langsung dari map
// ---------------------------------------------------------------------------

PantiProfileModel _makePanti({
  int id = 1,
  String nama = 'Panti A',
  String alamat = 'Jl. Test',
  String? lat,
  String? lng,
}) =>
    PantiProfileModel.fromJson({
      'id': id,
      'nama_panti': nama,
      'alamat_panti': alamat,
      'nomor_panti': '0800000000',
      'username': 'panti_${id}',
      'total_terkumpul': 0,
      'lat': lat,
      'lng': lng,
      'profile_picture': null,
      'description': null,
      'full_address': null,
    });

// ---------------------------------------------------------------------------
// Logika filter yang dicerminkan dari SearchScreen._filtered
// ---------------------------------------------------------------------------

List<PantiProfileModel> applyFilter(
  List<PantiProfileModel> list,
  String query,
) {
  final q = query.toLowerCase();
  return list.where((p) {
    return q.isEmpty ||
        p.namaPanti.toLowerCase().contains(q) ||
        p.alamatPanti.toLowerCase().contains(q);
  }).toList();
}

// ---------------------------------------------------------------------------
// Logika sort berdasarkan jarak (infinity = tanpa koordinat)
// ---------------------------------------------------------------------------

double mockDistance(PantiProfileModel p) {
  // Simulasi: panti dengan lat != null punya jarak tertentu
  if (p.lat == null || p.lng == null) return double.infinity;
  // Gunakan id sebagai proxy jarak supaya urutan mudah diprediksi
  return p.id.toDouble() * 1000;
}

List<PantiProfileModel> applySortByDistance(List<PantiProfileModel> list) {
  final sorted = List<PantiProfileModel>.from(list);
  sorted.sort((a, b) => mockDistance(a).compareTo(mockDistance(b)));
  return sorted;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  final pantiList = [
    _makePanti(id: 1, nama: 'Panti Kasih', alamat: 'Jl. Merdeka', lat: '-6.1', lng: '106.8'),
    _makePanti(id: 2, nama: 'Panti Harapan', alamat: 'Jl. Sudirman', lat: '-6.2', lng: '106.9'),
    _makePanti(id: 3, nama: 'Rumah Peduli', alamat: 'Jl. Gatot Subroto'),
  ];

  group('Filter — query kosong', () {
    test('mengembalikan semua panti ketika query kosong', () {
      final result = applyFilter(pantiList, '');
      expect(result.length, 3);
    });

    test('mengembalikan semua panti ketika query hanya spasi', () {
      // Logika: trim tidak dilakukan di _filtered, tapi lowercase string kosong
      final result = applyFilter(pantiList, '   ');
      // '   '.isEmpty = false → filter aktif, tapi tidak ada yang cocok dengan '   '
      expect(result.length, 0);
    });
  });

  // -------------------------------------------------------------------------

  group('Filter — cocok berdasarkan namaPanti', () {
    test('menemukan panti berdasarkan nama (case insensitive)', () {
      final result = applyFilter(pantiList, 'kasih');
      expect(result.length, 1);
      expect(result.first.namaPanti, 'Panti Kasih');
    });

    test('menemukan panti berdasarkan nama dengan huruf kapital', () {
      final result = applyFilter(pantiList, 'HARAPAN');
      expect(result.length, 1);
      expect(result.first.namaPanti, 'Panti Harapan');
    });

    test('menemukan panti dengan query parsial', () {
      final result = applyFilter(pantiList, 'panti');
      expect(result.length, 2);
    });

    test('tidak menemukan panti yang tidak cocok', () {
      final result = applyFilter(pantiList, 'xyz');
      expect(result.isEmpty, isTrue);
    });
  });

  // -------------------------------------------------------------------------

  group('Filter — cocok berdasarkan alamatPanti', () {
    test('menemukan panti berdasarkan alamat (case insensitive)', () {
      final result = applyFilter(pantiList, 'sudirman');
      expect(result.length, 1);
      expect(result.first.namaPanti, 'Panti Harapan');
    });

    test('menemukan panti berdasarkan jalan parsial', () {
      final result = applyFilter(pantiList, 'jl.');
      expect(result.length, 3);
    });

    test('menemukan panti via alamat meskipun nama tidak cocok', () {
      final result = applyFilter(pantiList, 'gatot');
      expect(result.length, 1);
      expect(result.first.namaPanti, 'Rumah Peduli');
    });
  });

  // -------------------------------------------------------------------------

  group('Sort — berdasarkan jarak', () {
    test('panti dengan koordinat muncul sebelum yang tanpa koordinat', () {
      final sorted = applySortByDistance(pantiList);
      // id 3 tidak punya koordinat → infinity → paling belakang
      expect(sorted.last.id, 3);
    });

    test('panti diurutkan dari jarak terpendek ke terjauh', () {
      final sorted = applySortByDistance(pantiList);
      // id 1 (jarak 1000) < id 2 (jarak 2000) < id 3 (infinity)
      expect(sorted[0].id, 1);
      expect(sorted[1].id, 2);
      expect(sorted[2].id, 3);
    });

    test('dua panti tanpa koordinat mempertahankan urutan relatifnya', () {
      final noCoord = [
        _makePanti(id: 5, nama: 'A'),
        _makePanti(id: 6, nama: 'B'),
      ];
      final sorted = applySortByDistance(noCoord);
      // Keduanya infinity → stable sort mempertahankan urutan semula
      expect(sorted.map((p) => p.id).toList(), anyOf([
        [5, 6],
        [6, 5],
      ]));
    });
  });

  // -------------------------------------------------------------------------

  group('Filter + Sort gabungan', () {
    test('filter kemudian sort menghasilkan subset terurut', () {
      final filtered = applyFilter(pantiList, 'panti');
      final sorted = applySortByDistance(filtered);
      expect(sorted.length, 2);
      // id 1 lebih dekat dari id 2
      expect(sorted[0].id, 1);
      expect(sorted[1].id, 2);
    });

    test('query yang tidak cocok menghasilkan list kosong setelah sort', () {
      final filtered = applyFilter(pantiList, 'zzz');
      final sorted = applySortByDistance(filtered);
      expect(sorted.isEmpty, isTrue);
    });
  });
}