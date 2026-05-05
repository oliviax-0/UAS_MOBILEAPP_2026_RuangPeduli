import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/data/finance_api.dart';

void main() {
  group('TransactionModel Test', () {
    test('constructor berhasil', () {
      const model = TransactionModel(
        id: 1,
        category: 'Makanan',
        subLabel: 'Test',
        jumlah: 10000,
        isIncome: true,
        tanggal: '2024-01-01',
        createdAt: '2024-01-01',
      );

      expect(model.id, 1);
      expect(model.category, 'Makanan');
      expect(model.jumlah, 10000);
      expect(model.subLabel, 'Test');
      expect(model.isIncome, true);
    });

    test('formattedAmount berhasil', () {
      const model = TransactionModel(
        id: 1,
        category: 'Makanan',
        subLabel: 'Test',
        jumlah: 10000,
        isIncome: true,
        tanggal: '2024-01-01',
        createdAt: '2024-01-01',
      );

      expect(model.formattedAmount, 'Rp 10.000');
    });
  });
}
