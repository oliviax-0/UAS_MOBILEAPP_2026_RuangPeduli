import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_panti.dart';

void main() {
  testWidgets('BottomNav render & tap test', (WidgetTester tester) async {
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

    expect(find.byType(BottomNav), findsOneWidget);

    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
    await tester.pump();

    expect(currentIndex, 1);
  });
}
