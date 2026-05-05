import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/edit_profile_panti.dart';

void main() {
  testWidgets('AvatarPicker render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AvatarPicker(
            imageUrl: '',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byType(AvatarPicker), findsOneWidget);
  });
}