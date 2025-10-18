import 'package:flutter_test/flutter_test.dart';
import 'package:stylemake/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('required', () {
      test('returns error for null', () {
        final validator = Validators.required();
        expect(validator(null), isNotNull);
      });

      test('returns error for empty string', () {
        final validator = Validators.required();
        expect(validator(''), isNotNull);
      });

      test('returns error for whitespace only', () {
        final validator = Validators.required();
        expect(validator('   '), isNotNull);
      });

      test('returns null for valid input', () {
        final validator = Validators.required();
        expect(validator('valid'), isNull);
      });

      test('returns custom message', () {
        final validator = Validators.required('Custom error');
        expect(validator(''), 'Custom error');
      });
    });

    group('minLength', () {
      test('returns error for too short input', () {
        final validator = Validators.minLength(5);
        expect(validator('abc'), isNotNull);
      });

      test('returns null for valid length', () {
        final validator = Validators.minLength(5);
        expect(validator('abcde'), isNull);
      });

      test('returns null for empty (no validation)', () {
        final validator = Validators.minLength(5);
        expect(validator(''), isNull);
      });
    });

    group('numeric', () {
      test('returns error for non-numeric input', () {
        final validator = Validators.numeric();
        expect(validator('abc'), isNotNull);
      });

      test('returns null for valid number', () {
        final validator = Validators.numeric();
        expect(validator('123'), isNull);
      });

      test('returns error for decimal', () {
        final validator = Validators.numeric();
        expect(validator('12.34'), isNotNull);
      });
    });

    group('positiveNumber', () {
      test('returns error for zero', () {
        final validator = Validators.positiveNumber();
        expect(validator('0'), isNotNull);
      });

      test('returns error for negative', () {
        final validator = Validators.positiveNumber();
        expect(validator('-5'), isNotNull);
      });

      test('returns null for positive number', () {
        final validator = Validators.positiveNumber();
        expect(validator('5'), isNull);
      });
    });

    group('gstNumber', () {
      test('returns error for invalid format', () {
        final validator = Validators.gstNumber();
        expect(validator('invalid'), isNotNull);
      });

      test('returns null for valid GST', () {
        final validator = Validators.gstNumber();
        expect(validator('27AABCU9603R1ZX'), isNull);
      });
    });

    group('pinCode', () {
      test('returns error for too short', () {
        final validator = Validators.pinCode();
        expect(validator('12345'), isNotNull);
      });

      test('returns error for non-numeric', () {
        final validator = Validators.pinCode();
        expect(validator('12ABC5'), isNotNull);
      });

      test('returns null for valid PIN', () {
        final validator = Validators.pinCode();
        expect(validator('400001'), isNull);
      });
    });

    group('compose', () {
      test('returns first error encountered', () {
        final validator = Validators.compose([
          Validators.required('Required'),
          Validators.minLength(5, 'Too short'),
        ]);
        expect(validator(''), 'Required');
      });

      test('validates all successfully', () {
        final validator = Validators.compose([
          Validators.required(),
          Validators.minLength(3),
        ]);
        expect(validator('Valid'), isNull);
      });
    });
  });
}
