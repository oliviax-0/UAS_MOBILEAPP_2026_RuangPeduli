// integration_test/utility_screens_test.dart
//
// Tests for utility / navigation screens:
// NotificationScreen, LokasiScreen, TransaksiSuksesScreen (edge cases)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ruangpeduliapp/masyarakat/notification/notification_screen.dart';
import 'package:ruangpeduliapp/masyarakat/transaksi/lokasi_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────
  //  NotificationScreen
  // ─────────────────────────────────────────────
  group('NotificationScreen', () {
    Widget buildScreen({int? userId}) => MaterialApp(
          home: NotificationScreen(userId: userId),
        );

    testWidgets('renders title "Notifikasi"', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      expect(find.text('Notifikasi'), findsOneWidget);
    });

    testWidgets('shows welcome notification when userId is null', (tester) async {
      await tester.pumpWidget(buildScreen(userId: null));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Selamat bergabung'),
        findsOneWidget,
      );
    });

    testWidgets('bottom nav bar is visible', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      // Nav bar has 4 icons
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('back arrow pops screen', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (ctx) {
            return ElevatedButton(
              onPressed: () => Navigator.push(
                ctx,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ),
              child: const Text('Open'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Notifikasi'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationScreen), findsNothing);
    });

    testWidgets('shows loading indicator while fetching', (tester) async {
      // Provide a userId so it actually tries to fetch
      await tester.pumpWidget(buildScreen(userId: 99));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────
  //  LokasiScreen
  // ─────────────────────────────────────────────
  group('LokasiScreen', () {
    Widget buildScreen({double? distanceMeters}) => MaterialApp(
          home: LokasiScreen(
            namaPanti: 'Panti Asuhan Harapan',
            alamat: 'Jl. Merdeka No. 1, Jakarta',
            lat: -6.2,
            lng: 106.816,
            distanceMeters: distanceMeters,
          ),
        );

    testWidgets('renders screen title "Lokasi"', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Lokasi'), findsOneWidget);
    });

    testWidgets('renders panti name and address', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Panti Asuhan Harapan'), findsOneWidget);
      expect(find.text('Jl. Merdeka No. 1, Jakarta'), findsOneWidget);
    });

    testWidgets('shows "Jarak tidak tersedia" when distanceMeters is null',
        (tester) async {
      await tester.pumpWidget(buildScreen(distanceMeters: null));
      await tester.pumpAndSettle();

      expect(find.text('Jarak tidak tersedia'), findsOneWidget);
    });

    testWidgets('formats distance in meters when < 1 km', (tester) async {
      await tester.pumpWidget(buildScreen(distanceMeters: 750));
      await tester.pumpAndSettle();

      expect(find.textContaining('750 m'), findsOneWidget);
    });

    testWidgets('formats distance in km when >= 1 km', (tester) async {
      await tester.pumpWidget(buildScreen(distanceMeters: 2500));
      await tester.pumpAndSettle();

      expect(find.textContaining('2.5 km'), findsOneWidget);
    });

    testWidgets('renders map placeholder (CustomPaint)', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('"Buka di Google Maps" button is present', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Buka di Google Maps'), findsOneWidget);
    });

    testWidgets('back arrow pops screen', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (ctx) {
            return ElevatedButton(
              onPressed: () => Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => LokasiScreen(
                    namaPanti: 'Panti',
                    alamat: 'Jl. Test',
                    lat: -6.2,
                    lng: 106.8,
                  ),
                ),
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

      expect(find.byType(LokasiScreen), findsNothing);
    });

    testWidgets('bottom nav bar renders', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });
  });
}
