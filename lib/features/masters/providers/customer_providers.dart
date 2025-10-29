import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/core/models/customer.dart';
import 'package:stylemake/core/repositories/customer_repository.dart';

/// Provider for CustomerRepository instance
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});

/// Provider for customers list with real-time updates
final customersListProvider = StreamProvider<List<Customer>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.watchAllCustomers();
});

/// Provider for customer search query
final customerSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered customers based on search query
final filteredCustomersProvider = Provider<List<Customer>>((ref) {
  final customersAsync = ref.watch(customersListProvider);
  final searchQuery = ref.watch(customerSearchQueryProvider);

  return customersAsync.when(
    data: (customers) {
      if (searchQuery.isEmpty) return customers;

      final query = searchQuery.toLowerCase();
      return customers.where((customer) {
        return customer.customerName.toLowerCase().contains(query) ||
               (customer.contactPerson?.toLowerCase().contains(query) ?? false) ||
               (customer.phone?.toLowerCase().contains(query) ?? false);
      }).toList();
    },
    loading: () => <Customer>[],
    error: (_, __) => <Customer>[],
  );
});

/// Provider for single customer by ID
final customerProvider = FutureProvider.family<Customer?, String>((ref, id) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomerById(id);
});

/// Provider for checking if customer can be deleted
final canDeleteCustomerProvider = FutureProvider.family<bool, String>((ref, id) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.canDeleteCustomer(id);
});

/// Provider for unique cities
final customerCitiesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getUniqueCities();
});
