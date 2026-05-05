import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/finance_api.dart';

void main() {
  group('Pengeluaran data test', () {
    test('TransactionModel pengeluaran berhasil', () {
      const trx = TransactionModel(
        id: 1,
        category: 'Operasional',
        subLabel: 'Test',
        jumlah: 20000,
        isIncome: false,
        tanggal: '2024-01-01',
        createdAt: '2024-01-01',
      );

      expect(trx.category, 'Operasional');
      expect(trx.isIncome, false);
      expect(trx.formattedAmount, 'Rp 20.000');
    });

    test('FinanceDashboard menghitung data pengeluaran', () {
      final dashboard = FinanceDashboard.fromJson({
        'total_pemasukan': 50000,
        'total_pengeluaran': 20000,
        'saldo': 30000,
      });

      expect(dashboard.totalPengeluaran, 20000);
      expect(dashboard.saldo, 30000);
    });
  });
}
