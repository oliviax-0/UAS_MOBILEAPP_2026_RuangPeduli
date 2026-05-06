import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Isolasi logika bisnis TransaksiSuksesScreen:
// – format tanggal Indonesia
// – no referensi dari milliseconds
// – format waktu WIB
// – avatar initial
// ---------------------------------------------------------------------------

/// Meniru _formatTanggal dari TransaksiSuksesScreen
String formatTanggal(DateTime now) {
  const bulan = [
    '',
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  return '${now.day} ${bulan[now.month]} ${now.year}';
}

/// Meniru pembentukan no referensi di TransaksiSuksesScreen
String buildNoReferensi(int millisecondsSinceEpoch) =>
    'REF${millisecondsSinceEpoch % 100000}';

/// Meniru logika initial avatar
String avatarInitial(String username) =>
    username.isNotEmpty ? username[0].toUpperCase() : '?';

/// Meniru format waktu WIB
String formatWaktuWib(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')} WIB';

void main() {
  // =========================================================================
  // GROUP: formatTanggal – format tanggal bahasa Indonesia
  // =========================================================================
  group('formatTanggal (TransaksiSukses)', () {
    test('14 Desember 2024', () {
      expect(
        formatTanggal(DateTime(2024, 12, 14)),
        '14 Desember 2024',
      );
    });

    test('1 Januari 2024', () {
      expect(
        formatTanggal(DateTime(2024, 1, 1)),
        '1 Januari 2024',
      );
    });

    test('28 Februari 2024 (tahun kabisat)', () {
      expect(
        formatTanggal(DateTime(2024, 2, 28)),
        '28 Februari 2024',
      );
    });

    test('17 Agustus 1945 (HUT RI)', () {
      expect(
        formatTanggal(DateTime(1945, 8, 17)),
        '17 Agustus 1945',
      );
    });

    test('semua 12 bulan diformat dengan benar', () {
      const expected = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      for (int m = 1; m <= 12; m++) {
        final result = formatTanggal(DateTime(2024, m, 1));
        expect(result, '1 ${expected[m - 1]} 2024',
            reason: 'Bulan ke-$m harus ${expected[m - 1]}');
      }
    });

    test('tanggal tanpa leading zero (1, bukan 01)', () {
      final result = formatTanggal(DateTime(2024, 3, 5));
      expect(result, '5 Maret 2024');
      expect(result.startsWith('0'), isFalse);
    });
  });

  // =========================================================================
  // GROUP: buildNoReferensi
  // =========================================================================
  group('buildNoReferensi (TransaksiSukses)', () {
    test('diawali dengan "REF"', () {
      expect(buildNoReferensi(123456789), startsWith('REF'));
    });

    test('bagian angka adalah sisa bagi 100000', () {
      expect(buildNoReferensi(200000), 'REF0');
      expect(buildNoReferensi(200001), 'REF1');
      expect(buildNoReferensi(299999), 'REF99999');
    });

    test('tidak melebihi 5 digit angka', () {
      for (int i = 0; i < 20; i++) {
        final ms = DateTime(2024, 1, i + 1).millisecondsSinceEpoch;
        final ref = buildNoReferensi(ms);
        final digits = ref.replaceFirst('REF', '');
        expect(int.parse(digits), lessThan(100000),
            reason: 'Digit harus < 100000');
      }
    });
  });

  // =========================================================================
  // GROUP: avatarInitial
  // =========================================================================
  group('avatarInitial (TransaksiSukses)', () {
    test('huruf pertama uppercase dari "budi" adalah "B"', () {
      expect(avatarInitial('budi'), 'B');
    });

    test('huruf pertama uppercase dari "Ahmad" adalah "A"', () {
      expect(avatarInitial('Ahmad'), 'A');
    });

    test('username kosong mengembalikan "?"', () {
      expect(avatarInitial(''), '?');
    });

    test('username satu karakter huruf kecil → uppercase', () {
      expect(avatarInitial('z'), 'Z');
    });

    test('angka sebagai awal username', () {
      expect(avatarInitial('1user'), '1');
    });
  });

  // =========================================================================
  // GROUP: formatWaktuWib
  // =========================================================================
  group('formatWaktuWib (TransaksiSukses)', () {
    test('00.00 WIB untuk midnight', () {
      expect(formatWaktuWib(0, 0), '00.00 WIB');
    });

    test('09.05 WIB untuk jam 9 menit 5', () {
      expect(formatWaktuWib(9, 5), '09.05 WIB');
    });

    test('10.30 WIB untuk jam 10 menit 30', () {
      expect(formatWaktuWib(10, 30), '10.30 WIB');
    });

    test('23.59 WIB untuk jam 23 menit 59', () {
      expect(formatWaktuWib(23, 59), '23.59 WIB');
    });

    test('jam dan menit selalu 2 digit (leading zero)', () {
      final result = formatWaktuWib(8, 7);
      expect(result, '08.07 WIB');
    });

    test('diakhiri dengan " WIB"', () {
      expect(formatWaktuWib(12, 0), endsWith(' WIB'));
    });
  });

  // =========================================================================
  // GROUP: display username di transaksi sukses
  // =========================================================================
  group('Display username (TransaksiSukses)', () {
    String displayUsername(String username) =>
        username.isNotEmpty ? '@$username' : '...';

    test('username tidak kosong → "@username"', () {
      expect(displayUsername('budi123'), '@budi123');
    });

    test('username kosong → "..."', () {
      expect(displayUsername(''), '...');
    });

    test('username dengan spasi → "@nama lengkap"', () {
      expect(displayUsername('nama lengkap'), '@nama lengkap');
    });
  });
}