import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/tambah_akun_panti.dart';

void main() {
  testWidgets('TambahAkunPanti render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TambahAkunPanti(),
      ),
    );

    expect(find.byType(TambahAkunPanti), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}