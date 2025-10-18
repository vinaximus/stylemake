import 'package:flutter_test/flutter_test.dart';
import 'package:stylemake/core/repositories/vendor_repository.dart';

void main() {
  group('VendorRepository', () {
    test('has default company ID constant', () {
      expect(
        VendorRepository.defaultCompanyId,
        '00000000-0000-0000-0000-000000000000',
      );
    });

    test('creates instance successfully', () {
      final repository = VendorRepository();
      expect(repository, isA<VendorRepository>());
    });

    // Note: Full integration tests require Supabase connection
    // These would be tested manually or with a test database
  });
}

