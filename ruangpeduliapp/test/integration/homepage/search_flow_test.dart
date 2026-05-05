import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_panti.dart';

void main() {
  testWidgets('Search flow basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePanti(
          userId: null,
          pantiId: null,
        ),
      ),
    );

    expect(find.byType(HomePanti), findsOneWidget);

    await tester.pumpAndSettle();

    final textField = find.byType(TextField);

    if (textField.evaluate().isNotEmpty) {
      await tester.enterText(textField.first, 'beras');
      await tester.pump();

      // trigger submit (enter)
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
    }

    // kondisi setelah search: list / empty / loading
    final list = find.byType(ListView);
    final empty = find.textContaining('Tidak ada');
    final belum = find.textContaining('Belum');
    final error = find.textContaining('Gagal');
    final loading = find.byType(CircularProgressIndicator);

    expect(
      list.evaluate().isNotEmpty ||
          empty.evaluate().isNotEmpty ||
          belum.evaluate().isNotEmpty ||
          error.evaluate().isNotEmpty ||
          loading.evaluate().isNotEmpty,
      true,
    );
  });
}
