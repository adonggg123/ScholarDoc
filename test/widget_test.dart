// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:tesdoc_project/main.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ScholarDocApp());

    // Verify that our splash screen shows the app name.
    expect(find.text('ScholarDoc'), findsOneWidget);
    expect(find.text('Manage your TES documents with ease.'), findsOneWidget);

    // Wait for the splash screen timer (3 seconds) to finish to avoid "pending timers" error.
    await tester.pump(const Duration(seconds: 4));
  });
}
