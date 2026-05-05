import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/keuangan_panti/keuangan_plus.dart';

void main() {
  testWidgets('Tab switch render & tap test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InputTransaksiPage(
          userId: 1,
          pantiId: 1,
        ),
      ),
    );

    expect(find.text('Pemasukan'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);

    await tester.tap(find.text('Pengeluaran'));
    await tester.pumpAndSettle();

    expect(find.byType(InputTransaksiPage), findsOneWidget);
  });
}
