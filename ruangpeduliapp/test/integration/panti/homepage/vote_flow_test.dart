import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_berita_panti.dart';

void main() {
  testWidgets('Vote flow basic test', (WidgetTester tester) async {
    int up = 0;
    int down = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              VoteButton(
                isUpvote: true,
                count: up,
                onTap: () {
                  up++;
                },
              ),
              VoteButton(
                isUpvote: false,
                count: down,
                onTap: () {
                  down++;
                },
              ),
            ],
          ),
        ),
      ),
    );

    // Pastikan tombol ada
    expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    expect(find.byIcon(Icons.thumb_down), findsOneWidget);

    // Tap upvote
    await tester.tap(find.byIcon(Icons.thumb_up));
    await tester.pump();
    expect(up, 1);

    // Tap downvote
    await tester.tap(find.byIcon(Icons.thumb_down));
    await tester.pump();
    expect(down, 1);
  });
}
