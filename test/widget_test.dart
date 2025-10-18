// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:stylemake/main.dart';

void main() {
  testWidgets('App renders with bottom navigation', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StylemakeApp());

    // Wait for the initial frame and navigation
    await tester.pumpAndSettle();

    // Verify that the bottom navigation is present
    expect(find.text('Production'), findsOneWidget);
    expect(find.text('Masters'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);

    // Verify the Production screen is shown by default
    expect(find.text('Production Module'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches screens', (
    WidgetTester tester,
  ) async {
    // Build our app
    await tester.pumpWidget(const StylemakeApp());
    await tester.pumpAndSettle();

    // Tap on Masters tab
    await tester.tap(find.text('Masters'));
    await tester.pumpAndSettle();

    // Verify Masters screen is shown
    expect(find.text('Master Data Management'), findsOneWidget);

    // Tap on Reports tab
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();

    // Verify Reports screen is shown
    expect(find.text('Reports & Analytics'), findsOneWidget);
  });
}
