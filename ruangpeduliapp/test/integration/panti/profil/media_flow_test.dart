import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/video_baru_panti.dart';

void main() {
  testWidgets('Media flow basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VideoBaruPanti(
          pantiId: 1,
        ),
      ),
    );

    // Halaman tampil
    expect(find.byType(VideoBaruPanti), findsOneWidget);
    expect(find.text('Video Baru'), findsOneWidget);

    // Mode unggah file tampil secara default.
    expect(find.text('Unggah File'), findsOneWidget);
    expect(find.text('Pilih Video dari Galeri'), findsOneWidget);

    // Pindah ke mode URL agar tidak membuka picker native di test.
    await tester.tap(find.text('Link URL'));
    await tester.pumpAndSettle();

    expect(find.text('URL Video'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'https://youtube.com/...'), findsOneWidget);

    // Submit tanpa URL hanya memunculkan validasi lokal, tidak memanggil API.
    await tester.tap(find.text('Bagikan'));
    await tester.pump();

    expect(find.text('Masukkan URL video terlebih dahulu'), findsOneWidget);

    // Pastikan tidak crash
    expect(find.byType(VideoBaruPanti), findsOneWidget);
  });
}
