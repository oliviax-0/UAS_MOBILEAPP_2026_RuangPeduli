import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_berita_panti.dart';

void main() {
  testWidgets('Detail flow basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BeritaDetailPanti(
          beritaId: 1,
          userId: null,
          pantiId: 1,
          title: 'Judul Test',
          thumbnail: null,
          date: '2026-05-05',
          authorName: 'Author Test',
          pantiName: 'Panti Test',
          body: 'Isi berita test',
          upvoteCount: 0,
          downvoteCount: 0,
        ),
      ),
    );

    // Halaman tampil
    expect(find.byType(BeritaDetailPanti), findsOneWidget);

    await tester.pumpAndSettle();

    // Kondisi: loading atau content
    final loading = find.byType(CircularProgressIndicator);
    final content = find.byType(SingleChildScrollView);

    expect(
      loading.evaluate().isNotEmpty ||
          content.evaluate().isNotEmpty,
      true,
    );

    // Coba tap vote jika ada
    final voteBtn = find.byIcon(Icons.arrow_upward_outlined);

    if (voteBtn.evaluate().isNotEmpty) {
      await tester.tap(voteBtn.first);
      await tester.pump();
    }

    // Coba tap author jika ada
    final authorTap = find.byType(GestureDetector);

    if (authorTap.evaluate().isNotEmpty) {
      await tester.tap(authorTap.first);
      await tester.pump();
    }

    // Pastikan tidak crash
    expect(find.byType(BeritaDetailPanti), findsWidgets);
  });
}
