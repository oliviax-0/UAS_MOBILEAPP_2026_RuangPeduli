import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ sesuaikan dengan class asli project kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_notifikasi.dart';

void main() {
  testWidgets('Notif flow test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: InventoryPantiNotifikasi(),
      ),
    );

    // render awal
    await tester.pump();

    // tunggu async selesai
    await tester.pumpAndSettle();

    // halaman tampil
    expect(find.byType(InventoryPantiNotifikasi), findsOneWidget);

    // kemungkinan UI
    final loading = find.byType(CircularProgressIndicator);
    final list = find.byType(ListView);
    final refresh = find.byIcon(Icons.refresh);
    final empty = find.textContaining('Belum');

    expect(
      loading.evaluate().isNotEmpty ||
          list.evaluate().isNotEmpty ||
          refresh.evaluate().isNotEmpty ||
          empty.evaluate().isNotEmpty,
      true,
    );

    // tap refresh jika ada
    if (refresh.evaluate().isNotEmpty) {
      await tester.tap(refresh.first);
      await tester.pumpAndSettle();
    }

    // tap item notif jika ada
    final gesture = find.byType(GestureDetector);

    if (gesture.evaluate().isNotEmpty) {
      await tester.tap(gesture.first);
      await tester.pumpAndSettle();
    }

    // pastikan tidak crash
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}