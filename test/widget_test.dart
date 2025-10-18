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

    // Verify that the app title is present.
    expect(find.text('Stylemake'), findsOneWidget);
    expect(find.text('Garment Manufacturing Management'), findsOneWidget);
    
    // Verify the placeholder message is present.
    expect(find.text('Production Module Coming Soon'), findsOneWidget);
  });
}
