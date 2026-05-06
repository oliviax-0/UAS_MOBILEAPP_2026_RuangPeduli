import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Isolasi logika bisnis KonfirmasiMetodeScreen:
// – pemilihan metode pembayaran
// – pembentukan no. referensi
// – logika _nominalInt parsing
// ---------------------------------------------------------------------------

/// Simulasi state pemilihan metode pembayaran
class MetodePembayaranState {
  String selectedMetode;

  final List<String> availableMetodes = [
    'GoPay',
    'OVO',
    'DANA',
    'Transfer Bank',
  ];

  MetodePembayaranState({this.selectedMetode = 'GoPay'});

  bool isValid(String metode) => availableMetodes.contains(metode);

  void select(String metode) {
    if (!isValid(metode)) throw ArgumentError('Metode tidak dikenal: $metode');
    selectedMetode = metode;
  }
}

/// Meniru _nominalInt parsing dari KonfirmasiMetodeScreen
int parseNominalInt(String nominal) {
  try {
    return int.parse(nominal.replaceAll('.', '').replaceAll(',', ''));
  } catch (_) {
    return 0;
  }
}

/// Meniru pembuatan noReferensi
String buildNoReferensi(int millisecondsSinceEpoch) =>
    'REF${millisecondsSinceEpoch % 100000}';

void main() {
  // =========================================================================
  // GROUP: MetodePembayaranState – pemilihan metode
  // =========================================================================
  group('MetodePembayaranState', () {
    test('default metode adalah GoPay', () {
      final state = MetodePembayaranState();
      expect(state.selectedMetode, 'GoPay');
    });

    test('dapat memilih OVO', () {
      final state = MetodePembayaranState();
      state.select('OVO');
      expect(state.selectedMetode, 'OVO');
    });

    test('dapat memilih DANA', () {
      final state = MetodePembayaranState();
      state.select('DANA');
      expect(state.selectedMetode, 'DANA');
    });

    test('dapat memilih Transfer Bank', () {
      final state = MetodePembayaranState();
      state.select('Transfer Bank');
      expect(state.selectedMetode, 'Transfer Bank');
    });

    test('dapat kembali ke GoPay setelah pilih lain', () {
      final state = MetodePembayaranState();
      state.select('DANA');
      state.select('GoPay');
      expect(state.selectedMetode, 'GoPay');
    });

    test('melempar ArgumentError untuk metode tidak dikenal', () {
      final state = MetodePembayaranState();
      expect(() => state.select('Bitcoin'), throwsArgumentError);
    });

    test('daftar metode berisi 4 item', () {
      final state = MetodePembayaranState();
      expect(state.availableMetodes.length, 4);
    });

    test('semua metode yang tersedia adalah valid', () {
      final state = MetodePembayaranState();
      for (final m in state.availableMetodes) {
        expect(state.isValid(m), isTrue);
      }
    });
  });

  // =========================================================================
  // GROUP: parseNominalInt
  // =========================================================================
  group('parseNominalInt (KonfirmasiMetode)', () {
    test('parse "50.000" → 50000', () {
      expect(parseNominalInt('50.000'), 50000);
    });

    test('parse "100.000" → 100000', () {
      expect(parseNominalInt('100.000'), 100000);
    });

    test('parse "1.000.000" → 1000000', () {
      expect(parseNominalInt('1.000.000'), 1000000);
    });

    test('parse "1000" tanpa titik → 1000', () {
      expect(parseNominalInt('1000'), 1000);
    });

    test('parse string kosong → 0', () {
      expect(parseNominalInt(''), 0);
    });

    test('parse "abc" → 0', () {
      expect(parseNominalInt('abc'), 0);
    });

    test('parse "1,000" dengan koma → 1000', () {
      expect(parseNominalInt('1,000'), 1000);
    });
  });

  // =========================================================================
  // GROUP: buildNoReferensi
  // =========================================================================
  group('buildNoReferensi', () {
    test('format dimulai dengan "REF"', () {
      final ref = buildNoReferensi(1000000);
      expect(ref.startsWith('REF'), isTrue);
    });

    test('bagian angka adalah modulus 100000', () {
      final ms = 1734567890123;
      final ref = buildNoReferensi(ms);
      final numeric = int.parse(ref.replaceFirst('REF', ''));
      expect(numeric, ms % 100000);
    });

    test('panjang bagian angka maksimal 5 digit', () {
      final ref = buildNoReferensi(DateTime.now().millisecondsSinceEpoch);
      final numeric = ref.replaceFirst('REF', '');
      expect(numeric.length, lessThanOrEqualTo(5));
    });

    test('dua referensi dari ms berbeda menghasilkan nilai berbeda (jika mod berbeda)', () {
      // Pilih dua nilai yang jelas berbeda setelah mod
      final ref1 = buildNoReferensi(100000);
      final ref2 = buildNoReferensi(100001);
      // 100000 % 100000 = 0, 100001 % 100000 = 1
      expect(ref1, isNot(equals(ref2)));
    });
  });

  // =========================================================================
  // GROUP: kalkulasi total dengan biaya admin
  // =========================================================================
  group('Total pembayaran inkl. biaya admin', () {
    const biayaAdmin = 2500;

    test('nominal 0 → total hanya biaya admin', () {
      expect(parseNominalInt('') + biayaAdmin, 2500);
    });

    test('nominal 50000 → total 52500', () {
      expect(parseNominalInt('50.000') + biayaAdmin, 52500);
    });

    test('nominal 1000000 → total 1002500', () {
      expect(parseNominalInt('1.000.000') + biayaAdmin, 1002500);
    });
  });
}