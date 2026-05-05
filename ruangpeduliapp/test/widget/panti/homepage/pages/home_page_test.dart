import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_panti.dart';

void main() {
  testWidgets('HomePantiPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePanti(
          userId: null,
          pantiId: null,
        ),
      ),
    );

    expect(find.byType(HomePanti), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    // cek salah satu kondisi (loading / empty / list)
    final loading = find.byType(CircularProgressIndicator);
    final empty = find.textContaining('Belum');
    final list = find.byType(ListView);
    final error = find.textContaining('Gagal');

    expect(
      loading.evaluate().isNotEmpty ||
          empty.evaluate().isNotEmpty ||
          list.evaluate().isNotEmpty ||
          error.evaluate().isNotEmpty,
      true,
    );
  });
}
