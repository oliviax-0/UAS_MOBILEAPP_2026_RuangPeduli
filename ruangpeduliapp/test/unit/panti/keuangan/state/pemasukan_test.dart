import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/finance_api.dart';

void main() {
  group('Pemasukan data test', () {
    test('JenisPemasukanModel berhasil dibuat dari json', () {
      final jenis = JenisPemasukanModel.fromJson({
        'id': 1,
        'nama': 'Donasi',
      });

      expect(jenis.id, 1);
      expect(jenis.nama, 'Donasi');
    });

    test('TransactionModel pemasukan berhasil', () {
      const trx = TransactionModel(
        id: 1,
        category: 'Donasi',
        subLabel: 'Test',
        jumlah: 50000,
        isIncome: true,
        tanggal: '2024-01-01',
        createdAt: '2024-01-01',
      );

      expect(trx.category, 'Donasi');
      expect(trx.isIncome, true);
      expect(trx.formattedAmount, 'Rp 50.000');
    });
  });
}
