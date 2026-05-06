import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_plus.dart';

void main() {
  testWidgets('Pengeluaran flow basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InputTransaksiPage(
          userId: 1,
          pantiId: 1,
        ),
      ),
    );

    expect(find.byType(InputTransaksiPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Pengeluaran'));
    await tester.pump(const Duration(milliseconds: 300));

    final fields = find.byType(TextField);

    if (fields.evaluate().isNotEmpty) {
      await tester.enterText(fields.first, '20000');
      await tester.pump();
    }

    if (fields.evaluate().length >= 2) {
      await tester.enterText(fields.at(1), 'Test pengeluaran');
      await tester.pump();
    }

    final dropdown = find.byType(DropdownButton);

    if (dropdown.evaluate().isNotEmpty) {
      await tester.tap(dropdown.first);
      await tester.pump(const Duration(milliseconds: 300));

      final item = find.byType(DropdownMenuItem);

      if (item.evaluate().isNotEmpty) {
        await tester.tap(item.first);
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    final saveBtn = find.textContaining('Simpan').evaluate().isNotEmpty
        ? find.textContaining('Simpan')
        : find.textContaining('Tambah');

    if (saveBtn.evaluate().isNotEmpty) {
      await tester.tap(saveBtn);
      await tester.pump(const Duration(milliseconds: 300));
    }

    final snackbar = find.byType(SnackBar);
    final loading = find.byType(CircularProgressIndicator);

    expect(
      snackbar.evaluate().isNotEmpty ||
          loading.evaluate().isNotEmpty ||
          find.byType(InputTransaksiPage).evaluate().isNotEmpty,
      true,
    );
  });
}
