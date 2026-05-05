import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/profile_panti.dart';

void main() {
  testWidgets('ProfilePanti render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfilePanti(),
        ),
      ),
    );

    // halaman tampil
    expect(find.byType(ProfilePanti), findsOneWidget);

    // cek header text "Profil" (bukan "Profile")
    expect(find.text('Profil'), findsWidgets);

    // cek Column structure
    expect(find.byType(Column), findsWidgets);

    // cek Divider (pemisah di layout)
    expect(find.byType(Divider), findsWidgets);
  });
}