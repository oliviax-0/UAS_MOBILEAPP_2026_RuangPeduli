import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/kebutuhan_tambah_panti.dart';

void main() {
  testWidgets('KebutuhanTambahPantiPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: KebutuhanTambahPantiPage(
          pantiId: 1,
          userId: 1,
        ),
      ),
    );

    expect(find.byType(KebutuhanTambahPantiPage), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}