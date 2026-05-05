import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_panti.dart';

void main() {
  testWidgets('Dashboard flow basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: KeuanganPanti(
          userId: null,
          pantiId: null,
        ),
      ),
    );

    // Halaman tampil
    expect(find.byType(KeuanganPanti), findsOneWidget);

    await tester.pumpAndSettle();

    // Kondisi: loading / dashboard card
    final loading = find.byType(CircularProgressIndicator);
    final dashboard = find.text('Dasbor');

    expect(
      loading.evaluate().isNotEmpty ||
          dashboard.evaluate().isNotEmpty,
      true,
    );

    final toggleBtn = find.byIcon(Icons.visibility_outlined);

    if (toggleBtn.evaluate().isNotEmpty) {
      await tester.tap(toggleBtn.first);
      await tester.pump();
    }

    await tester.pumpAndSettle();

    expect(find.byType(KeuanganPanti), findsWidgets);
  });
}
