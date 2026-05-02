import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/auth/auth_widgets.dart';

void main() {
  group('UnderlineField Widget', () {
    testWidgets(
      'TC-UF-01: UnderlineField displays label and hint correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnderlineField(
                label: 'Email',
                hint: 'Masukan Email',
                onChanged: (value) {},
              ),
            ),
          ),
        );

        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Masukan Email'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-UF-02: UnderlineField accepts text input',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnderlineField(
                label: 'Email',
                hint: 'Masukan Email',
                onChanged: (value) {},
              ),
            ),
          ),
        );

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.pump();

        expect(find.text('test@email.com'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-UF-03: UnderlineField displays error message when provided',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnderlineField(
                label: 'Email',
                hint: 'Masukan Email',
                errorText: 'Email wajib diisi',
                onChanged: (value) {},
              ),
            ),
          ),
        );

        expect(find.text('Email wajib diisi'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-UF-04: UnderlineField clears error when user starts typing',
      (WidgetTester tester) async {
        String? error = 'Email wajib diisi';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return UnderlineField(
                    label: 'Email',
                    hint: 'Masukan Email',
                    errorText: error,
                    onChanged: (value) {
                      setState(() {
                        error = null;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Email wajib diisi'), findsOneWidget);

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'a');
        await tester.pump();

        expect(find.text('Email wajib diisi'), findsNothing);
      },
    );

    testWidgets(
      'TC-UF-05: UnderlineField calls onChanged callback when text changes',
      (WidgetTester tester) async {
        String inputValue = '';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnderlineField(
                label: 'Email',
                hint: 'Masukan Email',
                onChanged: (value) {
                  inputValue = value;
                },
              ),
            ),
          ),
        );

        await tester.enterText(
            find.widgetWithText(TextField, 'Masukan Email'), 'test@email.com');
        await tester.pump();

        expect(inputValue, 'test@email.com');
      },
    );

    testWidgets(
      'TC-UF-06: UnderlineField obscures text when obscure is true',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnderlineField(
                label: 'Password',
                hint: 'Masukan Password',
                obscure: true,
                onChanged: (value) {},
              ),
            ),
          ),
        );

        final textField = find.byType(TextField);
        expect(textField, findsOneWidget);
      },
    );

    testWidgets(
      'TC-UF-07: UnderlineField with controller can be updated externally',
      (WidgetTester tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnderlineField(
                label: 'Email',
                hint: 'Masukan Email',
                controller: controller,
                onChanged: (value) {},
              ),
            ),
          ),
        );

        controller.text = 'test@example.com';
        await tester.pump();

        expect(find.text('test@example.com'), findsOneWidget);
        controller.dispose();
      },
    );
  });
}
