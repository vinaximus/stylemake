import 'package:stylemake/core/models/cutting.dart';
import 'package:stylemake/core/services/supabase_service.dart';
import 'package:stylemake/core/services/realtime_service.dart';
import 'package:stylemake/core/utils/error_handler.dart';
import 'package:stylemake/core/utils/performance_monitor.dart';

/// Repository for Cutting-related database operations
class CuttingRepository {
  CuttingRepository({SupabaseService? supabaseService})
    : _supabaseService = supabaseService ?? SupabaseService.instance;

  final SupabaseService _supabaseService;

  /// Default company ID for v0.5 single-company mode
  static const String defaultCompanyId = '00000000-0000-0000-0000-000000000000';

  /// Stream of cuttings with real-time updates
  Stream<List<CuttingWithStyle>> watchAllCuttings() async* {
    // First, yield the initial data
    try {
      final initialData = await getAllCuttings();
      yield initialData;
    } catch (e, stackTrace) {
      ErrorHandler.logError('watchAllCuttings - initial load', e, stackTrace);
      yield [];
    }

    // Then, listen for realtime updates and refresh data
    final realtimeStream = RealtimeService.instance.subscribeToCompanyTable(
      table: 'cuttings',
    );

    await for (final _ in realtimeStream) {
      try {
        // Fetch fresh data whenever there's an update
        final freshData = await getAllCuttings();
        yield freshData;
      } catch (e, stackTrace) {
        ErrorHandler.logError(
          'watchAllCuttings - realtime update',
          e,
          stackTrace,
        );
        // Don't yield on error, keep the previous state
      }
    }
  }

  /// Fetch all cuttings for the current company, ordered by date descending
  Future<List<CuttingWithStyle>> getAllCuttings() async {
    return PerformanceMonitor.instance.measure('getAllCuttings', () async {
      try {
        final response = await _supabaseService.client
            .from('cuttings')
            .select('*, styles!inner(name)')
            .eq('company_id', defaultCompanyId)
            .order('cutting_date', ascending: false);

        final data = response as List<dynamic>;
        return data.map((json) {
          final map = json as Map<String, dynamic>;
          // Extract style name from nested object
          final styleName =
              (map['styles'] as Map<String, dynamic>)['name'] as String;
          return CuttingWithStyle.fromJson({...map, 'style_name': styleName});
        }).toList();
      } catch (e) {
        throw Exception('Failed to fetch cuttings: $e');
      }
    });
  }

  /// Get a single cutting by ID
  Future<Cutting?> getCuttingById(String id) async {
    try {
      final response = await _supabaseService.client
          .from('cuttings')
          .select()
          .eq('id', id)
          .eq('company_id', defaultCompanyId)
          .maybeSingle();

      if (response == null) return null;

      return Cutting.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch cutting: $e');
    }
  }

  /// Get a single cutting by ID with style name
  Future<CuttingWithStyle?> getCuttingWithStyle(String id) async {
    try {
      final response = await _supabaseService.client
          .from('cuttings')
          .select('*, styles!inner(name)')
          .eq('id', id)
          .eq('company_id', defaultCompanyId)
          .maybeSingle();

      if (response == null) return null;

      final map = response;
      final styleName =
          (map['styles'] as Map<String, dynamic>)['name'] as String;
      return CuttingWithStyle.fromJson({...map, 'style_name': styleName});
    } catch (e) {
      throw Exception('Failed to fetch cutting with style: $e');
    }
  }

  /// Create a new cutting
  Future<Cutting> createCutting({
    required String cuttingRef,
    required DateTime cuttingDate,
    required int quantityCut,
    required String styleId,
    String? notes,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('cuttings')
          .insert({
            'cutting_ref': cuttingRef,
            'cutting_date': cuttingDate.toIso8601String().split('T')[0],
            'quantity_cut': quantityCut,
            'style_id': styleId,
            'notes': notes,
            'company_id': defaultCompanyId,
            'user_id': defaultCompanyId,
          })
          .select()
          .single();

      return Cutting.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create cutting: $e');
    }
  }

  /// Update an existing cutting
  Future<Cutting> updateCutting({
    required String id,
    required String cuttingRef,
    required DateTime cuttingDate,
    required int quantityCut,
    required String styleId,
    String? notes,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('cuttings')
          .update({
            'cutting_ref': cuttingRef,
            'cutting_date': cuttingDate.toIso8601String().split('T')[0],
            'quantity_cut': quantityCut,
            'style_id': styleId,
            'notes': notes,
          })
          .eq('id', id)
          .eq('company_id', defaultCompanyId)
          .select()
          .single();

      return Cutting.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update cutting: $e');
    }
  }

  /// Delete a cutting
  Future<void> deleteCutting(String id) async {
    try {
      await _supabaseService.client
          .from('cuttings')
          .delete()
          .eq('id', id)
          .eq('company_id', defaultCompanyId);
    } catch (e) {
      throw Exception('Failed to delete cutting: $e');
    }
  }

  /// Search cuttings by cutting reference
  Future<List<CuttingWithStyle>> searchCuttings(String query) async {
    try {
      final response = await _supabaseService.client
          .from('cuttings')
          .select('*, styles!inner(name)')
          .eq('company_id', defaultCompanyId)
          .ilike('cutting_ref', '%$query%')
          .order('cutting_date', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) {
        final map = json as Map<String, dynamic>;
        final styleName =
            (map['styles'] as Map<String, dynamic>)['name'] as String;
        return CuttingWithStyle.fromJson({...map, 'style_name': styleName});
      }).toList();
    } catch (e) {
      throw Exception('Failed to search cuttings: $e');
    }
  }

  /// Filter cuttings by style
  Future<List<CuttingWithStyle>> filterByStyle(String styleId) async {
    try {
      final response = await _supabaseService.client
          .from('cuttings')
          .select('*, styles!inner(name)')
          .eq('company_id', defaultCompanyId)
          .eq('style_id', styleId)
          .order('cutting_date', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) {
        final map = json as Map<String, dynamic>;
        final styleName =
            (map['styles'] as Map<String, dynamic>)['name'] as String;
        return CuttingWithStyle.fromJson({...map, 'style_name': styleName});
      }).toList();
    } catch (e) {
      throw Exception('Failed to filter cuttings by style: $e');
    }
  }

  /// Filter cuttings by date range
  Future<List<CuttingWithStyle>> filterByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabaseService.client
          .from('cuttings')
          .select('*, styles!inner(name)')
          .eq('company_id', defaultCompanyId)
          .gte('cutting_date', startDate.toIso8601String().split('T')[0])
          .lte('cutting_date', endDate.toIso8601String().split('T')[0])
          .order('cutting_date', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) {
        final map = json as Map<String, dynamic>;
        final styleName =
            (map['styles'] as Map<String, dynamic>)['name'] as String;
        return CuttingWithStyle.fromJson({...map, 'style_name': styleName});
      }).toList();
    } catch (e) {
      throw Exception('Failed to filter cuttings by date range: $e');
    }
  }
}
