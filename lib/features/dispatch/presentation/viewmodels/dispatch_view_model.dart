import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/features/dispatch/data/models/dispatch_master.dart';
import 'package:stylemake/features/dispatch/data/models/dispatch_item.dart';
import 'package:stylemake/features/masters/data/models/customer.dart';
import 'package:stylemake/features/dispatch/data/repositories/dispatch_repository.dart';
import 'package:stylemake/features/masters/data/repositories/customer_repository.dart';

/// Provider for DispatchRepository instance
final dispatchRepositoryProvider = Provider<DispatchRepository>((ref) {
  return DispatchRepository();
});

/// Provider for dispatches list with real-time updates
final dispatchesListProvider = StreamProvider<List<DispatchMaster>>((ref) {
  final repository = ref.read(dispatchRepositoryProvider);
  return repository.watchAllDispatches();
});

/// Provider for dispatch search query
final dispatchSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered dispatches based on search query
final filteredDispatchesProvider = Provider<List<DispatchMaster>>((ref) {
  final dispatchesAsync = ref.watch(dispatchesListProvider);
  final query = ref.watch(dispatchSearchQueryProvider).toLowerCase();

  return dispatchesAsync.when(
    data: (dispatches) {
      if (query.isEmpty) {
        return dispatches;
      }

      return dispatches.where((dispatch) {
        final dispatchNoMatch = dispatch.dispatchNo.toLowerCase().contains(
          query,
        );
        final vehicleMatch =
            dispatch.vehicleNo?.toLowerCase().contains(query) ?? false;
        final lrNoMatch = dispatch.lrNo?.toLowerCase().contains(query) ?? false;
        // Note: Customer name search would need to be implemented with joined data
        return dispatchNoMatch || vehicleMatch || lrNoMatch;
      }).toList();
    },
    loading: () => <DispatchMaster>[],
    error: (_, __) => <DispatchMaster>[],
  );
});

/// Provider for single dispatch by ID
final dispatchProvider = FutureProvider.family<DispatchMaster?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(dispatchRepositoryProvider);
  return repository.getDispatchById(id);
});

/// Provider for dispatch items by dispatch ID
final dispatchItemsProvider = FutureProvider.family<List<DispatchItem>, String>(
  (ref, dispatchId) async {
    final repository = ref.watch(dispatchRepositoryProvider);
    return repository.getDispatchItems(dispatchId);
  },
);

/// Provider for checking if dispatch can be deleted
final canDeleteDispatchProvider = FutureProvider.family<bool, String>((
  ref,
  id,
) async {
  // For now, all dispatches can be deleted
  // In future, add business logic to check if dispatch is referenced elsewhere
  return true;
});

/// Provider for dispatch count
final dispatchesCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(dispatchRepositoryProvider);
  return repository.getDispatchesCount();
});

/// Provider for CustomerRepository instance
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});

/// Provider for customers dropdown in dispatch form
final customersForDispatchProvider = FutureProvider<List<Customer>>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getAllCustomers();
});

/// Provider for styles dropdown in dispatch form
final stylesForDispatchProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  // For now, return empty list - in future, integrate with style repository
  return [];
});

/// Provider for dispatch form state management
final dispatchFormStateProvider = StateProvider<Map<String, dynamic>>(
  (ref) => {},
);

/// Provider for dispatch items in form
final dispatchFormItemsProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) => [],
);

/// Provider for total quantity calculation
final dispatchTotalQuantityProvider = Provider<double>((ref) {
  final items = ref.watch(dispatchFormItemsProvider);
  return items.fold<double>(
    0.0,
    (sum, item) => sum + (item['quantity'] as num? ?? 0).toDouble(),
  );
});

/// Provider for selected customer ID in dispatch form
final selectedCustomerIdProvider = StateProvider<String?>((ref) => null);
