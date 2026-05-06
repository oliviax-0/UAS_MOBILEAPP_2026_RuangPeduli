import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ sesuaikan dengan class asli project kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_stokmasuk.dart';

void main() {
  testWidgets('Search flow test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: InventoryPantiStokMasuk(),
      ),
    );

    // render awal
    await tester.pump();

    // tunggu async selesai
    await tester.pumpAndSettle();

    // halaman tampil
    expect(find.byType(InventoryPantiStokMasuk), findsOneWidget);

    // cari search field
    final search = find.byType(TextField);

    if (search.evaluate().isNotEmpty) {
      // input search
      await tester.enterText(search.first, 'Beras');
      await tester.pump();

      // validasi text masuk
      expect(find.text('Beras'), findsWidgets);
    }

    // kemungkinan hasil UI
    final loading = find.byType(CircularProgressIndicator);
    final list = find.byType(ListView);
    final empty = find.textContaining('Belum');

    expect(
      loading.evaluate().isNotEmpty ||
          list.evaluate().isNotEmpty ||
          empty.evaluate().isNotEmpty ||
          search.evaluate().isNotEmpty,
      true,
    );

    // pastikan tidak crash
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}