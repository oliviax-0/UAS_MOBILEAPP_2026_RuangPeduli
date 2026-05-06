import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Isolasi logika bisnis LokasiScreen:
// – format label jarak (_distanceLabel)
// – pembentukan URL Google Maps
// ---------------------------------------------------------------------------

/// Meniru _distanceLabel dari LokasiScreen
String distanceLabel(double? distanceMeters) {
  if (distanceMeters == null) return 'Jarak tidak tersedia';
  if (distanceMeters < 1000) {
    return '${distanceMeters.round()} m dari lokasi Anda';
  }
  return '${(distanceMeters / 1000).toStringAsFixed(1)} km dari lokasi Anda';
}

/// Meniru pembuatan URL Google Maps Direction
String buildMapsUrl(double lat, double lng) =>
    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

void main() {
  // =========================================================================
  // GROUP: distanceLabel
  // =========================================================================
  group('distanceLabel (LokasiScreen)', () {
    test('null → "Jarak tidak tersedia"', () {
      expect(distanceLabel(null), 'Jarak tidak tersedia');
    });

    test('0 meter → "0 m dari lokasi Anda"', () {
      expect(distanceLabel(0), '0 m dari lokasi Anda');
    });

    test('500 meter → "500 m dari lokasi Anda"', () {
      expect(distanceLabel(500), '500 m dari lokasi Anda');
    });

    test('999 meter → "999 m dari lokasi Anda"', () {
      expect(distanceLabel(999), '999 m dari lokasi Anda');
    });

    test('999.4 meter → dibulatkan "999 m"', () {
      expect(distanceLabel(999.4), '999 m dari lokasi Anda');
    });

    test('999.6 meter → dibulatkan "1000 m" (masih di bawah 1000 sebelum round)', () {
      // 999.6.round() = 1000, tapi < 1000 condition checks raw value
      // 999.6 < 1000 → true → "1.000 m" (setelah round = 1000)
      expect(distanceLabel(999.6), '1000 m dari lokasi Anda');
    });

    test('1000 meter → "1.0 km dari lokasi Anda"', () {
      expect(distanceLabel(1000), '1.0 km dari lokasi Anda');
    });

    test('1500 meter → "1.5 km dari lokasi Anda"', () {
      expect(distanceLabel(1500), '1.5 km dari lokasi Anda');
    });

    test('2000 meter → "2.0 km dari lokasi Anda"', () {
      expect(distanceLabel(2000), '2.0 km dari lokasi Anda');
    });

    test('10500 meter → "10.5 km dari lokasi Anda"', () {
      expect(distanceLabel(10500), '10.5 km dari lokasi Anda');
    });

    test('100000 meter (100 km) → "100.0 km dari lokasi Anda"', () {
      expect(distanceLabel(100000), '100.0 km dari lokasi Anda');
    });

    test('1333 meter → "1.3 km" (pembulatan 1 desimal)', () {
      expect(distanceLabel(1333), '1.3 km dari lokasi Anda');
    });

    test('1666 meter → "1.7 km" (pembulatan 1 desimal)', () {
      expect(distanceLabel(1666), '1.7 km dari lokasi Anda');
    });
  });

  // =========================================================================
  // GROUP: buildMapsUrl
  // =========================================================================
  group('buildMapsUrl (LokasiScreen)', () {
    test('URL diawali dengan https://www.google.com/maps', () {
      final url = buildMapsUrl(-6.2088, 106.8456);
      expect(url, startsWith('https://www.google.com/maps'));
    });

    test('URL mengandung parameter api=1', () {
      final url = buildMapsUrl(-6.2088, 106.8456);
      expect(url, contains('api=1'));
    });

    test('URL mengandung destination dengan lat,lng', () {
      final url = buildMapsUrl(-6.2088, 106.8456);
      expect(url, contains('destination=-6.2088,106.8456'));
    });

    test('URL menggunakan mode direction (/dir/)', () {
      final url = buildMapsUrl(-6.0, 107.0);
      expect(url, contains('/dir/'));
    });

    test('koordinat negatif (belahan bumi selatan) terbentuk benar', () {
      final url = buildMapsUrl(-8.6500, 115.2167); // Bali
      expect(url, contains('-8.65'));
      expect(url, contains('115.2167'));
    });

    test('koordinat Jakarta terbentuk dengan benar', () {
      final url = buildMapsUrl(-6.2088, 106.8456);
      expect(
        url,
        'https://www.google.com/maps/dir/?api=1&destination=-6.2088,106.8456',
      );
    });
  });

  // =========================================================================
  // GROUP: validasi koordinat (guard check sebelum navigasi)
  // =========================================================================
  group('Validasi koordinat', () {
    bool isValidCoordinate(double lat, double lng) {
      return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    }

    test('koordinat valid Jakarta', () {
      expect(isValidCoordinate(-6.2088, 106.8456), isTrue);
    });

    test('koordinat valid Bali', () {
      expect(isValidCoordinate(-8.65, 115.22), isTrue);
    });

    test('lat melebihi 90 → tidak valid', () {
      expect(isValidCoordinate(91.0, 106.0), isFalse);
    });

    test('lat kurang dari -90 → tidak valid', () {
      expect(isValidCoordinate(-91.0, 106.0), isFalse);
    });

    test('lng melebihi 180 → tidak valid', () {
      expect(isValidCoordinate(-6.0, 181.0), isFalse);
    });

    test('koordinat 0,0 → valid (Null Island)', () {
      expect(isValidCoordinate(0, 0), isTrue);
    });
  });
}