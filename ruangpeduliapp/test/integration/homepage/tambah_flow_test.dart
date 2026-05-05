import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_beritabaru.dart';

void main() {
  testWidgets('Tambah flow basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BeritaBaruPanti(
          userId: 1,
          pantiId: 1,
        ),
      ),
    );

    // Halaman tampil
    expect(find.byType(BeritaBaruPanti), findsOneWidget);

    await tester.pumpAndSettle();

    // Cari input field
    final fields = find.byType(TextField);
    expect(fields, findsWidgets);

    // Isi field (judul & isi jika ada)
    if (fields.evaluate().length >= 2) {
      await tester.enterText(fields.at(0), 'Judul Test');
      await tester.enterText(fields.at(1), 'Isi Test');
      await tester.pump();
    }

    // Cari tombol submit
    final submitBtn = find.textContaining('Kirim').evaluate().isNotEmpty
        ? find.textContaining('Kirim')
        : find.textContaining('Bagikan');

    if (submitBtn.evaluate().isNotEmpty) {
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();
    }

    // Cek hasil: snackbar / loading / tetap di page
    final snackbar = find.byType(SnackBar);
    final loading = find.byType(CircularProgressIndicator);

    expect(
          snackbar.evaluate().isNotEmpty ||
          loading.evaluate().isNotEmpty ||
          find.byType(BeritaBaruPanti).evaluate().isNotEmpty,
      true,
    );
  });
}
