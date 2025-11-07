import 'package:stylemake/features/dispatch/data/models/dispatch_master.dart';
import 'package:stylemake/features/dispatch/data/models/dispatch_item.dart';
import 'package:stylemake/app/services/supabase_service.dart';
import 'package:stylemake/app/services/realtime_service.dart';
import 'package:stylemake/shared/utils/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for Dispatch-related database operations
class DispatchRepository {
  DispatchRepository({SupabaseService? supabaseService})
    : _supabaseService = supabaseService ?? SupabaseService.instance;

  final SupabaseService _supabaseService;

  /// Default company ID for v0.5 single-company mode
  static const String defaultCompanyId = '00000000-0000-0000-0000-000000000000';

  /// Stream of dispatches with real-time updates
  Stream<List<DispatchMaster>> watchAllDispatches() async* {
    // First, yield the initial data
    try {
      final initialData = await getAllDispatches();
      yield initialData;
    } catch (e, stackTrace) {
      ErrorHandler.logError('watchAllDispatches - initial load', e, stackTrace);
      yield [];
    }

    // Then, listen for realtime updates and refresh data
    final realtimeStream = RealtimeService.instance.subscribeToCompanyTable(
      table: 'dispatch_master',
    );

    await for (final _ in realtimeStream) {
      try {
        // Fetch fresh data whenever there's an update
        final freshData = await getAllDispatches();
        yield freshData;
      } catch (e, stackTrace) {
        ErrorHandler.logError(
          'watchAllDispatches - realtime update',
          e,
          stackTrace,
        );
        // Don't yield on error, keep the previous state
      }
    }
  }

  /// Fetch all dispatches for the current company
  Future<List<DispatchMaster>> getAllDispatches() async {
    try {
      final response = await _supabaseService.client
          .from('dispatch_master')
          .select('''
            *,
            customers!inner(
              id,
              customer_name,
              contact_person,
              phone,
              address
            )
          ''')
          .eq('company_id', defaultCompanyId)
          .order('dispatch_date', ascending: false);

      final data = response as List<dynamic>;
      return data
          .map((json) => DispatchMaster.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch dispatches: $e');
    }
  }

  /// Get a single dispatch by ID
  Future<DispatchMaster?> getDispatchById(String id) async {
    try {
      final response = await _supabaseService.client
          .from('dispatch_master')
          .select('''
            *,
            customers!inner(
              id,
              customer_name,
              contact_person,
              phone,
              address
            )
          ''')
          .eq('id', id)
          .eq('company_id', defaultCompanyId)
          .maybeSingle();

      if (response == null) return null;

      return DispatchMaster.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch dispatch: $e');
    }
  }

  /// Get dispatch items for a specific dispatch
  Future<List<DispatchItem>> getDispatchItems(String dispatchId) async {
    try {
      final response = await _supabaseService.client
          .from('dispatch_items')
          .select('''
            *,
            styles!inner(
              id,
              name,
              designer
            )
          ''')
          .eq('dispatch_id', dispatchId)
          .order('created_at');

      final data = response as List<dynamic>;
      return data
          .map((json) => DispatchItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch dispatch items: $e');
    }
  }

  /// Get count of dispatches
  Future<int> getDispatchesCount() async {
    try {
      final response = await _supabaseService.client
          .from('dispatch_master')
          .select()
          .eq('company_id', defaultCompanyId)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      throw Exception('Failed to count dispatches: $e');
    }
  }

  /// Delete a dispatch (cascade deletes items)
  Future<void> deleteDispatch(String id) async {
    try {
      await _supabaseService.client
          .from('dispatch_master')
          .delete()
          .eq('id', id)
          .eq('company_id', defaultCompanyId);
    } catch (e) {
      throw Exception('Failed to delete dispatch: $e');
    }
  }

  /// Generate next dispatch number (DCH-XXXX format)
  Future<String> generateDispatchNo() async {
    try {
      // Get the highest dispatch number for this company
      final response = await _supabaseService.client
          .from('dispatch_master')
          .select('dispatch_no')
          .eq('company_id', defaultCompanyId)
          .like('dispatch_no', 'DCH-%')
          .order('dispatch_no', ascending: false)
          .limit(1);

      int nextNumber = 1;
      
      if (response.isNotEmpty) {
        final lastDispatchNo = response.first['dispatch_no'] as String;
        final numberPart = lastDispatchNo.split('-')[1];
        nextNumber = int.parse(numberPart) + 1;
      }

      return 'DCH-${nextNumber.toString().padLeft(4, '0')}';
    } catch (e) {
      throw Exception('Failed to generate dispatch number: $e');
    }
  }

  /// Create a new dispatch with items
  Future<DispatchMaster> createDispatch(
    Map<String, dynamic> masterData,
    List<Map<String, dynamic>> itemsData,
  ) async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        // Calculate total quantity
        final totalQuantity = itemsData.fold<double>(
          0.0,
          (sum, item) => sum + (item['quantity'] as num).toDouble(),
        );

        // Generate dispatch number if not provided or if retrying
        String dispatchNo = masterData['dispatch_no'] as String? ?? '';
        if (dispatchNo.isEmpty || retryCount > 0) {
          dispatchNo = await generateDispatchNo();
        }

        // Prepare master data
        final masterPayload = {
          ...masterData,
          'dispatch_no': dispatchNo,
          'company_id': defaultCompanyId,
          'user_id': defaultCompanyId, // Using company ID as user ID for v0.5
          'total_quantity': totalQuantity,
        };

        // Create master record
        final masterResponse = await _supabaseService.client
            .from('dispatch_master')
            .insert(masterPayload)
            .select()
            .single();

        final master = DispatchMaster.fromJson(masterResponse);

        // Create items
        if (itemsData.isNotEmpty) {
          final itemsPayload = itemsData.map((item) {
            // Filter only database fields - exclude display-only fields like 'style_name'
            return {
              'dispatch_id': master.id,
              'style_id': item['style_id'],
              'color': item['color'],
              'size': item['size'],
              'quantity': item['quantity'],
              'rate': item['rate'],
              'remarks': item['remarks'],
            };
          }).toList();

          await _supabaseService.client
              .from('dispatch_items')
              .insert(itemsPayload);
        }

        return master;
      } catch (e) {
        // Check if it's a unique constraint violation
        if (e.toString().contains('23505') || e.toString().contains('unique constraint')) {
          retryCount++;
          if (retryCount >= maxRetries) {
            throw Exception('Failed to create dispatch: Unable to generate unique dispatch number after $maxRetries attempts');
          }
          // Wait a bit before retrying
          await Future.delayed(Duration(milliseconds: 100 * retryCount));
          continue;
        } else {
          throw Exception('Failed to create dispatch: $e');
        }
      }
    }
    
    throw Exception('Failed to create dispatch: Maximum retries exceeded');
  }

  /// Update an existing dispatch with items
  Future<DispatchMaster> updateDispatch(
    String id,
    Map<String, dynamic> masterData,
    List<Map<String, dynamic>> itemsData,
  ) async {
    try {
      // Calculate total quantity
      final totalQuantity = itemsData.fold<double>(
        0.0,
        (sum, item) => sum + (item['quantity'] as num).toDouble(),
      );

      // Update master record
      final masterPayload = {
        ...masterData,
        'total_quantity': totalQuantity,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final masterResponse = await _supabaseService.client
          .from('dispatch_master')
          .update(masterPayload)
          .eq('id', id)
          .eq('company_id', defaultCompanyId)
          .select()
          .single();

      // Delete existing items
      await _supabaseService.client
          .from('dispatch_items')
          .delete()
          .eq('dispatch_id', id);

      // Create new items
      if (itemsData.isNotEmpty) {
        final itemsPayload = itemsData.map((item) {
          // Filter only database fields - exclude display-only fields like 'style_name'
          return {
            'dispatch_id': id,
            'style_id': item['style_id'],
            'color': item['color'],
            'size': item['size'],
            'quantity': item['quantity'],
            'rate': item['rate'],
            'remarks': item['remarks'],
          };
        }).toList();

        await _supabaseService.client
            .from('dispatch_items')
            .insert(itemsPayload);
      }

      return DispatchMaster.fromJson(masterResponse);
    } catch (e) {
      throw Exception('Failed to update dispatch: $e');
    }
  }

  /// Delete a single dispatch item
  Future<void> deleteDispatchItem(String itemId) async {
    try {
      await _supabaseService.client
          .from('dispatch_items')
          .delete()
          .eq('id', itemId);
    } catch (e) {
      throw Exception('Failed to delete dispatch item: $e');
    }
  }
}
