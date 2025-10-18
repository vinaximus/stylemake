import 'package:flutter_test/flutter_test.dart';
import 'package:stylemake/core/repositories/fabrication_po_repository.dart';

void main() {
  group('FabricationPoRepository Tests', () {
    test('Repository instantiates successfully', () {
      final repository = FabricationPoRepository();
      expect(repository, isNotNull);
    });
  });
}
