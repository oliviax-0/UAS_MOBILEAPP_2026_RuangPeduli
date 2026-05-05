import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/finance_api.dart';

void main() {
  group('FinanceApi model test', () {
    test('FinanceDashboard fromJson berhasil', () {
      final model = FinanceDashboard.fromJson({
        'total_pemasukan': 100000,
        'total_pengeluaran': 25000,
        'saldo': 75000,
      });

      expect(model.totalPemasukan, 100000);
      expect(model.totalPengeluaran, 25000);
      expect(model.saldo, 75000);
    });

    test('TransactionModel berhasil dibuat', () {
      const trx = TransactionModel(
        id: 1,
        category: 'Donasi',
        subLabel: 'Test',
        jumlah: 50000,
        isIncome: true,
        tanggal: '2024-01-01',
        createdAt: '2024-01-01',
      );

      expect(trx.id, 1);
      expect(trx.category, 'Donasi');
      expect(trx.formattedAmount, 'Rp 50.000');
    });

    test('JenisPemasukanModel fromJson berhasil', () {
      final model = JenisPemasukanModel.fromJson({
        'id': 1,
        'nama': 'Donasi',
      });

      expect(model.id, 1);
      expect(model.nama, 'Donasi');
    });
  });
}
