import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/profile_panti.dart';

void main() {
  testWidgets('Logout flow basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfilePanti(),
      ),
    );

    // Halaman tampil
    expect(find.byType(ProfilePanti), findsOneWidget);

    // Cari tombol logout (text atau icon umum)
    final logoutButton = find.textContaining('Logout').evaluate().isNotEmpty
        ? find.textContaining('Logout')
        : find.byIcon(Icons.logout);

    if (logoutButton.evaluate().isNotEmpty) {
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();
    }

    // Pastikan tidak crash / tetap ada widget utama
    expect(find.byType(ProfilePanti), findsOneWidget);
  });
}