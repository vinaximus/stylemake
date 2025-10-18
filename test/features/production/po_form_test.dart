import 'package:flutter_test/flutter_test.dart';
import 'package:stylemake/core/utils/validators.dart';

void main() {
  group('PO Form Validation Tests', () {
    test('Job Order No validator accepts valid format', () {
      final validator = Validators.jobOrderNo();
      expect(validator('JOB-123'), null);
      expect(validator('ABC123'), null);
      expect(validator('123-XYZ-456'), null);
    });

    test('Job Order No validator rejects invalid format', () {
      final validator = Validators.jobOrderNo();
      expect(validator('AB'), isNot(null)); // Too short
      expect(validator('A' * 51), isNot(null)); // Too long
      expect(validator('JOB#123'), isNot(null)); // Invalid character
    });

    test('Positive decimal validator accepts valid numbers', () {
      final validator = Validators.positiveDecimal();
      expect(validator('1'), null);
      expect(validator('10.5'), null);
      expect(validator('999.99'), null);
    });

    test('Positive decimal validator rejects invalid numbers', () {
      final validator = Validators.positiveDecimal();
      expect(validator('0'), isNot(null)); // Not positive
      expect(validator('-1'), isNot(null)); // Negative
      expect(validator('10.123'), isNot(null)); // Too many decimals
    });

    test('Date comparison validator works correctly', () {
      final issueDate = DateTime(2025, 1, 1);
      final validator = Validators.dateComparison(issueDate, 'Issue Date');

      expect(validator('2025-01-01'), null); // Same date
      expect(validator('2025-01-15'), null); // After issue date
      expect(validator('2024-12-31'), isNot(null)); // Before issue date
    });

    test('Positive integer validator accepts valid integers', () {
      final validator = Validators.positiveInteger();
      expect(validator('1'), null);
      expect(validator('100'), null);
      expect(validator('9999'), null);
    });
  });
}
