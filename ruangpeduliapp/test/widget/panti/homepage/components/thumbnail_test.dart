import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_beritabaru.dart';

void main() {
  testWidgets('ThumbnailPicker render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ThumbnailPicker(
            imagePath: '',
            onPick: () {},
          ),
        ),
      ),
    );

    expect(find.byType(ThumbnailPicker), findsOneWidget);
    expect(find.byType(GestureDetector), findsWidgets);
  });
}
