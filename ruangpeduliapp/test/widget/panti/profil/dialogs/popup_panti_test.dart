import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/popup_panti.dart';

void main() {
  testWidgets('showAlamatPopup dialog test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showAlamatPopup(
                  context,
                  pantiId: 1,
                  initialValue: 'Test Alamat',
                ),
                child: const Text('Show Popup'),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Show Popup'), findsOneWidget);
    await tester.tap(find.text('Show Popup'));
    await tester.pumpAndSettle();

    // Dialog harus tampil
    expect(find.text('Alamat'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });
}