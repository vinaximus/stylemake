import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/core/models/vendor.dart';
import 'package:stylemake/core/repositories/vendor_repository.dart';

/// Provider for VendorRepository instance
final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return VendorRepository();
});

/// Provider for vendors list with real-time updates
final vendorsListProvider = StreamProvider<List<Vendor>>((ref) {
  final repository = ref.read(vendorRepositoryProvider);
  return repository.watchAllVendors();
});

/// Provider for search query
final vendorSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for city filter
final vendorCityFilterProvider = StateProvider<String?>((ref) => null);

/// Provider for unique cities
final vendorCitiesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(vendorRepositoryProvider);
  return repository.getUniqueCities();
});

/// Provider for filtered vendors based on search query and city filter
final filteredVendorsProvider = Provider<List<Vendor>>((ref) {
  final vendors = ref.watch(vendorsListProvider).value ?? [];
  final query = ref.watch(vendorSearchQueryProvider).toLowerCase();
  final cityFilter = ref.watch(vendorCityFilterProvider);

  var filtered = vendors;

  // Apply city filter
  if (cityFilter != null && cityFilter.isNotEmpty) {
    filtered = filtered.where((v) => v.city == cityFilter).toList();
  }

  // Apply search query
  if (query.isNotEmpty) {
    filtered = filtered
        .where(
          (v) =>
              v.name.toLowerCase().contains(query) ||
              (v.city?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  return filtered;
});
