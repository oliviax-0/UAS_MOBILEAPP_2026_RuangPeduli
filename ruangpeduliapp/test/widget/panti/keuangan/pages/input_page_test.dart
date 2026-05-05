import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_plus.dart';

void main() {
  testWidgets('InputPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InputTransaksiPage(
          userId: 1,
          pantiId: 1,
        ),
      ),
    );

    expect(find.byType(InputTransaksiPage), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    expect(find.text('Pemasukan'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);

    // cek ada TextField (input form)
    final fields = find.byType(TextField);
    expect(fields, findsWidgets);

    // cek tombol simpan / tambah
    final saveBtn = find.textContaining('Simpan').evaluate().isNotEmpty
        ? find.textContaining('Simpan')
        : find.textContaining('Tambah');

    if (saveBtn.evaluate().isNotEmpty) {
      expect(saveBtn, findsOneWidget);
    }
  });
}
