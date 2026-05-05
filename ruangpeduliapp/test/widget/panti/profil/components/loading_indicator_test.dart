import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoadingIndicator Widget', () {
    testWidgets(
      'TC-LI-01: loading indicator tampil di layar',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'TC-LI-02: loading indicator memiliki ukuran tetap',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byType(CircularProgressIndicator),
            matching: find.byType(SizedBox),
          ),
        );
        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );

        expect(sizedBox.width, 24);
        expect(sizedBox.height, 24);
        expect(indicator.strokeWidth, 2);
      },
    );

    testWidgets(
      'TC-LI-03: loading indicator dapat memakai warna tema aplikasi',
      (WidgetTester tester) async {
        const loadingColor = Color(0xFFF28695);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: loadingColor),
              ),
            ),
          ),
        );

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );

        expect(indicator.color, loadingColor);
      },
    );
  });
}
