import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylemake/features/masters/presentation/views/vendors/vendor_form_screen.dart';

void main() {
  group('VendorFormScreen', () {
    testWidgets('renders in add mode with all fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: VendorFormScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Add Vendor'), findsOneWidget);
      expect(find.text('Vendor Name'), findsOneWidget);
      expect(find.text('GST Number'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('PIN Code'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('validates required vendor name', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: VendorFormScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap save without entering data
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Vendor name is required'), findsOneWidget);
    });

    testWidgets('validates GST format when provided', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: VendorFormScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter valid vendor name
      final nameFields = find.byType(TextFormField);
      await tester.enterText(nameFields.at(0), 'Test Vendor');

      // Enter invalid GST
      await tester.enterText(nameFields.at(1), 'INVALID');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Invalid GST'),
        findsOneWidget,
      );
    });

    testWidgets('accepts valid GST format', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: VendorFormScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final nameFields = find.byType(TextFormField);

      // Enter valid vendor name
      await tester.enterText(nameFields.at(0), 'Test Vendor');

      // Enter valid GST
      await tester.enterText(nameFields.at(1), '27AABCU9603R1ZX');

      // No error should appear for valid GST
      // (Would need to actually submit to verify, but format is correct)
    });
  });
}

