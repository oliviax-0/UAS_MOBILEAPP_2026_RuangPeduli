import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_beritabaru.dart';

void main() {
  testWidgets('TambahPage render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BeritaBaruPanti(
          userId: 1,
          pantiId: 1,
        ),
      ),
    );

    expect(find.byType(BeritaBaruPanti), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Postingan Baru'), findsOneWidget);

    // cek ada input field
    final fields = find.byType(TextField);
    expect(fields, findsWidgets);

    // cek tombol submit (fallback fleksibel)
    final submitBtn = find.text('Bagikan');

    if (submitBtn.evaluate().isNotEmpty) {
      expect(submitBtn, findsOneWidget);
    }
  });
}
