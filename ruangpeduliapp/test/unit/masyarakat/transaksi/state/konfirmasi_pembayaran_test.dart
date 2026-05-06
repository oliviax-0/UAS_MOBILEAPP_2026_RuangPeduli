import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Isolasi logika bisnis dari KonfirmasiPembayaranScreen ke dalam
// kelas testable tanpa ketergantungan Flutter widget.
// ---------------------------------------------------------------------------

/// Meniru logika _formatNominal dari KonfirmasiPembayaranScreen
String formatNominal(String raw) {
  final digits = raw.replaceAll('.', '');
  if (digits.isEmpty) return '';
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Meniru logika validasi nominal dari _onKonfirmasi
String? validateNominal(String input) {
  final raw = input.replaceAll('.', '');
  if (raw.isEmpty) return 'Masukkan nominal donasi';
  final nominal = int.tryParse(raw) ?? 0;
  if (nominal < 1000) return 'Nominal minimal Rp1.000';
  return null; // valid
}

void main() {
  // =========================================================================
  // GROUP: formatNominal – auto-format thousand separator
  // =========================================================================
  group('formatNominal (KonfirmasiPembayaran)', () {
    test('string kosong dikembalikan kosong', () {
      expect(formatNominal(''), '');
    });

    test('angka 3 digit tanpa titik', () {
      expect(formatNominal('500'), '500');
    });

    test('angka 4 digit mendapat titik di posisi ke-1', () {
      expect(formatNominal('1000'), '1.000');
    });

    test('angka 5 digit: 50000 → 50.000', () {
      expect(formatNominal('50000'), '50.000');
    });

    test('angka 6 digit: 100000 → 100.000', () {
      expect(formatNominal('100000'), '100.000');
    });

    test('angka 7 digit: 1000000 → 1.000.000', () {
      expect(formatNominal('1000000'), '1.000.000');
    });

    test('angka 9 digit: 250000000 → 250.000.000', () {
      expect(formatNominal('250000000'), '250.000.000');
    });

    test('input yang sudah ada titik: strip dulu lalu format ulang', () {
      // Simulasi: user sudah mengetik '1.000' lalu kita format ulang
      expect(formatNominal('1.000'), '1.000');
    });

    test('angka 10 digit: 1234567890 → 1.234.567.890', () {
      expect(formatNominal('1234567890'), '1.234.567.890');
    });
  });

  // =========================================================================
  // GROUP: validateNominal – validasi input sebelum lanjut ke metode
  // =========================================================================
  group('validateNominal (KonfirmasiPembayaran)', () {
    test('input kosong → error "Masukkan nominal donasi"', () {
      expect(validateNominal(''), 'Masukkan nominal donasi');
    });

    test('input "0" → error nominal minimal', () {
      expect(validateNominal('0'), 'Nominal minimal Rp1.000');
    });

    test('input "999" → error nominal minimal', () {
      expect(validateNominal('999'), 'Nominal minimal Rp1.000');
    });

    test('input "1000" → valid (null)', () {
      expect(validateNominal('1000'), isNull);
    });

    test('input "1.000" (dengan titik) → valid (null)', () {
      expect(validateNominal('1.000'), isNull);
    });

    test('input "50.000" → valid (null)', () {
      expect(validateNominal('50.000'), isNull);
    });

    test('input "1.000.000" → valid (null)', () {
      expect(validateNominal('1.000.000'), isNull);
    });

    test('input "1001" → valid (null)', () {
      expect(validateNominal('1001'), isNull);
    });

    test('input berisi karakter non-digit setelah strip → 0, error minimal', () {
      // replaceAll('.', '') dari 'abc' = 'abc', tryParse = null → 0
      expect(validateNominal('abc'), 'Nominal minimal Rp1.000');
    });
  });

  // =========================================================================
  // GROUP: Kalkulasi nominal donasi + biaya admin = total pembayaran
  // Meniru _nominalInt, _biayaAdmin, _totalPembayaran dari KonfirmasiMetodeScreen
  // =========================================================================
  group('Kalkulasi total pembayaran (KonfirmasiMetode)', () {
    const biayaAdmin = 2500;

    int parseNominal(String nominal) {
      try {
        return int.parse(nominal.replaceAll('.', '').replaceAll(',', ''));
      } catch (_) {
        return 0;
      }
    }

    int totalPembayaran(String nominal) =>
        parseNominal(nominal) + biayaAdmin;

    test('nominal 50.000 + 2500 = 52500', () {
      expect(totalPembayaran('50.000'), 52500);
    });

    test('nominal 100.000 + 2500 = 102500', () {
      expect(totalPembayaran('100.000'), 102500);
    });

    test('nominal 1.000.000 + 2500 = 1002500', () {
      expect(totalPembayaran('1.000.000'), 1002500);
    });

    test('nominal kosong → 0 + 2500 = 2500', () {
      expect(totalPembayaran(''), 2500);
    });

    test('nominal tidak valid → 0 + 2500 = 2500', () {
      expect(totalPembayaran('abc'), 2500);
    });

    test('biaya admin selalu Rp2.500', () {
      expect(biayaAdmin, 2500);
    });
  });

  // =========================================================================
  // GROUP: formatRupiah helper (KonfirmasiMetodeScreen._formatRupiah)
  // =========================================================================
  group('formatRupiah (KonfirmasiMetode)', () {
    String formatRupiah(int amount) {
      final s = amount.toString();
      final buffer = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
        buffer.write(s[i]);
      }
      return 'Rp${buffer.toString()}';
    }

    test('Rp2.500 untuk 2500', () {
      expect(formatRupiah(2500), 'Rp2.500');
    });

    test('Rp52.500 untuk 52500', () {
      expect(formatRupiah(52500), 'Rp52.500');
    });

    test('Rp100.000 untuk 100000', () {
      expect(formatRupiah(100000), 'Rp100.000');
    });

    test('Rp1.002.500 untuk 1002500', () {
      expect(formatRupiah(1002500), 'Rp1.002.500');
    });

    test('Rp0 untuk 0', () {
      expect(formatRupiah(0), 'Rp0');
    });
  });
}