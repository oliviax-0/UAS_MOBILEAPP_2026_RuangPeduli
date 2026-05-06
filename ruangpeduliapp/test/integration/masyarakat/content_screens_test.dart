// integration_test/content_screens_test.dart
//
// Tests for content-related screens:
// BeritaDetailScreen, KebutuhanScreen, VideoPlayerScreen

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ruangpeduliapp/masyarakat/home/berita_detail_screen.dart';
import 'package:ruangpeduliapp/masyarakat/home/kebutuhan_screen.dart';
import 'package:ruangpeduliapp/data/content_api.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────
  //  BeritaDetailScreen
  // ─────────────────────────────────────────────
  group('BeritaDetailScreen', () {
    BeritaModel _makeBerita({
      String title = 'Panti Butuh Bantuan',
      String content = 'Isi berita yang panjang di sini.',
      String pantiName = 'Panti Asuhan Harapan',
      int? pantiId = 1,
      String? thumbnail,
      String? pantiProfilePicture,
    }) =>
        BeritaModel(
          title: title,
          content: content,
          pantiName: pantiName,
          pantiId: pantiId,
          thumbnail: thumbnail,
          pantiProfilePicture: pantiProfilePicture,
        );

    testWidgets('renders title, content, panti name', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BeritaDetailScreen(berita: _makeBerita(), userId: 1),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Panti Butuh Bantuan'), findsOneWidget);
      expect(find.text('Isi berita yang panjang di sini.'), findsOneWidget);
      expect(find.text('Panti Asuhan Harapan'), findsOneWidget);
    });

    testWidgets('shows placeholder thumbnail when no image URL', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BeritaDetailScreen(berita: _makeBerita(thumbnail: null)),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.image_rounded), findsOneWidget);
    });

    testWidgets('shows default panti icon when no profile picture', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BeritaDetailScreen(
          berita: _makeBerita(pantiProfilePicture: null),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.home_work_rounded), findsOneWidget);
    });

    testWidgets('"Lihat Profil" button visible when pantiId is set', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BeritaDetailScreen(berita: _makeBerita(pantiId: 5), userId: 1),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Lihat Profil'), findsOneWidget);
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('"Lihat Profil" button is disabled when pantiId is null',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BeritaDetailScreen(
          berita: _makeBerita(pantiId: null),
          userId: 1,
        ),
      ));
      await tester.pumpAndSettle();

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('back arrow pops the screen', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (ctx) {
            return ElevatedButton(
              onPressed: () => Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) =>
                      BeritaDetailScreen(berita: _makeBerita(), userId: 1),
                ),
              ),
              child: const Text('Open'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Panti Butuh Bantuan'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Panti Butuh Bantuan'), findsNothing);
    });

    testWidgets('AppBar label is "Berita"', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BeritaDetailScreen(berita: _makeBerita()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Berita'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────
  //  KebutuhanScreen
  // ─────────────────────────────────────────────
  group('KebutuhanScreen', () {
    Widget buildScreen({int? pantiId = 1}) => MaterialApp(
          home: KebutuhanScreen(
            pantiId: pantiId,
            namaPanti: 'Panti Asuhan Harapan',
            username: '@harapan',
            userId: 42,
          ),
        );

    testWidgets('renders screen title "Kebutuhan"', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump(); // don't settle – loading state shows first

      expect(find.text('Kebutuhan'), findsOneWidget);
    });

    testWidgets('shows panti name and username in header', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      expect(find.text('Panti Asuhan Harapan'), findsOneWidget);
      expect(find.text('@harapan'), findsOneWidget);
    });

    testWidgets('shows loading indicator while fetching', (tester) async {
      await tester.pumpWidget(buildScreen());
      // Pump one frame so the loader is visible before async completes
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when pantiId is null', (tester) async {
      await tester.pumpWidget(buildScreen(pantiId: null));
      await tester.pumpAndSettle();

      // When pantiId is null _load() returns immediately with empty list
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('back arrow pops screen', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (ctx) {
            return ElevatedButton(
              onPressed: () => Navigator.push(
                ctx,
                MaterialPageRoute(builder: (_) => buildScreen()),
              ),
              child: const Text('Open'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(KebutuhanScreen), findsNothing);
    });
  });
}
