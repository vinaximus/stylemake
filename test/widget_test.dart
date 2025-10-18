// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:stylemake/main.dart';

void main() {
  testWidgets('App renders placeholder home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StylemakeApp());

    // Wait for the initial frame
    await tester.pump();

    // Verify that the app title is present.
    expect(find.text('Stylemake'), findsOneWidget);
    expect(find.text('Garment Manufacturing Management'), findsOneWidget);

    // Verify the Phase 1 message is present.
    expect(find.text('Phase 1 - Database Setup'), findsOneWidget);

    // Note: Connection test is async and will complete quickly in tests
    // We just verify the basic UI renders correctly
  });
}
