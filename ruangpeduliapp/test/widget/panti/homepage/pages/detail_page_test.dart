import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/masyarakat/home/berita_detail_screen.dart';
import 'package:ruangpeduliapp/data/content_api.dart';

void main() {
  testWidgets('BeritaDetailScreen render test', (WidgetTester tester) async {
    // Create mock berita
    final mockBerita = BeritaModel(
      id: 1,
      title: 'Test Berita',
      content: 'Isi berita test',
      thumbnail: null,
      authorName: 'Panti Test',
      pantiName: 'Panti Asuhan Test',
      pantiId: 1,
      pantiProfilePicture: null,
      createdAt: '2024-01-01',
      upvoteCount: 0,
      downvoteCount: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BeritaDetailScreen(
          berita: mockBerita,
          userId: 1,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(BeritaDetailScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Test Berita'), findsOneWidget);
  });
}