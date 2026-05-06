// test/mocks/mock_finance_api.dart

import 'package:ruangpeduliapp/data/finance_api.dart';
import 'package:test/test.dart';

class MockFinanceApi {
  /// =========================
  /// DASHBOARD
  /// =========================
  Future<Map<String, dynamic>> fetchDashboard() async {
    return {
      'saldo': 100000,
      'total_pemasukan': 50000,
      'total_pengeluaran': 20000,
    };
  }

  /// =========================
  /// GET TRANSACTIONS
  /// =========================
  Future<List<TransactionModel>> getTransactions() async {
    return [
      const TransactionModel(
        id: 1,
        category: 'Donasi',
        jumlah: 50000,
        subLabel: 'Pemasukan',
        isIncome: true,
        tanggal: '2024-01-01',
        createdAt: '2024-01-01',
      ),
      const TransactionModel(
        id: 2,
        category: 'Makanan',
        jumlah: 20000,
        subLabel: 'Pengeluaran',
        isIncome: false,
        tanggal: '2024-01-02',
        createdAt: '2024-01-02',
      ),
    ];
  }

  /// =========================
  /// TAMBAH PEMASUKAN
  /// =========================
  Future<bool> addPemasukan(TransactionModel trx) async {
    return true;
  }

  /// =========================
  /// TAMBAH PENGELUARAN
  /// =========================
  Future<bool> addPengeluaran(TransactionModel trx) async {
    return true;
  }

  /// =========================
  /// DELETE TRANSACTION
  /// =========================
  Future<bool> deleteTransaction(int id) async {
    return true;
  }
}

void main() {
  group('MockFinanceApi Tests', () {
    late MockFinanceApi api;

    setUp(() {
      api = MockFinanceApi();
    });

    test('fetchDashboard returns valid mock data', () async {
      final result = await api.fetchDashboard();
      expect(result['saldo'], 100000);
      expect(result['total_pemasukan'], 50000);
    });

    test('getTransactions returns list of transactions', () async {
      final result = await api.getTransactions();
      expect(result, hasLength(2));
      expect(result.first.category, 'Donasi');
      expect(result.last.isIncome, false);
    });

    test('add methods return true', () async {
      const trx = TransactionModel(
        id: 3,
        category: 'Test',
        jumlah: 100,
        subLabel: 'Test',
        isIncome: true,
        tanggal: '2024-01-01',
        createdAt: '2024-01-01',
      );
      expect(await api.addPemasukan(trx), true);
      expect(await api.addPengeluaran(trx), true);
    });
  });
}