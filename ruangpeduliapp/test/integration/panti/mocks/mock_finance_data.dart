// test/mocks/mock_finance_data.dart

import 'package:ruangpeduliapp/data/finance_api.dart';
import 'package:test/test.dart';

/// =========================
/// DASHBOARD DATA
/// =========================
final mockDashboard = {
  'saldo': 100000,
  'total_pemasukan': 50000,
  'total_pengeluaran': 20000,
};

/// =========================
/// SINGLE TRANSACTION
/// =========================
final mockTrx = const TransactionModel(
  id: 1,
  category: 'Donasi',
  jumlah: 50000,
  subLabel: 'Pemasukan',
  isIncome: true,
  tanggal: '2024-01-01',
  createdAt: '2024-01-01',
);

/// =========================
/// LIST TRANSACTIONS
/// =========================
final mockTrxList = [
  mockTrx,
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

/// =========================
/// PEMASUKAN DATA
/// =========================
final mockPemasukan = const TransactionModel(
  id: 3,
  category: 'Donasi Baru',
  jumlah: 75000,
  subLabel: 'Tambahan pemasukan',
  isIncome: true,
  tanggal: '2024-01-03',
  createdAt: '2024-01-03',
);

/// =========================
/// PENGELUARAN DATA
/// =========================
final mockPengeluaran = const TransactionModel(
  id: 4,
  category: 'Operasional',
  jumlah: 30000,
  subLabel: 'Biaya listrik',
  isIncome: false,
  tanggal: '2024-01-04',
  createdAt: '2024-01-04',
);

void main() {
  group('Mock Finance Data validation', () {
    test('mockTrx has valid data', () {
      expect(mockTrx.jumlah, 50000);
      expect(mockTrx.isIncome, isTrue);
      expect(mockTrx.category, 'Donasi');
    });
  });
}