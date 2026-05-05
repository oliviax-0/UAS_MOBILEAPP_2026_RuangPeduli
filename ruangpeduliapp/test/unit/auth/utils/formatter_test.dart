import 'package:flutter_test/flutter_test.dart';
// Unit test for formatting logic extracted from:
// - KonfirmasiPembayaranScreen._formatNominal()
// - KonfirmasiMetodeScreen._formatRupiah()
// - SearchScreen._formatDistance()
// - LokasiScreen._distanceLabel
// - TransaksiSuksesScreen._formatTanggal()
// - TransaksiSuksesScreen._buildSuksesPage() → username display

void main() {

  group('Nominal Formatter - KonfirmasiPembayaranScreen._formatNominal()', () {
    // Helper mirrors exact logic from _formatNominal()
    String formatNominal(String input) {
      final raw = input.replaceAll('.', '');
      if (raw.isEmpty) return '';
      final buffer = StringBuffer();
      for (int i = 0; i < raw.length; i++) {
        if (i > 0 && (raw.length - i) % 3 == 0) buffer.write('.');
        buffer.write(raw[i]);
      }
      return buffer.toString();
    }

    test(
      'TC-FM-01: Empty input returns empty string',
      () {
        expect(formatNominal(''), '');
      },
    );

    test(
      'TC-FM-02: 3-digit number has no separator',
      () {
        expect(formatNominal('100'), '100');
      },
    );

    test(
      'TC-FM-03: 4-digit number gets one separator',
      () {
        expect(formatNominal('1000'), '1.000');
      },
    );

    test(
      'TC-FM-04: 6-digit number gets one separator',
      () {
        expect(formatNominal('100000'), '100.000');
      },
    );

    test(
      'TC-FM-05: 7-digit number gets two separators',
      () {
        expect(formatNominal('1000000'), '1.000.000');
      },
    );

    test(
      'TC-FM-06: Already formatted input is re-formatted correctly',
      () {
        // Input with dots is stripped first then re-formatted
        expect(formatNominal('1.000.000'), '1.000.000');
      },
    );

    test(
      'TC-FM-07: Minimum donation 1000 is formatted correctly',
      () {
        expect(formatNominal('1000'), '1.000');
      },
    );
  });


  group('Rupiah Formatter - KonfirmasiMetodeScreen._formatRupiah()', () {
    // Helper mirrors exact logic from _formatRupiah()
    String formatRupiah(int value) {
      return 'Rp${value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      )}';
    }

    test(
      'TC-FM-08: 1000 is formatted as "Rp1.000"',
      () {
        expect(formatRupiah(1000), 'Rp1.000');
      },
    );

    test(
      'TC-FM-09: 10000 is formatted as "Rp10.000"',
      () {
        expect(formatRupiah(10000), 'Rp10.000');
      },
    );

    test(
      'TC-FM-10: 100000 is formatted as "Rp100.000"',
      () {
        expect(formatRupiah(100000), 'Rp100.000');
      },
    );

    test(
      'TC-FM-11: 1000000 is formatted as "Rp1.000.000"',
      () {
        expect(formatRupiah(1000000), 'Rp1.000.000');
      },
    );

    test(
      'TC-FM-12: 2500 (admin fee) is formatted as "Rp2.500"',
      () {
        expect(formatRupiah(2500), 'Rp2.500');
      },
    );

    test(
      'TC-FM-13: Result always starts with "Rp"',
      () {
        expect(formatRupiah(5000).startsWith('Rp'), true);
      },
    );
  });

  group('Distance Formatter - SearchScreen._formatDistance()', () {
    // Helper mirrors exact logic from _formatDistance()
    String formatDistance(double meters) {
      if (meters < 1000) return '${meters.round()} m';
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }

    test(
      'TC-FM-14: Distance less than 1000m is shown in meters',
      () {
        expect(formatDistance(500), '500 m');
      },
    );

    test(
      'TC-FM-15: Distance of exactly 999m is shown in meters',
      () {
        expect(formatDistance(999), '999 m');
      },
    );

    test(
      'TC-FM-16: Distance of exactly 1000m is shown in km',
      () {
        expect(formatDistance(1000), '1.0 km');
      },
    );

    test(
      'TC-FM-17: Distance of 1500m is shown as "1.5 km"',
      () {
        expect(formatDistance(1500), '1.5 km');
      },
    );

    test(
      'TC-FM-18: Distance of 10000m is shown as "10.0 km"',
      () {
        expect(formatDistance(10000), '10.0 km');
      },
    );

    test(
      'TC-FM-19: Distance is rounded for meters',
      () {
        expect(formatDistance(500.6), '501 m');
        expect(formatDistance(500.4), '500 m');
      },
    );
  });

  group('Distance Label - LokasiScreen._distanceLabel', () {
    // Helper mirrors exact logic from _distanceLabel
    String distanceLabel(double? distanceMeters) {
      if (distanceMeters == null) return 'Jarak tidak tersedia';
      if (distanceMeters < 1000) return '${distanceMeters.round()} m dari lokasi Anda';
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km dari lokasi Anda';
    }

    test(
      'TC-FM-20: Null distance returns "Jarak tidak tersedia"',
      () {
        expect(distanceLabel(null), 'Jarak tidak tersedia');
      },
    );

    test(
      'TC-FM-21: Distance less than 1000m shows in meters with suffix',
      () {
        expect(distanceLabel(500), '500 m dari lokasi Anda');
      },
    );

    test(
      'TC-FM-22: Distance of 1000m or more shows in km with suffix',
      () {
        expect(distanceLabel(1500), '1.5 km dari lokasi Anda');
      },
    );

    test(
      'TC-FM-23: Label always ends with "dari lokasi Anda" when distance is not null',
      () {
        expect(distanceLabel(300).endsWith('dari lokasi Anda'), true);
        expect(distanceLabel(2000).endsWith('dari lokasi Anda'), true);
      },
    );
  });

  group('Date Formatter - TransaksiSuksesScreen._formatTanggal()', () {
    // Helper mirrors exact logic from _formatTanggal()
    String formatTanggal(DateTime date) {
      const bulan = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${date.day} ${bulan[date.month]} ${date.year}';
    }

    test(
      'TC-FM-24: Date is formatted as "D MonthName YYYY"',
      () {
        final date = DateTime(2026, 5, 5);
        expect(formatTanggal(date), '5 Mei 2026');
      },
    );

    test(
      'TC-FM-25: All 12 month names are correct',
      () {
        const expectedMonths = [
          'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        for (int i = 1; i <= 12; i++) {
          final date = DateTime(2026, i, 1);
          expect(formatTanggal(date).contains(expectedMonths[i - 1]), true);
        }
      },
    );

    test(
      'TC-FM-26: Day is not zero-padded',
      () {
        // Day 5 should appear as "5" not "05"
        final date = DateTime(2026, 5, 5);
        expect(formatTanggal(date).startsWith('5'), true);
      },
    );

    test(
      'TC-FM-27: Year is included in the formatted date',
      () {
        final date = DateTime(2026, 5, 5);
        expect(formatTanggal(date).contains('2026'), true);
      },
    );
  });

  group('Username Display - TransaksiSuksesScreen._buildSuksesPage()', () {
    test(
      'TC-FM-28: Non-empty username is prefixed with "@"',
      () {
        const username = 'johndoe';
        final display = username.isNotEmpty ? '@$username' : '...';
        expect(display, '@johndoe');
      },
    );

    test(
      'TC-FM-29: Empty username shows "..."',
      () {
        const username = '';
        final display = username.isNotEmpty ? '@$username' : '...';
        expect(display, '...');
      },
    );

    test(
      'TC-FM-30: Username display always starts with "@" when not empty',
      () {
        const username = 'olivia';
        final display = username.isNotEmpty ? '@$username' : '...';
        expect(display.startsWith('@'), true);
      },
    );
  });
}