import 'package:stylemake/core/models/style.dart';
import 'package:stylemake/core/services/supabase_service.dart';
import 'package:stylemake/core/services/realtime_service.dart';
import 'package:stylemake/core/utils/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for Style-related database operations
class StyleRepository {
  StyleRepository({SupabaseService? supabaseService})
    : _supabaseService = supabaseService ?? SupabaseService.instance;

  final SupabaseService _supabaseService;

  /// Default company ID for v0.5 single-company mode
  static const String defaultCompanyId = '00000000-0000-0000-0000-000000000000';

  /// Stream of styles with real-time updates
  Stream<List<Style>> watchAllStyles() async* {
    // First, yield the initial data
    try {
      final initialData = await getAllStyles();
      yield initialData;
    } catch (e, stackTrace) {
      ErrorHandler.logError('watchAllStyles - initial load', e, stackTrace);
      yield [];
    }

    // Then, listen for realtime updates and refresh data
    final realtimeStream = RealtimeService.instance.subscribeToCompanyTable(
      table: 'styles',
    );

    await for (final _ in realtimeStream) {
      try {
        // Fetch fresh data whenever there's an update
        final freshData = await getAllStyles();
        yield freshData;
      } catch (e, stackTrace) {
        ErrorHandler.logError(
          'watchAllStyles - realtime update',
          e,
          stackTrace,
        );
        // Don't yield on error, keep the previous state
      }
    }
  }

  /// Fetch all styles for the current company
  Future<List<Style>> getAllStyles() async {
    try {
      final response = await _supabaseService.client
          .from('styles')
          .select()
          .eq('company_id', defaultCompanyId)
          .order('name');

      final data = response as List<dynamic>;
      return data
          .map((json) => Style.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch styles: $e');
    }
  }

  /// Get a single style by ID
  Future<Style?> getStyleById(String id) async {
    try {
      final response = await _supabaseService.client
          .from('styles')
          .select()
          .eq('id', id)
          .eq('company_id', defaultCompanyId)
          .maybeSingle();

      if (response == null) return null;

      return Style.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch style: $e');
    }
  }

  /// Get count of styles
  Future<int> getStylesCount() async {
    try {
      final response = await _supabaseService.client
          .from('styles')
          .select()
          .eq('company_id', defaultCompanyId)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      throw Exception('Failed to count styles: $e');
    }
  }

  /// Create a new style
  Future<Style> createStyle({required String name, String? designer}) async {
    try {
      final response = await _supabaseService.client
          .from('styles')
          .insert({
            'name': name,
            'designer': designer,
            'company_id': defaultCompanyId,
            'user_id': defaultCompanyId,
          })
          .select()
          .single();

      return Style.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create style: $e');
    }
  }

  /// Update an existing style
  Future<Style> updateStyle({
    required String id,
    required String name,
    String? designer,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('styles')
          .update({'name': name, 'designer': designer})
          .eq('id', id)
          .eq('company_id', defaultCompanyId)
          .select()
          .single();

      return Style.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update style: $e');
    }
  }

  /// Delete a style
  Future<void> deleteStyle(String id) async {
    try {
      await _supabaseService.client
          .from('styles')
          .delete()
          .eq('id', id)
          .eq('company_id', defaultCompanyId);
    } catch (e) {
      throw Exception('Failed to delete style: $e');
    }
  }

  /// Check if a style can be deleted (not referenced in other tables)
  Future<bool> canDeleteStyle(String id) async {
    try {
      // Check cuttings table
      final cuttingsResponse = await _supabaseService.client
          .from('cuttings')
          .select('id')
          .eq('style_id', id)
          .limit(1);

      if (cuttingsResponse.isNotEmpty) return false;

      // Check dispatch_items table
      final dispatchResponse = await _supabaseService.client
          .from('dispatch_items')
          .select('id')
          .eq('style_id', id)
          .limit(1);

      if (dispatchResponse.isNotEmpty) return false;

      // Check receipts table
      final receiptsResponse = await _supabaseService.client
          .from('receipts')
          .select('id')
          .eq('style_id', id)
          .limit(1);

      if (receiptsResponse.isNotEmpty) return false;

      return true;
    } catch (e) {
      throw Exception('Failed to check style references: $e');
    }
  }

  /// Get unique designers from all styles
  Future<List<String>> getUniqueDesigners() async {
    try {
      final response = await _supabaseService.client
          .from('styles')
          .select('designer')
          .eq('company_id', defaultCompanyId)
          .not('designer', 'is', null)
          .order('designer');

      final data = response as List<dynamic>;
      return data
          .map((json) => json['designer'] as String)
          .where((designer) => designer.isNotEmpty)
          .toSet()
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch unique designers: $e');
    }
  }
}
