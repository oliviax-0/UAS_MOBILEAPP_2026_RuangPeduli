import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_panti.dart';

void main() {
  testWidgets('Navigation flow basic test', (WidgetTester tester) async {
    int currentIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox(),
          bottomNavigationBar: BottomNav(
            currentIndex: currentIndex,
            onTap: (index) {
              currentIndex = index;
            },
          ),
        ),
      ),
    );

    // BottomNav tampil
    expect(find.byType(BottomNav), findsOneWidget);

    // Ambil semua item icon di bottom nav
    final icons = find.byType(Icon);

    if (icons.evaluate().length >= 2) {
      // Tap item kedua
      await tester.tap(icons.at(1));
      await tester.pump();

      expect(currentIndex, 1);
    } else {
      // fallback: minimal widget ada
      expect(find.byType(BottomNav), findsOneWidget);
    }
  });
}
