import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/donation_api.dart';

void main() {
  // =========================================================================
  // GROUP: DonasiModel.fromJson
  // =========================================================================
  group('DonasiModel.fromJson', () {
    test('parse semua field dengan nilai lengkap', () {
      final json = {
        'id': 1,
        'nama_panti': 'Panti Asuh Harapan',
        'panti_image': 'https://example.com/img.jpg',
        'jumlah': 100000,
        'metode_pembayaran': 'GoPay',
        'no_referensi': 'REF12345',
        'tanggal': '2024-12-14T10:00:00Z',
        'tanggal_label': '14 Desember 2024',
      };

      final model = DonasiModel.fromJson(json);

      expect(model.id, 1);
      expect(model.namaPanti, 'Panti Asuh Harapan');
      expect(model.pantiImage, 'https://example.com/img.jpg');
      expect(model.jumlah, 100000);
      expect(model.metodePembayaran, 'GoPay');
      expect(model.noReferensi, 'REF12345');
      expect(model.tanggal, '2024-12-14T10:00:00Z');
      expect(model.tanggalLabel, '14 Desember 2024');
    });

    test('pantiImage null jika tidak ada di JSON', () {
      final json = {
        'id': 2,
        'nama_panti': 'Panti B',
        'panti_image': null,
        'jumlah': 50000,
        'metode_pembayaran': 'OVO',
        'no_referensi': 'REF99',
        'tanggal': '2024-01-01T00:00:00Z',
        'tanggal_label': '1 Januari 2024',
      };

      final model = DonasiModel.fromJson(json);
      expect(model.pantiImage, isNull);
    });

    test('default kosong saat field opsional tidak ada', () {
      final json = {
        'id': 3,
        'jumlah': 20000,
      };

      final model = DonasiModel.fromJson(json);
      expect(model.namaPanti, '');
      expect(model.metodePembayaran, '');
      expect(model.noReferensi, '');
      expect(model.tanggal, '');
      expect(model.tanggalLabel, '');
      expect(model.pantiImage, isNull);
    });

    test('jumlah default 0 jika tidak ada di JSON', () {
      final json = {'id': 4};
      final model = DonasiModel.fromJson(json);
      expect(model.jumlah, 0);
    });
  });

  // =========================================================================
  // GROUP: DonasiModel.formattedJumlah
  // =========================================================================
  group('DonasiModel.formattedJumlah', () {
    test('format Rp1.000 untuk jumlah 1000', () {
      final model = _buildModel(jumlah: 1000);
      expect(model.formattedJumlah, 'Rp1.000');
    });

    test('format Rp50.000 untuk jumlah 50000', () {
      final model = _buildModel(jumlah: 50000);
      expect(model.formattedJumlah, 'Rp50.000');
    });

    test('format Rp100.000 untuk jumlah 100000', () {
      final model = _buildModel(jumlah: 100000);
      expect(model.formattedJumlah, 'Rp100.000');
    });

    test('format Rp1.000.000 untuk jumlah 1000000', () {
      final model = _buildModel(jumlah: 1000000);
      expect(model.formattedJumlah, 'Rp1.000.000');
    });

    test('format Rp5.250.000 untuk jumlah 5250000', () {
      final model = _buildModel(jumlah: 5250000);
      expect(model.formattedJumlah, 'Rp5.250.000');
    });

    test('format Rp500 untuk jumlah 500 (kurang dari 1000, tanpa titik)', () {
      final model = _buildModel(jumlah: 500);
      expect(model.formattedJumlah, 'Rp500');
    });

    test('format Rp0 untuk jumlah 0', () {
      final model = _buildModel(jumlah: 0);
      expect(model.formattedJumlah, 'Rp0');
    });
  });

  // =========================================================================
  // GROUP: DonasiModel.tanggalDateTime
  // =========================================================================
  group('DonasiModel.tanggalDateTime', () {
    test('parse tanggal ISO dengan benar', () {
      final model = _buildModel(tanggal: '2024-12-14T10:00:00Z');
      final dt = model.tanggalDateTime;
      expect(dt.year, 2024);
      expect(dt.month, 12);
      expect(dt.day, 14);
    });

    test('kembalikan DateTime.now() untuk string kosong', () {
      final model = _buildModel(tanggal: '');
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final after  = DateTime.now().add(const Duration(seconds: 1));
      final dt = model.tanggalDateTime;
      expect(dt.isAfter(before), isTrue);
      expect(dt.isBefore(after), isTrue);
    });

    test('kembalikan DateTime.now() untuk tanggal tidak valid', () {
      final model = _buildModel(tanggal: 'bukan-tanggal');
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final dt = model.tanggalDateTime;
      expect(dt.isAfter(before), isTrue);
    });
  });
}

// ---------------------------------------------------------------------------
// Helper – membangun DonasiModel dengan nilai default
// ---------------------------------------------------------------------------
DonasiModel _buildModel({
  int id = 1,
  String namaPanti = 'Panti Test',
  String? pantiImage,
  int jumlah = 10000,
  String metodePembayaran = 'GoPay',
  String noReferensi = 'REF001',
  String tanggal = '2024-01-01T00:00:00Z',
  String tanggalLabel = '1 Januari 2024',
}) =>
    DonasiModel(
      id: id,
      namaPanti: namaPanti,
      pantiImage: pantiImage,
      jumlah: jumlah,
      metodePembayaran: metodePembayaran,
      noReferensi: noReferensi,
      tanggal: tanggal,
      tanggalLabel: tanggalLabel,
    );