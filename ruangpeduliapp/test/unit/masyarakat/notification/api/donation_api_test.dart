import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/donation_api.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _donationJson({
  int id = 1,
  String namaPanti = 'Panti Kasih',
  int jumlah = 50000,
  String tanggal = '2024-06-01T10:00:00.000Z',
  String tanggalLabel = '1 Juni 2024',
  String metodePembayaran = 'Transfer',
  String noReferensi = 'REF001',
}) =>
    {
      'id': id,
      'nama_panti': namaPanti,
      'jumlah': jumlah,
      'tanggal': tanggal,
      'tanggal_label': tanggalLabel,
      'metode_pembayaran': metodePembayaran,
      'no_referensi': noReferensi,
      'panti_image': null,
    };

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DonasiModel — kontrak model (tanpa jaringan)', () {
    test('fromJson memparsing namaPanti dengan benar', () {
      final model = DonasiModel.fromJson(_donationJson(namaPanti: 'Panti Harapan'));
      expect(model.namaPanti, 'Panti Harapan');
    });

    test('fromJson memparsing jumlah sebagai int', () {
      final model = DonasiModel.fromJson(_donationJson(jumlah: 75000));
      expect(model.jumlah, 75000);
    });

    test('formattedJumlah mengandung titik pemisah ribuan', () {
      final model = DonasiModel.fromJson(_donationJson(jumlah: 150000));
      expect(model.formattedJumlah, contains('150.000'));
    });

    test('formattedJumlah dimulai dengan prefix Rp', () {
      final model = DonasiModel.fromJson(_donationJson(jumlah: 50000));
      expect(model.formattedJumlah, startsWith('Rp'));
    });

    test('formattedJumlah untuk angka kecil mengandung angka tersebut', () {
      final model = DonasiModel.fromJson(_donationJson(jumlah: 500));
      expect(model.formattedJumlah, contains('500'));
    });

    test('tanggalLabel diparsing langsung dari field tanggal_label', () {
      final model = DonasiModel.fromJson(
        _donationJson(tanggalLabel: '14 Desember 2026'),
      );
      expect(model.tanggalLabel, '14 Desember 2026');
    });

    test('tanggalLabel kosong string jika tidak dikirim API', () {
      final json = _donationJson()..remove('tanggal_label');
      // fromJson fallback: json['tanggal_label'] ?? ''
      final model = DonasiModel.fromJson({...json, 'tanggal_label': null});
      expect(model.tanggalLabel, '');
    });

    test('metodePembayaran diparsing dengan benar', () {
      final model = DonasiModel.fromJson(
        _donationJson(metodePembayaran: 'QRIS'),
      );
      expect(model.metodePembayaran, 'QRIS');
    });

    test('noReferensi diparsing dengan benar', () {
      final model = DonasiModel.fromJson(
        _donationJson(noReferensi: 'TRX-20240601-001'),
      );
      expect(model.noReferensi, 'TRX-20240601-001');
    });

    test('pantiImage null ketika tidak dikirim API', () {
      final model = DonasiModel.fromJson(_donationJson());
      expect(model.pantiImage, isNull);
    });

    test('list donasi diparsing dengan benar dari JSON array', () {
      final raw = jsonEncode([
        _donationJson(id: 1, namaPanti: 'Panti A', jumlah: 10000),
        _donationJson(id: 2, namaPanti: 'Panti B', jumlah: 20000),
      ]);
      final list = (jsonDecode(raw) as List)
          .map((e) => DonasiModel.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(list.length, 2);
      expect(list[0].namaPanti, 'Panti A');
      expect(list[1].jumlah, 20000);
    });

    test('total donasi dihitung dengan fold secara akurat', () {
      final donations = [
        DonasiModel.fromJson(_donationJson(jumlah: 10000)),
        DonasiModel.fromJson(_donationJson(jumlah: 25000)),
        DonasiModel.fromJson(_donationJson(jumlah: 15000)),
      ];
      final total = donations.fold<int>(0, (sum, d) => sum + d.jumlah);
      expect(total, 50000);
    });

    test('list kosong menghasilkan total donasi nol', () {
      final List<DonasiModel> donations = [];
      final total = donations.fold<int>(0, (sum, d) => sum + d.jumlah);
      expect(total, 0);
    });
  });
}