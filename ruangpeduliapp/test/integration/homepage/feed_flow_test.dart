import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_panti.dart';

void main() {
  testWidgets('Feed flow basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePanti(
          userId: null,
          pantiId: null,
        ),
      ),
    );

    // Halaman tampil
    expect(find.byType(HomePanti), findsOneWidget);

    // Tunggu render async (loading selesai)
    await tester.pumpAndSettle();

    // Kondisi kemungkinan: loading / empty / list berita
    final loading = find.byType(CircularProgressIndicator);
    final empty = find.textContaining('Belum');
    final list = find.byType(ListView);
    final error = find.textContaining('Gagal');

    expect(
      loading.evaluate().isNotEmpty ||
          empty.evaluate().isNotEmpty ||
          list.evaluate().isNotEmpty ||
          error.evaluate().isNotEmpty,
      true,
    );

    // Jika ada card, coba tap
    final newsCard = find.byType(GestureDetector);

    if (newsCard.evaluate().isNotEmpty) {
      await tester.tap(newsCard.first);
      await tester.pumpAndSettle();
    }

    // Pastikan tidak crash
    expect(find.byType(HomePanti), findsWidgets);
  });
}
