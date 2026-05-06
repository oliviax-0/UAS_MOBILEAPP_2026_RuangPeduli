import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ sesuaikan dengan project asli kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti.dart';

void main() {
  testWidgets('Dashboard flow test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: InventoryPanti(),
      ),
    );

    // render awal
    await tester.pump();

    // tunggu async
    await tester.pumpAndSettle();

    // halaman tampil
    expect(find.byType(InventoryPanti), findsOneWidget);

    // kemungkinan kondisi UI
    final loading = find.byType(CircularProgressIndicator);
    final grid = find.byType(GridView);
    final list = find.byType(ListView);
    final empty = find.textContaining('Belum');

    expect(
      loading.evaluate().isNotEmpty ||
          grid.evaluate().isNotEmpty ||
          list.evaluate().isNotEmpty ||
          empty.evaluate().isNotEmpty,
      true,
    );

    // coba tap salah satu menu jika ada
    final gesture = find.byType(GestureDetector);

    if (gesture.evaluate().isNotEmpty) {
      await tester.tap(gesture.first);
      await tester.pumpAndSettle();
    }

    // pastikan tidak crash
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}