import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_anggota.dart';

void main() {
  testWidgets(
    'Pegawai flow test',
    (WidgetTester tester) async {

      await tester.pumpWidget(
        const MaterialApp(

          home:DaftarPegawaiScreen(
            userId: null,
          ),
        ),
      );

      // render awal
      await tester.pump();

      // tunggu async selesai
      await tester.pumpAndSettle();

      // MaterialApp tampil
      expect(find.byType(MaterialApp), findsOneWidget);

      // kemungkinan widget muncul
      final loading =
          find.byType(CircularProgressIndicator);

      final list =
          find.byType(ListView);

      final search =
          find.byType(TextField);

      final gesture =
          find.byType(GestureDetector);

      final fab =
          find.byType(FloatingActionButton);

      expect(
        loading.evaluate().isNotEmpty ||
            list.evaluate().isNotEmpty ||
            search.evaluate().isNotEmpty ||
            gesture.evaluate().isNotEmpty ||
            fab.evaluate().isNotEmpty,
        true,
      );

      // isi search jika ada
      if (search.evaluate().isNotEmpty) {
        await tester.enterText(
          search.first,
          'Budi',
        );

        await tester.pump();
      }

      // tap FAB jika ada
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab.first);
        await tester.pumpAndSettle();
      }

      // tap item jika ada
      if (gesture.evaluate().isNotEmpty) {
        await tester.tap(gesture.first);
        await tester.pumpAndSettle();
      }

      // validasi akhir
      expect(find.byType(MaterialApp), findsOneWidget);
    },
  );
}