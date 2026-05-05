import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/profile_panti/video_baru_panti.dart';

void main() {
  testWidgets('VideoBaruPanti render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: VideoBaruPanti(
          pantiId: 1,
        ),
      ),
    );

    expect(find.byType(VideoBaruPanti), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}