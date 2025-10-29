import 'package:stylemake/core/models/customer.dart';
import 'package:stylemake/core/services/supabase_service.dart';
import 'package:stylemake/core/services/realtime_service.dart';
import 'package:stylemake/core/utils/error_handler.dart';
import 'package:stylemake/core/utils/performance_monitor.dart';

/// Repository for Customer-related database operations
class CustomerRepository {
  CustomerRepository({SupabaseService? supabaseService})
    : _supabaseService = supabaseService ?? SupabaseService.instance;

  final SupabaseService _supabaseService;

  /// Default company ID for v0.5 single-company mode
  static const String defaultCompanyId = '00000000-0000-0000-0000-000000000000';

  /// Stream of customers with real-time updates
  Stream<List<Customer>> watchAllCustomers() async* {
    // First, yield the initial data
    try {
      final initialData = await getAllCustomers();
      yield initialData;
    } catch (e, stackTrace) {
      ErrorHandler.logError('watchAllCustomers - initial load', e, stackTrace);
      yield [];
    }

    // Then, listen for realtime updates and refresh data
    final realtimeStream = RealtimeService.instance.subscribeToCompanyTable(
      table: 'customers',
    );

    await for (final _ in realtimeStream) {
      try {
        // Fetch fresh data whenever there's an update
        final freshData = await getAllCustomers();
        yield freshData;
      } catch (e, stackTrace) {
        ErrorHandler.logError(
          'watchAllCustomers - realtime update',
          e,
          stackTrace,
        );
        // Don't yield on error, keep the previous state
      }
    }
  }

  /// Fetch all customers for the current company
  Future<List<Customer>> getAllCustomers() async {
    return PerformanceMonitor.instance.measure('getAllCustomers', () async {
      try {
        final response = await _supabaseService.client
            .from('customers')
            .select()
            .eq('company_id', defaultCompanyId)
            .order('customer_name');

        final data = response;
        return data
            .map((json) => Customer.fromJson(json))
            .toList();
      } catch (e) {
        throw Exception('Failed to fetch customers: $e');
      }
    });
  }

  /// Get a single customer by ID
  Future<Customer?> getCustomerById(String id) async {
    try {
      final response = await _supabaseService.client
          .from('customers')
          .select()
          .eq('id', id)
          .eq('company_id', defaultCompanyId)
          .maybeSingle();

      if (response == null) return null;

      return Customer.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch customer: $e');
    }
  }

  /// Create a new customer
  Future<Customer> createCustomer(Map<String, dynamic> data) async {
    return PerformanceMonitor.instance.measure('createCustomer', () async {
      try {
        // Add default company and user IDs
        final customerData = {
          ...data,
          'company_id': defaultCompanyId,
          'user_id': defaultCompanyId,
        };

        final response = await _supabaseService.client
            .from('customers')
            .insert(customerData)
            .select()
            .single();

        return Customer.fromJson(response);
      } catch (e) {
        throw Exception('Failed to create customer: $e');
      }
    });
  }

  /// Update an existing customer
  Future<Customer> updateCustomer(String id, Map<String, dynamic> data) async {
    return PerformanceMonitor.instance.measure('updateCustomer', () async {
      try {
        final response = await _supabaseService.client
            .from('customers')
            .update(data)
            .eq('id', id)
            .eq('company_id', defaultCompanyId)
            .select()
            .single();

        return Customer.fromJson(response);
      } catch (e) {
        throw Exception('Failed to update customer: $e');
      }
    });
  }

  /// Delete a customer (with reference check)
  Future<void> deleteCustomer(String id) async {
    return PerformanceMonitor.instance.measure('deleteCustomer', () async {
      try {
        // First check if customer is referenced in dispatches
        final canDelete = await canDeleteCustomer(id);
        if (!canDelete) {
          throw Exception('Cannot delete customer: Customer is referenced in dispatch records');
        }

        await _supabaseService.client
            .from('customers')
            .delete()
            .eq('id', id)
            .eq('company_id', defaultCompanyId);
      } catch (e) {
        if (e.toString().contains('referenced in dispatch records')) {
          rethrow;
        }
        throw Exception('Failed to delete customer: $e');
      }
    });
  }

  /// Check if customer can be deleted (not referenced in dispatches)
  Future<bool> canDeleteCustomer(String id) async {
    try {
      final response = await _supabaseService.client
          .from('dispatch_master')
          .select('id')
          .eq('customer_id', id)
          .eq('company_id', defaultCompanyId)
          .limit(1);

      final data = response;
      return data.isEmpty; // Can delete if no references found
    } catch (e) {
      // If there's an error checking references, assume we can't delete
      return false;
    }
  }

  /// Get unique cities for filtering
  Future<List<String>> getUniqueCities() async {
    try {
      final response = await _supabaseService.client
          .from('customers')
          .select('contact_person')
          .eq('company_id', defaultCompanyId)
          .not('contact_person', 'is', null);

      final data = response;
      final cities = data
          .map((json) => json['contact_person'] as String?)
          .where((city) => city != null && city.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      cities.sort();
      return cities;
    } catch (e) {
      ErrorHandler.logError('getUniqueCities', e, StackTrace.current);
      return [];
    }
  }
}
