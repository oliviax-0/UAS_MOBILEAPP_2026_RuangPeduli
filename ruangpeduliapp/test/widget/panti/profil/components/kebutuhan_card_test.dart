import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/kebutuhan_panti.dart';

void main() {
  testWidgets('KebutuhanPantiPage card render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: KebutuhanPantiPage(
          pantiId: 1,
          userId: 1,
        ),
      ),
    );

    // Cek salah satu kondisi (loading atau empty)
    final loadingFinder = find.byType(CircularProgressIndicator);
    final emptyFinder = find.text('Belum ada kebutuhan');

    expect(
      loadingFinder.evaluate().isNotEmpty || emptyFinder.evaluate().isNotEmpty,
      true,
    );
  });
}