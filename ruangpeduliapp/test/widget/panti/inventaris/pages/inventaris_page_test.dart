// test/widget/panti/inventory_panti_test.dart
//
// Widget test for InventarisPanti covering:
// - Header (title, notification bell)
// - Stok section (Stok Masuk, Stok Keluar, Add button)
// - Anggota section (Pegawai, Penghuni cards)
// - Navigation to sub-screens
//
// No mock API needed — InventarisPanti uses null-safe userId/pantiId
// so API calls are skipped when null is passed

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti.dart';
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_notifikasi.dart';
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_stokmasuk.dart';
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_stokkeluar.dart';
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_anggota.dart';

// ─────────────────────────────────────────────────────────────
// Helper: build InventarisPanti inside a Scaffold + MaterialApp
// Pass null for userId and pantiId to skip all API calls
// ─────────────────────────────────────────────────────────────
Widget buildInventarisPanti({int? userId, int? pantiId}) {
  return MaterialApp(
    home: Scaffold(
      body: InventarisPanti(userId: userId, pantiId: pantiId),
    ),
  );
}

void main() {
  // ═══════════════════════════════════════════════════════════
  // GROUP 1: Header
  // ═══════════════════════════════════════════════════════════
  group('Header - InventarisPanti._buildHeader()', () {
    testWidgets(
      'TC-INV-01: "Inventaris" title is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        expect(find.text('Inventaris'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INV-02: Notification bell icon is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INV-03: Inventory icon is visible in header',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INV-04: Notification badge is NOT shown when lowStockCount is 0',
      (WidgetTester tester) async {
        // Pass null pantiId — skips _checkLowStock() API call
        // so _lowStockCount stays 0
        await tester.pumpWidget(buildInventarisPanti(pantiId: null));
        await tester.pump();

        // Badge only appears when _lowStockCount > 0
        expect(find.text('99+'), findsNothing);
      },
    );

    testWidgets(
      'TC-INV-05: Tapping notification bell navigates to InventarisNotifikasiScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.notifications_rounded));
        await tester.pumpAndSettle();

        expect(find.byType(InventarisNotifikasiScreen), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 2: Stok Section
  // ═══════════════════════════════════════════════════════════
  group('Stok Section - InventarisPanti._buildStokSection()', () {
    testWidgets(
      'TC-INV-06: "Stok" section title is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        expect(find.text('Stok'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INV-07: "Stok Masuk" card is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        expect(find.text('Stok Masuk'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INV-08: "Stok Keluar" card is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        expect(find.text('Stok Keluar'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INV-09: Add button (+) is visible in Stok section',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        expect(find.byIcon(Icons.add), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INV-10: Tapping "Stok Masuk" navigates to StokMasukScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        await tester.tap(find.text('Stok Masuk'));
        await tester.pumpAndSettle();

        expect(find.byType(StokMasukScreen), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INV-11: Tapping "Stok Keluar" navigates to StokKeluarScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        await tester.tap(find.text('Stok Keluar'));
        await tester.pumpAndSettle();

        expect(find.byType(StokKeluarScreen), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 3: Anggota Section
  // ═══════════════════════════════════════════════════════════
  group('Anggota Section - InventarisPanti._buildAnggotaSection()', () {
    testWidgets(
      'TC-INV-12: "Anggota" section title is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        expect(find.text('Anggota'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INV-13: "Pegawai" label is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        expect(find.text('Pegawai'), findsWidgets);
      },
    );

    testWidgets(
      'TC-INV-14: "Penghuni" label is visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        expect(find.text('Penghuni'), findsWidgets);
      },
    );

    testWidgets(
      'TC-INV-15: Pegawai count shows "—" when userId is null (no API call)',
      (WidgetTester tester) async {
        // Pass null userId — skips _fetchCounts() API call
        // so _pegawaiCount stays null and displays "—"
        await tester.pumpWidget(buildInventarisPanti(userId: null));
        await tester.pump();

        expect(find.text('—'), findsWidgets);
      },
    );

    testWidgets(
      'TC-INV-16: Tapping "Pegawai" card navigates to DaftarPegawaiScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        // Tap the Pegawai card (in the grid, not the summary row)
        await tester.tap(find.byIcon(Icons.work_rounded));
        await tester.pumpAndSettle();

        expect(find.byType(DaftarPegawaiScreen), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INV-17: Tapping "Penghuni" card navigates to DaftarPenghuniScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        await tester.tap(find.byIcon(Icons.groups_rounded));
        await tester.pumpAndSettle();

        expect(find.byType(DaftarPenghuniScreen), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 4: Layout structure
  // ═══════════════════════════════════════════════════════════
  group('Layout Structure - InventarisPanti.build()', () {
    testWidgets(
      'TC-INV-18: InventarisPanti renders without error',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        expect(find.byType(InventarisPanti), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INV-19: SingleChildScrollView is used as root layout',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      },
    );

    testWidgets(
      'TC-INV-20: Both Stok and Anggota sections are visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildInventarisPanti());
        await tester.pump();

        expect(find.text('Stok'), findsOneWidget);
        expect(find.text('Anggota'), findsOneWidget);
      },
    );
  });
}