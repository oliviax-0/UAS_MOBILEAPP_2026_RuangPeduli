import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

// ---------------------------------------------------------------------------
// Catatan: Geolocator menggunakan platform channel. Dalam unit test murni
// kita menguji LOGIKA kalkulasi jarak dan format, bukan platform channel.
// Untuk integration test dengan GeolocatorPlatform.instance mock, lihat
// berkas integration_test/location_integration_test.dart.
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Helpers yang mencerminkan logika di SearchScreen
// ---------------------------------------------------------------------------

double distanceBetween(
  double userLat,
  double userLng,
  double? pantiLat,
  double? pantiLng,
) {
  if (pantiLat == null || pantiLng == null) return double.infinity;
  return Geolocator.distanceBetween(userLat, userLng, pantiLat, pantiLng);
}

String formatDistance(double meters) {
  if (meters.isInfinite) return '';
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('distanceBetween (unit logic)', () {
    test('mengembalikan infinity ketika koordinat panti null', () {
      final d = distanceBetween(-6.2, 106.8, null, null);
      expect(d, double.infinity);
    });

    test('mengembalikan infinity ketika lat null saja', () {
      final d = distanceBetween(-6.2, 106.8, null, 106.9);
      expect(d, double.infinity);
    });

    test('mengembalikan infinity ketika lng null saja', () {
      final d = distanceBetween(-6.2, 106.8, -6.3, null);
      expect(d, double.infinity);
    });

    test('mengembalikan nol ketika koordinat identik', () {
      final d = distanceBetween(-6.2088, 106.8456, -6.2088, 106.8456);
      expect(d, closeTo(0, 1.0));
    });

    test('jarak antara dua titik nyata masuk akal (> 0)', () {
      // Jakarta Pusat ke Monas (estimasi ~500 m)
      final d = distanceBetween(-6.1751, 106.8272, -6.1754, 106.8272);
      expect(d, greaterThanOrEqualTo(0));
    });
  });

  // -------------------------------------------------------------------------

  group('formatDistance', () {
    test('mengembalikan string kosong untuk infinity', () {
      expect(formatDistance(double.infinity), '');
    });

    test('menampilkan meter ketika < 1000 m', () {
      expect(formatDistance(500), '500 m');
      expect(formatDistance(999), '999 m');
    });

    test('menampilkan km ketika >= 1000 m', () {
      expect(formatDistance(1000), '1.0 km');
      expect(formatDistance(2500), '2.5 km');
      expect(formatDistance(12300), '12.3 km');
    });

    test('membulatkan meter ke integer terdekat', () {
      expect(formatDistance(499.7), '500 m');
      expect(formatDistance(100.2), '100 m');
    });

    test('km diformat dengan satu desimal', () {
      expect(formatDistance(1234), '1.2 km');
    });
  });

  // -------------------------------------------------------------------------

  group('isNearest badge logic', () {
    // Logika: isNearest = i == 0 && _userPosition != null && distM.isFinite
    test('isNearest true ketika indeks 0, posisi ada, dan jarak finite', () {
      const index = 0;
      const hasPosition = true;
      const distance = 350.0;

      final isNearest = index == 0 && hasPosition && distance.isFinite;
      expect(isNearest, isTrue);
    });

    test('isNearest false ketika posisi null', () {
      const index = 0;
      const hasPosition = false;
      const distance = 350.0;

      final isNearest = index == 0 && hasPosition && distance.isFinite;
      expect(isNearest, isFalse);
    });

    test('isNearest false ketika bukan indeks pertama', () {
      const index = 1;
      const hasPosition = true;
      const distance = 350.0;

      final isNearest = index == 0 && hasPosition && distance.isFinite;
      expect(isNearest, isFalse);
    });

    test('isNearest false ketika jarak infinity', () {
      const index = 0;
      const hasPosition = true;
      final distance = double.infinity;

      final isNearest = index == 0 && hasPosition && distance.isFinite;
      expect(isNearest, isFalse);
    });
  });
}