import 'package:stylemake/core/models/style.dart';
import 'package:stylemake/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for Style-related database operations
class StyleRepository {
  StyleRepository({SupabaseService? supabaseService})
    : _supabaseService = supabaseService ?? SupabaseService.instance;

  final SupabaseService _supabaseService;

  /// Default company ID for v0.5 single-company mode
  static const String defaultCompanyId = '00000000-0000-0000-0000-000000000000';

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
  Future<Style> createStyle({required String name}) async {
    try {
      final response = await _supabaseService.client
          .from('styles')
          .insert({
            'name': name,
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
  Future<Style> updateStyle({required String id, required String name}) async {
    try {
      final response = await _supabaseService.client
          .from('styles')
          .update({'name': name})
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
}
