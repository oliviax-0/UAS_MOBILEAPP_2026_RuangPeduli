import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


import 'package:ruangpeduliapp/masyarakat/home/home_masyarakat_screen.dart';

// ─── Helper ───────────────────────────────────────────────────────────────────

Future<void> pumpScreen(WidgetTester tester, {int? userId}) async {
  await tester.pumpWidget(
    MaterialApp(home: HomeMasyarakatScreen(userId: userId)),
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
    testWidgets('renders HomeMasyarakatScreen widget', (tester) async {
      await pumpScreen(tester);
      expect(find.byType(HomeMasyarakatScreen), findsOneWidget);
    });

    testWidgets('renders Scaffold with white background', (tester) async {
      await pumpScreen(tester);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.white);
    });

    testWidgets('renders RefreshIndicator', (tester) async {
      await pumpScreen(tester);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 2. Top bar
  // ══════════════════════════════════════════════════════════════════════════

  group('Top bar', () {
    testWidgets('shows search bar with "Search" hint text', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('shows microphone icon in search bar', (tester) async {
      await pumpScreen(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is Icon &&
            (w.icon == Icons.mic_none_rounded || w.icon == Icons.mic_rounded)),
        findsOneWidget,
      );
    });

    testWidgets('shows notification bell icon', (tester) async {
      await pumpScreen(tester);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });

    testWidgets('shows user avatar circle in top bar', (tester) async {
      await pumpScreen(tester);
      // Profile avatar renders ClipOval + person fallback icon
      expect(find.byIcon(Icons.person_rounded), findsWidgets);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 3. Section headers
  // ══════════════════════════════════════════════════════════════════════════

  group('Section headers', () {
    testWidgets('shows "Berita" section header', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Berita'), findsOneWidget);
    });

    testWidgets('shows "Video Terbaru" section header', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Video Terbaru'), findsOneWidget);
    });

    testWidgets('section headers have chevron_right icon', (tester) async {
      await pumpScreen(tester);
      expect(find.byIcon(Icons.chevron_right_rounded), findsWidgets);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 4. Loading state
  // ══════════════════════════════════════════════════════════════════════════

  group('Loading state', () {
    testWidgets('shows CircularProgressIndicator while data is loading',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: HomeMasyarakatScreen()),
      );
      // One frame only — APIs in flight, _isLoading = true
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 5. Empty state (APIs fail silently → empty lists)
  // ══════════════════════════════════════════════════════════════════════════

  group('Empty state', () {
    testWidgets('shows "Belum ada berita" when berita list is empty',
        (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Belum ada berita'), findsOneWidget);
    });

    testWidgets('shows "Belum ada video" when video list is empty',
        (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Belum ada video'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 6. Chatbot FAB
  // ══════════════════════════════════════════════════════════════════════════

  group('Chatbot FAB', () {
    testWidgets('shows chatbot FAB (chat_rounded fallback icon)', (tester) async {
      await pumpScreen(tester);
      // Image.asset for chatbot_ai.png will fail in tests → shows fallback icon
      expect(find.byIcon(Icons.chat_rounded), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 7. Bottom navigation bar
  // ══════════════════════════════════════════════════════════════════════════

  group('Bottom navigation bar', () {
    testWidgets('renders all 4 nav icons', (tester) async {
      await pumpScreen(tester);
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsWidgets);
    });

    testWidgets('home icon is selected by default (shows white dot)',
        (tester) async {
      await pumpScreen(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle &&
            (w.decoration as BoxDecoration).color == Colors.white),
        findsOneWidget,
      );
    });

    testWidgets('nav bar has navPink background color', (tester) async {
      await pumpScreen(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is Container && w.color == const Color(0xFFF47B8C)),
        findsWidgets,
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 8. userId prop
  // ══════════════════════════════════════════════════════════════════════════

  group('userId prop', () {
    testWidgets('renders correctly without userId', (tester) async {
      await pumpScreen(tester);
      expect(find.byType(HomeMasyarakatScreen), findsOneWidget);
    });

    testWidgets('renders correctly with userId', (tester) async {
      await pumpScreen(tester, userId: 7);
      expect(find.byType(HomeMasyarakatScreen), findsOneWidget);
    });
  });
}

