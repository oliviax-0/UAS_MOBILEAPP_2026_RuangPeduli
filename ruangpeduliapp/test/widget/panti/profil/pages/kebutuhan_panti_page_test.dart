import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/kebutuhan_panti.dart';

void main() {
  testWidgets('KebutuhanPantiPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KebutuhanPantiPage(
            pantiId: 1,
            userId: 1,
          ),
        ),
      ),
    );

    expect(find.byType(KebutuhanPantiPage), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}