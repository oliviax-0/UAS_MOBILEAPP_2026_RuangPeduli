import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/home_panti/home_berita_panti.dart';

void main() {
  testWidgets('VoteButton render & tap test', (WidgetTester tester) async {
    int voteCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VoteButton(
            isUpvote: true,
            count: voteCount,
            onTap: () {
              voteCount++;
            },
          ),
        ),
      ),
    );

    expect(find.byType(VoteButton), findsOneWidget);
    expect(find.byIcon(Icons.thumb_up), findsOneWidget);

    await tester.tap(find.byType(VoteButton));
    await tester.pump();

    expect(voteCount, 1);
  });
}
