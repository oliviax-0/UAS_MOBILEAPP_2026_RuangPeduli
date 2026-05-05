import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/finance_api.dart';

void main() {
  group('Dashboard model test', () {
    test('FinanceDashboard fromJson berhasil', () {
      final dashboard = FinanceDashboard.fromJson({
        'saldo': 100000,
        'total_pemasukan': 50000,
        'total_pengeluaran': 20000,
      });

      expect(dashboard.saldo, 100000);
      expect(dashboard.totalPemasukan, 50000);
      expect(dashboard.totalPengeluaran, 20000);
    });

    test('FinanceDashboard fromJson menerima string angka', () {
      final dashboard = FinanceDashboard.fromJson({
        'saldo': '100000',
        'total_pemasukan': '50000',
        'total_pengeluaran': '20000',
      });

      expect(dashboard.saldo, 100000);
      expect(dashboard.totalPemasukan, 50000);
      expect(dashboard.totalPengeluaran, 20000);
    });
  });
}
