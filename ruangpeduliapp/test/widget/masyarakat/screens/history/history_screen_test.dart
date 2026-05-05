import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ruangpeduliapp/masyarakat/history/riwayat_donasi_screen.dart';

// ─── Helper ───────────────────────────────────────────────────────────────────

Future<void> pumpScreen(
  WidgetTester tester, {
  int? userId,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: RiwayatDonasiScreen(userId: userId),
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
    testWidgets('renders RiwayatDonasiScreen widget', (tester) async {
      await pumpScreen(tester);
      expect(find.byType(RiwayatDonasiScreen), findsOneWidget);
    });

    testWidgets('shows "Riwayat Donasi" title in header', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Riwayat Donasi'), findsOneWidget);
    });

    testWidgets('header has pink background color', (tester) async {
      await pumpScreen(tester);
      final container = tester.widgetList<Container>(find.byType(Container))
          .firstWhere(
            (c) => c.color == const Color(0xFFF1BFB4),
            orElse: () => Container(),
          );
      expect(container.color, const Color(0xFFF1BFB4));
    });

    testWidgets('shows Scaffold with white background', (tester) async {
      await pumpScreen(tester);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.white);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 2. Loading state
  // ══════════════════════════════════════════════════════════════════════════

  group('Loading state', () {
    testWidgets('shows CircularProgressIndicator while loading with userId',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: RiwayatDonasiScreen(userId: 1)),
      );
      // Pump just one frame — API call is in-flight, _isLoading is true
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CircularProgressIndicator has correct pink color',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: RiwayatDonasiScreen(userId: 1)),
      );
      await tester.pump();
      final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator));
      expect(indicator.color, const Color(0xFFF47B8C));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 3. Empty state — no userId (anonymous)
  // ══════════════════════════════════════════════════════════════════════════

  group('Empty state (no userId)', () {
    testWidgets('shows history icon when no donations exist', (tester) async {
      await pumpScreen(tester); // userId == null → skips API → empty list
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.history_rounded), findsWidgets);
    });

    testWidgets('shows "Belum ada riwayat donasi" text when list is empty',
        (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Belum ada riwayat donasi'), findsOneWidget);
    });

    testWidgets('does NOT show ListView when list is empty', (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ListView), findsNothing);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 4. Filter button
  // ══════════════════════════════════════════════════════════════════════════

  group('Filter button', () {
    testWidgets('shows "Filter" button', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Filter'), findsOneWidget);
    });

    testWidgets('shows filter_list icon next to Filter button', (tester) async {
      await pumpScreen(tester);
      expect(find.byIcon(Icons.filter_list_rounded), findsOneWidget);
    });

    testWidgets('tapping Filter button opens bottom sheet', (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      // Bottom sheet shows "Pilih Tanggal" title
      expect(find.text('Pilih Tanggal'), findsOneWidget);
    });

    testWidgets('filter bottom sheet shows "Terapkan Filter" button',
        (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(find.text('Terapkan Filter'), findsOneWidget);
    });

    testWidgets('filter bottom sheet shows calendar icon', (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
    });

    testWidgets('tapping "Terapkan Filter" closes the bottom sheet',
        (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Terapkan Filter'));
      await tester.pumpAndSettle();

      // Bottom sheet dismissed → "Pilih Tanggal" no longer visible
      expect(find.text('Pilih Tanggal'), findsNothing);
    });

    testWidgets('active filter chip appears after applying a filter',
        (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Terapkan Filter'));
      await tester.pumpAndSettle();

      // A date label chip + close icon should now be visible
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('tapping close on active filter chip clears the filter',
        (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));

      // Apply filter first
      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terapkan Filter'));
      await tester.pumpAndSettle();

      // Now clear it
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Chip should be gone
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets(
        'shows "Tidak ada riwayat pada tanggal ini" when filter yields no results',
        (tester) async {
      await pumpScreen(tester); // empty list
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terapkan Filter'));
      await tester.pumpAndSettle();

      expect(
        find.text('Tidak ada riwayat pada tanggal ini'),
        findsOneWidget,
      );
    });

    testWidgets('"Lihat semua riwayat" link appears when filter active and empty',
        (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terapkan Filter'));
      await tester.pumpAndSettle();

      expect(find.text('Lihat semua riwayat'), findsOneWidget);
    });

    testWidgets(
        'tapping "Lihat semua riwayat" clears the filter and shows empty-state',
        (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terapkan Filter'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lihat semua riwayat'));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada riwayat donasi'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 5. Inline calendar (inside filter sheet)
  // ══════════════════════════════════════════════════════════════════════════

  group('Inline calendar', () {
    testWidgets('calendar shows previous-month chevron', (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    });

    testWidgets('calendar shows next-month chevron', (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('calendar shows month and year dropdown buttons', (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      // Both dropdowns show a keyboard_arrow_down icon
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsWidgets);
    });

    testWidgets('tapping next-month chevron advances the month', (tester) async {
      await pumpScreen(tester);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      // Read current month label
      final now = DateTime.now();
      const monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final nextMonthName =
          monthNames[(now.month % 12)]; // next month, 0-indexed

      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();

      expect(find.text(nextMonthName), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 6. Bottom navigation bar
  // ══════════════════════════════════════════════════════════════════════════

  group('Bottom navigation bar', () {
    testWidgets('renders bottom navigation bar', (tester) async {
      await pumpScreen(tester);
      // NavBar is a plain Container — verify via its icons
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('history icon is shown as selected (has dot indicator)',
        (tester) async {
      await pumpScreen(tester);
      // The selected _NavItem renders a small white dot Container below the icon.
      // history_rounded appears in both the empty-state icon and the nav bar,
      // so we verify the dot exists (selected state in _NavItem).
      expect(
        find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle &&
            (w.decoration as BoxDecoration).color == Colors.white),
        findsOneWidget,
      );
    });

    testWidgets('nav bar background is navPink color', (tester) async {
      await pumpScreen(tester);
      expect(
        find.byWidgetPredicate((w) =>
            w is Container &&
            w.color == const Color(0xFFF47B8C)),
        findsWidgets,
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 7. userId prop
  // ══════════════════════════════════════════════════════════════════════════

  group('userId prop', () {
    testWidgets('renders correctly without userId', (tester) async {
      await pumpScreen(tester);
      expect(find.byType(RiwayatDonasiScreen), findsOneWidget);
    });

    testWidgets('renders correctly with userId provided', (tester) async {
      await pumpScreen(tester, userId: 99);
      expect(find.byType(RiwayatDonasiScreen), findsOneWidget);
    });

    testWidgets('skips loading state when userId is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: RiwayatDonasiScreen()),
      );
      await tester.pump();
      // No loading indicator because _loadData() returns early
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}