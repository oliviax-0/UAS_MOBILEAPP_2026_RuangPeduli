import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ruangpeduliapp/data/content_api.dart';
import 'package:ruangpeduliapp/masyarakat/home/berita_detail_screen.dart';

// ─── Fake BeritaModel ─────────────────────────────────────────────────────────
// BeritaModel is a data class from content_api.dart.
// We construct a minimal instance with the fields BeritaDetailScreen uses:
//   title, content, pantiName, pantiId, thumbnail, pantiProfilePicture

BeritaModel _fakeBerita({
  String title = 'Judul Berita Test',
  String content = 'Isi berita yang panjang untuk pengujian.',
  String pantiName = 'Panti Test',
  int? pantiId = 1,
  String? thumbnail,
  String? pantiProfilePicture,
  int id = 1,
  String authorName = 'Author Test',
  String createdAt = '2024-01-01T00:00:00Z',
  int upvoteCount = 0,
  int downvoteCount = 0,
}) {
  return BeritaModel(
    id: id,
    title: title,
    content: content,
    thumbnail: thumbnail,
    authorName: authorName,
    pantiName: pantiName,
    pantiId: pantiId,
    pantiProfilePicture: pantiProfilePicture,
    createdAt: createdAt,
    upvoteCount: upvoteCount,
    downvoteCount: downvoteCount,
  );
}

// ─── Helper ───────────────────────────────────────────────────────────────────

Future<void> pumpScreen(
  WidgetTester tester, {
  BeritaModel? berita,
  int? userId,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BeritaDetailScreen(
        berita: berita ?? _fakeBerita(),
        userId: userId,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ══════════════════════════════════════════════════════════════════════════
  // 1. Rendering
  // ══════════════════════════════════════════════════════════════════════════

  group('Rendering', () {
    testWidgets('renders BeritaDetailScreen widget', (tester) async {
      await pumpScreen(tester);
      expect(find.byType(BeritaDetailScreen), findsOneWidget);
    });

    testWidgets('renders Scaffold with white background', (tester) async {
      await pumpScreen(tester);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.white);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 2. AppBar
  // ══════════════════════════════════════════════════════════════════════════

  group('AppBar', () {
    testWidgets('shows "Berita" as AppBar title', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Berita'), findsOneWidget);
    });

    testWidgets('shows back button (arrow_back_rounded)', (tester) async {
      await pumpScreen(tester);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('back button pops the route', (tester) async {
      bool popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) =>
                        BeritaDetailScreen(berita: _fakeBerita()),
                  ),
                );
                popped = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 3. Berita content
  // ══════════════════════════════════════════════════════════════════════════

  group('Berita content', () {
    testWidgets('displays berita title', (tester) async {
      await pumpScreen(tester, berita: _fakeBerita(title: 'Judul Unik'));
      expect(find.text('Judul Unik'), findsOneWidget);
    });

    testWidgets('displays berita body content', (tester) async {
      await pumpScreen(
          tester, berita: _fakeBerita(content: 'Isi konten berita ini.'));
      expect(find.text('Isi konten berita ini.'), findsOneWidget);
    });

    testWidgets('displays panti name', (tester) async {
      await pumpScreen(tester, berita: _fakeBerita(pantiName: 'Panti Harapan'));
      expect(find.text('Panti Harapan'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 4. Thumbnail
  // ══════════════════════════════════════════════════════════════════════════

  group('Thumbnail', () {
    testWidgets('shows placeholder image icon when thumbnail is null',
        (tester) async {
      await pumpScreen(tester, berita: _fakeBerita(thumbnail: null));
      expect(find.byIcon(Icons.image_rounded), findsOneWidget);
    });

    testWidgets('shows placeholder when thumbnail is empty string',
        (tester) async {
      await pumpScreen(tester, berita: _fakeBerita(thumbnail: ''));
      expect(find.byIcon(Icons.image_rounded), findsOneWidget);
    });

    testWidgets('placeholder thumbnail container has correct color',
        (tester) async {
      await pumpScreen(tester, berita: _fakeBerita(thumbnail: null));
      expect(
        find.byWidgetPredicate((w) =>
            w is Container && w.color == const Color(0xFFCFBFC2)),
        findsOneWidget,
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 5. Panti avatar
  // ══════════════════════════════════════════════════════════════════════════

  group('Panti avatar', () {
    testWidgets(
        'shows home_work_rounded icon as avatar fallback when no profile picture',
        (tester) async {
      await pumpScreen(
          tester, berita: _fakeBerita(pantiProfilePicture: null));
      expect(find.byIcon(Icons.home_work_rounded), findsOneWidget);
    });

    testWidgets('panti avatar fallback has correct red-pink color',
        (tester) async {
      await pumpScreen(
          tester, berita: _fakeBerita(pantiProfilePicture: null));
      final icon = tester.widget<Icon>(find.byIcon(Icons.home_work_rounded));
      expect(icon.color, const Color(0xFFF43D5E));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 6. "Lihat Profil" button
  // ══════════════════════════════════════════════════════════════════════════

  group('"Lihat Profil" button', () {
    testWidgets('shows "Lihat Profil" button when pantiId is set',
        (tester) async {
      await pumpScreen(tester, berita: _fakeBerita(pantiId: 1));
      expect(find.text('Lihat Profil'), findsOneWidget);
    });

    testWidgets('"Lihat Profil" button is disabled when pantiId is null',
        (tester) async {
      await pumpScreen(tester, berita: _fakeBerita(pantiId: null));
      final btn = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Lihat Profil'));
      expect(btn.onPressed, isNull);
    });

    testWidgets('"Lihat Profil" button shows loading indicator when tapped',
        (tester) async {
      await pumpScreen(tester, berita: _fakeBerita(pantiId: 1));
      await tester.tap(find.text('Lihat Profil'));
      await tester.pump(); // one frame — _loadingProfile becomes true
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'shows SnackBar "Gagal memuat profil panti" when API fails',
        (tester) async {
      await pumpScreen(tester, berita: _fakeBerita(pantiId: 999));
      await tester.tap(find.text('Lihat Profil'));
      // Wait for the API call to fail
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(find.text('Gagal memuat profil panti'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 7. userId prop
  // ══════════════════════════════════════════════════════════════════════════

  group('userId prop', () {
    testWidgets('renders correctly without userId', (tester) async {
      await pumpScreen(tester);
      expect(find.byType(BeritaDetailScreen), findsOneWidget);
    });

    testWidgets('renders correctly with userId', (tester) async {
      await pumpScreen(tester, userId: 42);
      expect(find.byType(BeritaDetailScreen), findsOneWidget);
    });
  });
}