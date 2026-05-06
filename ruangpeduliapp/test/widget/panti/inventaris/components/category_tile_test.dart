import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ sesuaikan dengan file asli kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_stokmasuk.dart';

void main() {
  testWidgets('Category tile render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryTile(
            nama: 'Makanan',
            jumlah: 10,
            onTap: () {},
          ),
        ),
      ),
    );

    // widget tampil
    expect(find.byType(CategoryTile), findsOneWidget);

    // nama kategori tampil
    expect(find.text('Makanan'), findsOneWidget);

    // jumlah tampil
    expect(find.text('10 Jenis'), findsOneWidget);
  });
}
