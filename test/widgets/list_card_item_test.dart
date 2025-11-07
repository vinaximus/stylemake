import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylemake/shared/widgets/list_card_item.dart';

void main() {
  group('ListCardItem', () {
    testWidgets('renders title correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ListCardItem(title: 'Test Title')),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListCardItem(title: 'Test Title', subtitle: 'Test Subtitle'),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListCardItem(title: 'Test Title', onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(ListCardItem));
      expect(tapped, isTrue);
    });

    testWidgets('renders trailing widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListCardItem(
              title: 'Test Title',
              trailing: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('renders leading widget when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListCardItem(title: 'Test Title', leading: Icon(Icons.star)),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}
