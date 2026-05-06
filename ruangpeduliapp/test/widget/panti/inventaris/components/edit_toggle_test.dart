import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Edit toggle test',
      (WidgetTester tester) async {

    bool isEdit = false;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isEdit = !isEdit;
                      });
                    },
                    child: Icon(
                      isEdit ? Icons.check : Icons.edit,
                    ),
                  ),

                  Text(
                    isEdit ? 'Mode Edit' : 'Mode View',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    // awalnya mode view
    expect(find.text('Mode View'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);

    // tap toggle
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pump();

    // berubah ke mode edit
    expect(find.text('Mode Edit'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}