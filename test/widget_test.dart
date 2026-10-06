// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lira_app/main.dart';

void main() {
  testWidgets('language switch changes the app language', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SyrianCurrencyConverterApp());

    expect(find.text('محول الليرة السورية'), findsOneWidget);
    expect(find.text('المحول'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('languageSwitch')));
    await tester.pump();

    expect(find.text('Syrian Lira Converter'), findsOneWidget);
    expect(find.text('Converter'), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.pump();

    expect(find.text('This screen is coming soon'), findsOneWidget);
  });
}
