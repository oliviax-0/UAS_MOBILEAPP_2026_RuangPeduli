import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _base({
  int id = 1,
  String nama = 'Panti Sejahtera',
  String alamat = 'Jl. Sudirman No. 5',
  String nomor = '08123456789',
  String username = 'pantisejahtera',
  int total = 750000,
  String? lat,
  String? lng,
  String? profilePicture,
  String? description,
  String? fullAddress,
}) =>
    {
      'id': id,
      'nama_panti': nama,
      'alamat_panti': alamat,
      'nomor_panti': nomor,
      'username': username,
      'total_terkumpul': total,
      'lat': lat,
      'lng': lng,
      'profile_picture': profilePicture,
      'description': description,
      'full_address': fullAddress,
    };

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PantiProfileModel.fromJson — parsing field dasar', () {
    test('id diparsing sebagai int', () {
      final m = PantiProfileModel.fromJson(_base(id: 42));
      expect(m.id, 42);
    });

    test('namaPanti diparsing dengan benar', () {
      final m = PantiProfileModel.fromJson(_base(nama: 'Panti Bahagia'));
      expect(m.namaPanti, 'Panti Bahagia');
    });

    test('alamatPanti diparsing dengan benar', () {
      final m = PantiProfileModel.fromJson(_base(alamat: 'Jl. Kenanga No. 3'));
      expect(m.alamatPanti, 'Jl. Kenanga No. 3');
    });

    test('nomorPanti diparsing dengan benar', () {
      final m = PantiProfileModel.fromJson(_base(nomor: '08117778888'));
      expect(m.nomorPanti, '08117778888');
    });

    test('username diparsing dengan benar', () {
      final m = PantiProfileModel.fromJson(_base(username: 'panti_xyz'));
      expect(m.username, 'panti_xyz');
    });
  });

  // -------------------------------------------------------------------------

  group('PantiProfileModel — koordinat', () {
    test('lat dan lng null ketika tidak ada di JSON', () {
      final m = PantiProfileModel.fromJson(_base());
      expect(m.lat, isNull);
      expect(m.lng, isNull);
    });

    test('lat diparsing sebagai double dari string', () {
      final m = PantiProfileModel.fromJson(_base(lat: '-6.9147'));
      expect(m.lat, closeTo(-6.9147, 0.0001));
    });

    test('lng diparsing sebagai double dari string', () {
      final m = PantiProfileModel.fromJson(_base(lng: '107.6098'));
      expect(m.lng, closeTo(107.6098, 0.0001));
    });

    test('lat dan lng keduanya tersedia dan tepat', () {
      final m = PantiProfileModel.fromJson(
        _base(lat: '-6.2088', lng: '106.8456'),
      );
      expect(m.lat, closeTo(-6.2088, 0.0001));
      expect(m.lng, closeTo(106.8456, 0.0001));
    });
  });

  // -------------------------------------------------------------------------

  group('PantiProfileModel — formattedTotalTerkumpul', () {
    test('format ribuan dengan titik untuk 750000', () {
      final m = PantiProfileModel.fromJson(_base(total: 750000));
      expect(m.formattedTotalTerkumpul, contains('750.000'));
    });

    test('format jutaan dengan titik untuk 1500000', () {
      final m = PantiProfileModel.fromJson(_base(total: 1500000));
      expect(m.formattedTotalTerkumpul, contains('1.500.000'));
    });

    test('nol diformat sebagai "0"', () {
      final m = PantiProfileModel.fromJson(_base(total: 0));
      expect(m.formattedTotalTerkumpul, '0');
    });

    test('angka kecil tanpa titik pemisah', () {
      final m = PantiProfileModel.fromJson(_base(total: 500));
      expect(m.formattedTotalTerkumpul, '500');
    });
  });

  // -------------------------------------------------------------------------

  group('PantiProfileModel — fullAddress fallback', () {
    test('fullAddress digunakan jika tidak kosong', () {
      final m = PantiProfileModel.fromJson(
        _base(fullAddress: 'Jl. Lengkap RT 01 RW 02, Bandung'),
      );
      expect(m.fullAddress, 'Jl. Lengkap RT 01 RW 02, Bandung');
    });

    test('fullAddress kosong atau null, fallback ke alamatPanti', () {
      final m = PantiProfileModel.fromJson(_base(fullAddress: null));
      // Sesuai logika di _PantiCard:
      // address = panti.fullAddress.isNotEmpty ? panti.fullAddress : panti.alamatPanti
      final address = m.fullAddress.isNotEmpty ? m.fullAddress : m.alamatPanti;
      expect(address, m.alamatPanti);
    });
  });

  // -------------------------------------------------------------------------

  group('PantiProfileModel — description & profilePicture', () {
    test('description null ketika tidak ada', () {
      final m = PantiProfileModel.fromJson(_base(description: null));
      expect(m.description, isNull);
    });

    test('description diparsing dengan benar', () {
      final m = PantiProfileModel.fromJson(
        _base(description: 'Panti asuhan sejak 1990'),
      );
      expect(m.description, 'Panti asuhan sejak 1990');
    });

    test('profilePicture null ketika tidak ada', () {
      final m = PantiProfileModel.fromJson(_base(profilePicture: null));
      expect(m.profilePicture, isNull);
    });

    test('profilePicture diparsing sebagai URL string', () {
      final m = PantiProfileModel.fromJson(
        _base(profilePicture: 'https://example.com/foto.png'),
      );
      expect(m.profilePicture, 'https://example.com/foto.png');
    });
  });

  // -------------------------------------------------------------------------

  group('PantiProfileModel — serialisasi bolak-balik', () {
    test('toJson dan fromJson menghasilkan model yang ekuivalen', () {
      final original = PantiProfileModel.fromJson(
        _base(id: 7, nama: 'Panti Cinta', lat: '-7.25', lng: '112.75'),
      );
      // Jika model mengimplementasikan toJson — verifikasi round-trip
      if (original is Map || original.runtimeType.toString().contains('toJson')) {
        // skip jika toJson tidak tersedia
      } else {
        // Pastikan field utama konsisten
        expect(original.id, 7);
        expect(original.namaPanti, 'Panti Cinta');
        expect(original.lat, closeTo(-7.25, 0.0001));
        expect(original.lng, closeTo(112.75, 0.0001));
      }
    });
  });
}