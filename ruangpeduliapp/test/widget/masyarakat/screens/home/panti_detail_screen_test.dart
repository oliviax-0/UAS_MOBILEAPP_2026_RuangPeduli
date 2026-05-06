import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ruangpeduliapp/masyarakat/home/panti_detail_screen.dart';

// ─── Helper ───────────────────────────────────────────────────────────────────

Future<void> pumpScreen(
  WidgetTester tester, {
  int? pantiId,
  String namaPanti = 'Panti Test',
  String username = '@pantitest',
  String nomorPanti = '0812345678',
  String alamatPanti = 'Jl. Test No. 1',
  String description = 'Deskripsi panti test.',
  String? profilePicture,
  String terkumpul = 'Rp0',
  int? userId,
  bool isPantiViewer = false,
  List<String> mediaUrls = const [],
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: PantiDetailScreen(
        pantiId: pantiId,
        namaPanti: namaPanti,
        username: username,
        nomorPanti: nomorPanti,
        alamatPanti: alamatPanti,
        description: description,
        profilePicture: profilePicture,
        terkumpul: terkumpul,
        userId: userId,
        isPantiViewer: isPantiViewer,
        mediaUrls: mediaUrls,
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
    testWidgets('renders PantiDetailScreen widget', (tester) async {
      await pumpScreen(tester);
      expect(find.byType(PantiDetailScreen), findsOneWidget);
    });

    testWidgets('renders Scaffold with white background', (tester) async {
      await pumpScreen(tester);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.white);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 2. App bar
  // ══════════════════════════════════════════════════════════════════════════

  group('App bar', () {
    testWidgets('shows "Profil" title', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('shows back arrow icon', (tester) async {
      await pumpScreen(tester);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('back arrow pops the route', (tester) async {
      bool popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => PantiDetailScreen(
                      namaPanti: 'P',
                      username: '@p',
                      nomorPanti: '0',
                      alamatPanti: 'A',
                      description: 'D',
                      terkumpul: 'Rp0',
                    ),
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

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 3. Panti profile info
  // ══════════════════════════════════════════════════════════════════════════

  group('Panti profile info', () {
    testWidgets('displays panti name', (tester) async {
      await pumpScreen(tester, namaPanti: 'Panti Harapan Bangsa');
      expect(find.text('Panti Harapan Bangsa'), findsOneWidget);
    });

    testWidgets('displays username', (tester) async {
      await pumpScreen(tester, username: '@pantiharapan');
      expect(find.text('@pantiharapan'), findsOneWidget);
    });

    testWidgets('displays nomor panti', (tester) async {
      await pumpScreen(tester, nomorPanti: '081299998888');
      expect(find.text('081299998888'), findsOneWidget);
    });

    testWidgets('displays alamat panti', (tester) async {
      await pumpScreen(tester, alamatPanti: 'Jl. Merdeka No. 5, Jakarta');
      expect(find.text('Jl. Merdeka No. 5, Jakarta'), findsOneWidget);
    });

    testWidgets('displays deskripsi panti', (tester) async {
      await pumpScreen(tester, description: 'Panti asuhan untuk anak yatim.');
      expect(find.text('Panti asuhan untuk anak yatim.'), findsOneWidget);
    });

    testWidgets('shows "Belum ada deskripsi." when description is empty',
        (tester) async {
      await pumpScreen(tester, description: '');
      expect(find.text('Belum ada deskripsi.'), findsOneWidget);
    });

    testWidgets('shows avatar fallback when no profile picture', (tester) async {
      await pumpScreen(tester, profilePicture: null);
      expect(find.byIcon(Icons.business_rounded), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 4. Section labels
  // ══════════════════════════════════════════════════════════════════════════

  group('Section labels', () {
    testWidgets('shows "Alamat" section label', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Alamat'), findsOneWidget);
    });

    testWidgets('shows "Foto" section label', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Foto'), findsOneWidget);
    });

    testWidgets('shows "Deskripsi" section label', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Deskripsi'), findsOneWidget);
    });

    testWidgets('shows "Postingan" section label', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Postingan'), findsOneWidget);
    });

    testWidgets('shows "Video" section label', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Video'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 5. Action buttons
  // ══════════════════════════════════════════════════════════════════════════

  group('Action buttons', () {
    testWidgets('shows "Kebutuhan" button', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Kebutuhan'), findsOneWidget);
    });

    testWidgets('shows "Donasi" button when isPantiViewer is false',
        (tester) async {
      await pumpScreen(tester, isPantiViewer: false);
      expect(find.text('Donasi'), findsOneWidget);
    });

    testWidgets('does NOT show "Donasi" button when isPantiViewer is true',
        (tester) async {
      await pumpScreen(tester, isPantiViewer: true);
      expect(find.text('Donasi'), findsNothing);
    });

    testWidgets('"Kebutuhan" button navigates to KebutuhanScreen',
        (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Kebutuhan'));
      await tester.pumpAndSettle();

      expect(find.text('Kebutuhan'), findsWidgets); // KebutuhanScreen title
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 6. Loading state (empty sections while _loading=true)
  // ══════════════════════════════════════════════════════════════════════════

  group('Loading state', () {
    testWidgets('shows CircularProgressIndicator while content is loading',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PantiDetailScreen(
            pantiId: 1,
            namaPanti: 'P',
            username: '@p',
            nomorPanti: '0',
            alamatPanti: 'A',
            description: 'D',
            terkumpul: 'Rp0',
          ),
        ),
      );
      await tester.pump(); // one frame — APIs in flight
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 7. Empty content sections (pantiId null → APIs skipped)
  // ══════════════════════════════════════════════════════════════════════════

  group('Empty content sections', () {
    testWidgets('shows "Belum ada foto." when fotos is empty', (tester) async {
      await pumpScreen(tester); // pantiId null → no fetch
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Belum ada foto.'), findsOneWidget);
    });

    testWidgets('shows "Belum ada postingan." when beritas is empty',
        (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Belum ada postingan.'), findsOneWidget);
    });

    testWidgets('shows "Belum ada video." when videos is empty', (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Belum ada video.'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 8. Props
  // ══════════════════════════════════════════════════════════════════════════

  group('Props', () {
    testWidgets('renders without pantiId', (tester) async {
      await pumpScreen(tester);
      expect(find.byType(PantiDetailScreen), findsOneWidget);
    });

    testWidgets('renders with pantiId', (tester) async {
      await pumpScreen(tester, pantiId: 5);
      expect(find.byType(PantiDetailScreen), findsOneWidget);
    });

    testWidgets('renders with userId', (tester) async {
      await pumpScreen(tester, userId: 99);
      expect(find.byType(PantiDetailScreen), findsOneWidget);
    });
  });
}