import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ✅ sesuaikan dengan file asli kamu
import 'package:ruangpeduliapp/panti/inventory_panti/inventory_panti_produkbaru.dart';

void main() {
  testWidgets('Dropdown widget render & select test',
      (WidgetTester tester) async {

    String selected = 'Makanan';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                value: selected,
                items: const [
                  DropdownMenuItem(
                    value: 'Makanan',
                    child: Text('Makanan'),
                  ),
                  DropdownMenuItem(
                    value: 'Minuman',
                    child: Text('Minuman'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selected = value!;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    // dropdown tampil
    expect(find.byType(DropdownButton<String>), findsOneWidget);

    // buka dropdown
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    // pilih item
    await tester.tap(find.text('Minuman').last);
    await tester.pumpAndSettle();

    // selected berubah
    expect(find.text('Minuman'), findsWidgets);
  });
}