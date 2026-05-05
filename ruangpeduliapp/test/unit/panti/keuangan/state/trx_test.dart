import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/finance_api.dart';

void main() {
  group('Transaction state data test', () {
    test('TransactionModel income berhasil', () {
      const trx = TransactionModel(
        id: 1,
        category: 'Donasi',
        subLabel: 'Test',
        jumlah: 10000,
        isIncome: true,
        tanggal: '2024-01-01',
        createdAt: '2024-01-01',
      );

      expect(trx.id, 1);
      expect(trx.category, 'Donasi');
      expect(trx.isIncome, true);
      expect(trx.formattedAmount, 'Rp 10.000');
    });

    test('TransactionModel expense berhasil', () {
      const trx = TransactionModel(
        id: 2,
        category: 'Makanan',
        subLabel: 'Test',
        jumlah: 25000,
        isIncome: false,
        tanggal: '2024-01-02',
        createdAt: '2024-01-02',
      );

      expect(trx.id, 2);
      expect(trx.category, 'Makanan');
      expect(trx.isIncome, false);
      expect(trx.formattedAmount, 'Rp 25.000');
    });
  });
}
