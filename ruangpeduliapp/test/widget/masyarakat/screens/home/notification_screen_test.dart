import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ruangpeduliapp/masyarakat/notification/notification_screen.dart';

// ─── Helper ───────────────────────────────────────────────────────────────────

Future<void> pumpScreen(
  WidgetTester tester, {
  int? userId,
}) async {
  tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
  tester.binding.window.devicePixelRatioTestValue = 1.0;

  addTearDown(() {
    tester.binding.window.clearPhysicalSizeTestValue();
    tester.binding.window.clearDevicePixelRatioTestValue();
  });

  await tester.pumpWidget(
    MaterialApp(
      home: NotificationScreen(userId: userId),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

// ─── main ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 1. Rendering
  // ══════════════════════════════════════════════════════════════════════════

  group('Rendering', () {
    testWidgets('renders NotificationScreen widget', (tester) async {
      await pumpScreen(tester);
      expect(find.byType(NotificationScreen), findsOneWidget);
    });

    testWidgets('shows "Notifikasi" title in header', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Notifikasi'), findsOneWidget);
    });

    testWidgets('shows back arrow button (arrow_back_rounded)', (tester) async {
      await pumpScreen(tester);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('renders Scaffold with white background', (tester) async {
      await pumpScreen(tester);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.white);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 2. Loading state
  // ══════════════════════════════════════════════════════════════════════════

  group('Loading state', () {
    testWidgets('shows CircularProgressIndicator while loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: NotificationScreen(userId: 1)),
      );
      await tester.pump();
      // First frame - APIs loading, _loading = true
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 3. Anonymous state (userId == nulll)
  // ══════════════════════════════════════════════════════════════════════════

  group('Anonymous state', () {
    testWidgets(
        'shows welcome message when userId is null',
        (tester) async {
      await pumpScreen(tester); // userId == null
      await tester.pump(const Duration(milliseconds: 500));
      // Should show welcome notification
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows welcome notification with heart icon', (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('shows welcome message text', (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Selamat bergabung! Terima kasih sudah peduli sesama 💛'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 4. Notification items display
  // ══════════════════════════════════════════════════════════════════════════

  group('Notification items', () {
    testWidgets('renders NotifCard items in ListView', (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(milliseconds: 500));
      // Welcome notification should appear
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('notification card has pink background color', (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.byWidgetPredicate((w) =>
            w is Container && w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == const Color(0xFFFFF0F2)),
        findsOneWidget,
      );
    });

    testWidgets('notification card has rounded corners', (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.byWidgetPredicate((w) =>
            w is Container && w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).borderRadius == BorderRadius.circular(14)),
        findsOneWidget,
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 5. Error state
  // ══════════════════════════════════════════════════════════════════════════

  group('Error state', () {
    testWidgets('shows error icon when API fails', (tester) async {
      await pumpScreen(tester, userId: 999); // Invalid user ID
      await tester.pump(const Duration(seconds: 2));
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('shows error message text', (tester) async {
      await pumpScreen(tester, userId: 999);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Gagal memuat notifikasi'), findsOneWidget);
    });

    testWidgets('shows "Coba lagi" button when error occurs', (tester) async {
      await pumpScreen(tester, userId: 999);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Coba lagi'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 6. Bottom navigation bar
  // ══════════════════════════════════════════════════════════════════════════

  group('Bottom navigation bar', () {
    testWidgets('renders all 4 nav icons', (tester) async {
      await pumpScreen(tester);
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsWidgets);
    });

    testWidgets('nav bar has navPink background color', (tester) async {
      await pumpScreen(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == const Color(0xFFF47B8C)),
        findsOneWidget,
      );
    });

    testWidgets('nav bar has shadow effect', (tester) async {
      await pumpScreen(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).boxShadow != null),
        findsOneWidget,
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 7. Back button functionality
  // ══════════════════════════════════════════════════════════════════════════

  group('Back button', () {
    testWidgets('back button appears in header', (tester) async {
      await pumpScreen(tester);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('tapping back button pops the route', (tester) async {
      bool popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => const NotificationScreen(),
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
  // 8. userId prop
  // ══════════════════════════════════════════════════════════════════════════

  group('userId prop', () {
    testWidgets('renders correctly without userId', (tester) async {
      await pumpScreen(tester);
      expect(find.byType(NotificationScreen), findsOneWidget);
    });

    testWidgets('renders correctly with userId', (tester) async {
      await pumpScreen(tester, userId: 5);
      expect(find.byType(NotificationScreen), findsOneWidget);
    });
  });
}