import 'package:flutter_test/flutter_test.dart';
import 'package:stylemake/features/production/data/repositories/cutting_repository.dart';

void main() {
  group('CuttingRepository', () {
    test('defaultCompanyId should be correct UUID', () {
      expect(
        CuttingRepository.defaultCompanyId,
        '00000000-0000-0000-0000-000000000000',
      );
    });

    test('repository can be instantiated', () {
      final repository = CuttingRepository();
      expect(repository, isNotNull);
    });
  });
}

