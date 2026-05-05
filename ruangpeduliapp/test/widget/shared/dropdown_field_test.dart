import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/kebutuhan_tambah_panti.dart';

void main() {
  Future<void> pumpKebutuhanTambahPage(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: KebutuhanTambahPantiPage(
          pantiId: 1,
          userId: 1,
        ),
      ),
    );
  }

  group('DropdownField Widget', () {
    testWidgets(
      'TC-DF-01: dropdown satuan tampil dengan hint',
      (WidgetTester tester) async {
        await pumpKebutuhanTambahPage(tester);

        expect(find.text('Satuan'), findsOneWidget);
        expect(find.text('Pilih satuan yang digunakan'), findsOneWidget);
        expect(find.byType(DropdownButton<String>), findsOneWidget);
      },
    );

    testWidgets(
      'TC-DF-02: dropdown satuan dapat memilih item',
      (WidgetTester tester) async {
        await pumpKebutuhanTambahPage(tester);

        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Kg').last);
        await tester.pumpAndSettle();

        expect(find.text('Kg'), findsOneWidget);
        expect(find.text('Pilih satuan yang digunakan'), findsNothing);
      },
    );
  });
}
