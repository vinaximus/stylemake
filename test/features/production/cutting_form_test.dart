import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylemake/features/production/presentation/views/cuttings/cutting_form_screen.dart';
import 'package:stylemake/shared/utils/validators.dart';

void main() {
  group('Cutting Form Validation', () {
    test('cutting reference should be required', () {
      final validator = Validators.required('Cutting reference is required');
      expect(validator(''), 'Cutting reference is required');
      expect(validator(null), 'Cutting reference is required');
      expect(validator('  '), 'Cutting reference is required');
      expect(validator('CUT-001'), null);
    });

    test('cutting reference should have minimum length', () {
      final validator = Validators.minLength(
        3,
        'Minimum 3 characters required',
      );
      expect(validator('AB'), 'Minimum 3 characters required');
      expect(validator('ABC'), null);
      expect(validator('CUT-001'), null);
    });

    test('cutting reference should match format', () {
      final validator = Validators.cuttingRefFormat();
      expect(validator('CUT-001'), null);
      expect(validator('CUT001'), null);
      expect(validator('CUT-2025-001'), null);
      expect(validator('cut-001'), isNotNull); // lowercase not allowed
      expect(validator('CUT 001'), isNotNull); // space not allowed
      expect(validator('CUT_001'), isNotNull); // underscore not allowed
    });

    test('quantity should be positive integer', () {
      final validator = Validators.positiveInteger();
      expect(validator('0'), isNotNull);
      expect(validator('-1'), isNotNull);
      expect(validator('1'), null);
      expect(validator('100'), null);
      expect(validator('1.5'), isNotNull); // decimal not allowed
      expect(validator('abc'), isNotNull);
    });

    test('notes should respect maximum length', () {
      final validator = Validators.maxLength(500);
      final shortText = 'Short note';
      final longText = 'a' * 501;

      expect(validator(shortText), null);
      expect(validator(longText), isNotNull);
    });

    test('notes should be optional', () {
      final validator = Validators.maxLength(500);
      expect(validator(''), null);
      expect(validator(null), null);
    });
  });

  testWidgets('Cutting form shows validation on empty submit', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: CuttingFormScreen())));
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
    expect(find.textContaining('required'), findsWidgets);
  });
}

