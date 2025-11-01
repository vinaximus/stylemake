import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylemake/features/masters/screens/styles/style_form_screen.dart';

void main() {
  group('StyleFormScreen', () {
    testWidgets('renders in add mode', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: StyleFormScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Add Style'), findsOneWidget);
      expect(find.text('Style Name'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('renders in edit mode', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: StyleFormScreen(styleId: 'test-id'),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Edit Style'), findsOneWidget);
    });

    testWidgets('validates required field', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: StyleFormScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap save without entering data
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Style name is required'), findsOneWidget);
    });

    testWidgets('validates minimum length', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: StyleFormScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Style Name field specifically (first TextFormField)
      final textFields = find.byType(TextFormField);
      expect(textFields, findsWidgets);
      
      // Enter 2 characters (less than minimum 3) in the first field (Style Name)
      await tester.enterText(textFields.first, 'ab');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Minimum 3 characters required'), findsOneWidget);
    });
  });
}

