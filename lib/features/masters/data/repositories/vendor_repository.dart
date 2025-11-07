import 'package:stylemake/features/masters/data/models/vendor.dart';
import 'package:stylemake/app/services/supabase_service.dart';
import 'package:stylemake/app/services/realtime_service.dart';
import 'package:stylemake/shared/utils/error_handler.dart';
import 'package:stylemake/shared/utils/performance_monitor.dart';

/// Repository for Vendor-related database operations
class VendorRepository {
  VendorRepository({SupabaseService? supabaseService})
    : _supabaseService = supabaseService ?? SupabaseService.instance;

  final SupabaseService _supabaseService;

  /// Default company ID for v0.5 single-company mode
  static const String defaultCompanyId = '00000000-0000-0000-0000-000000000000';

  /// Stream of vendors with real-time updates
  Stream<List<Vendor>> watchAllVendors() async* {
    // First, yield the initial data
    try {
      final initialData = await getAllVendors();
      yield initialData;
    } catch (e, stackTrace) {
      ErrorHandler.logError('watchAllVendors - initial load', e, stackTrace);
      yield [];
    }

    // Then, listen for realtime updates and refresh data
    final realtimeStream = RealtimeService.instance.subscribeToCompanyTable(
      table: 'vendors',
    );

    await for (final _ in realtimeStream) {
      try {
        // Fetch fresh data whenever there's an update
        final freshData = await getAllVendors();
        yield freshData;
      } catch (e, stackTrace) {
        ErrorHandler.logError(
          'watchAllVendors - realtime update',
          e,
          stackTrace,
        );
        // Don't yield on error, keep the previous state
      }
    }
  }

  /// Fetch all vendors for the current company
  Future<List<Vendor>> getAllVendors() async {
    return PerformanceMonitor.instance.measure('getAllVendors', () async {
      try {
        final response = await _supabaseService.client
            .from('vendors')
            .select()
            .eq('company_id', defaultCompanyId)
            .order('name');

        final data = response as List<dynamic>;
        return data
            .map((json) => Vendor.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw Exception('Failed to fetch vendors: $e');
      }
    });
  }

  /// Get a single vendor by ID
  Future<Vendor?> getVendorById(String id) async {
    try {
      final response = await _supabaseService.client
          .from('vendors')
          .select()
          .eq('id', id)
          .eq('company_id', defaultCompanyId)
          .maybeSingle();

      if (response == null) return null;

      return Vendor.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch vendor: $e');
    }
  }

  /// Create a new vendor
  Future<Vendor> createVendor({
    required String name,
    String? gst,
    String? address,
    String? city,
    String? pinCode,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('vendors')
          .insert({
            'name': name,
            'gst': gst,
            'address': address,
            'city': city,
            'pin_code': pinCode,
            'company_id': defaultCompanyId,
            'user_id': defaultCompanyId,
          })
          .select()
          .single();

      return Vendor.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create vendor: $e');
    }
  }

  /// Update an existing vendor
  Future<Vendor> updateVendor({
    required String id,
    required String name,
    String? gst,
    String? address,
    String? city,
    String? pinCode,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('vendors')
          .update({
            'name': name,
            'gst': gst,
            'address': address,
            'city': city,
            'pin_code': pinCode,
          })
          .eq('id', id)
          .eq('company_id', defaultCompanyId)
          .select()
          .single();

      return Vendor.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update vendor: $e');
    }
  }

  /// Delete a vendor
  Future<void> deleteVendor(String id) async {
    try {
      await _supabaseService.client
          .from('vendors')
          .delete()
          .eq('id', id)
          .eq('company_id', defaultCompanyId);
    } catch (e) {
      throw Exception('Failed to delete vendor: $e');
    }
  }

  /// Search vendors by name or city
  Future<List<Vendor>> searchVendors(String query) async {
    try {
      if (query.trim().isEmpty) {
        return getAllVendors();
      }

      final searchTerm = query.toLowerCase();
      final response = await _supabaseService.client
          .from('vendors')
          .select()
          .eq('company_id', defaultCompanyId)
          .or('name.ilike.%$searchTerm%,city.ilike.%$searchTerm%')
          .order('name');

      final data = response as List<dynamic>;
      return data
          .map((json) => Vendor.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search vendors: $e');
    }
  }

  /// Filter vendors by city
  Future<List<Vendor>> filterByCity(String city) async {
    try {
      final response = await _supabaseService.client
          .from('vendors')
          .select()
          .eq('company_id', defaultCompanyId)
          .eq('city', city)
          .order('name');

      final data = response as List<dynamic>;
      return data
          .map((json) => Vendor.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter vendors by city: $e');
    }
  }

  /// Get unique cities from vendors
  Future<List<String>> getUniqueCities() async {
    try {
      final response = await _supabaseService.client
          .from('vendors')
          .select('city')
          .eq('company_id', defaultCompanyId)
          .not('city', 'is', null);

      final data = response as List<dynamic>;
      final cities = data
          .map((json) => json['city'] as String?)
          .where((city) => city != null && city.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      cities.sort();
      return cities;
    } catch (e) {
      throw Exception('Failed to fetch cities: $e');
    }
  }
}
