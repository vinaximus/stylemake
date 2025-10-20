import 'package:stylemake/core/models/item_issue.dart';
import 'package:stylemake/core/services/supabase_service.dart';

/// Repository for Item Issues
class ItemIssueRepository {
  final _supabase = SupabaseService.instance.client;

  // Default company and user IDs for v0.5 single-company mode
  static const String defaultCompanyId = '00000000-0000-0000-0000-000000000000';

  final _companyId = defaultCompanyId;
  final _userId = defaultCompanyId;

  /// Get all issues with details (JOIN with PO, vendor, cutting)
  Future<List<ItemIssueWithDetails>> getAllIssues() async {
    try {
      final response = await _supabase
          .from('item_issues')
          .select('''
            *,
            fabrication_pos!inner(
              po_number,
              vendors!inner(name),
              cuttings!inner(cutting_ref)
            )
          ''')
          .eq('company_id', _companyId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ItemIssueWithDetails.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch issues: $e');
    }
  }

  /// Get single issue with details
  Future<ItemIssueWithDetails?> getIssueById(String id) async {
    try {
      final response = await _supabase
          .from('item_issues')
          .select('''
            *,
            fabrication_pos!inner(
              po_number,
              vendors!inner(name),
              cuttings!inner(cutting_ref)
            )
          ''')
          .eq('id', id)
          .eq('company_id', _companyId)
          .maybeSingle();

      if (response == null) return null;

      return ItemIssueWithDetails.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch issue: $e');
    }
  }

  /// Get issues by PO ID
  Future<List<ItemIssueWithDetails>> getIssuesByPo(String poId) async {
    try {
      final response = await _supabase
          .from('item_issues')
          .select('''
            *,
            fabrication_pos!inner(
              po_number,
              vendors!inner(name),
              cuttings!inner(cutting_ref)
            )
          ''')
          .eq('po_id', poId)
          .eq('company_id', _companyId)
          .order('issue_date', ascending: false);

      return (response as List)
          .map((json) => ItemIssueWithDetails.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch issues by PO: $e');
    }
  }

  /// Get issues by cutting ID (via POs linked to that cutting)
  Future<List<ItemIssueWithDetails>> getIssuesByCutting(
    String cuttingId,
  ) async {
    try {
      // First get all POs for this cutting
      final posResponse = await _supabase
          .from('fabrication_pos')
          .select('id')
          .eq('cutting_id', cuttingId)
          .eq('company_id', _companyId);

      final poIds = (posResponse as List)
          .map((po) => po['id'] as String)
          .toList();

      if (poIds.isEmpty) {
        return [];
      }

      // Then get all issues for these POs
      final response = await _supabase
          .from('item_issues')
          .select('''
            *,
            fabrication_pos!inner(
              po_number,
              vendors!inner(name),
              cuttings!inner(cutting_ref)
            )
          ''')
          .inFilter('po_id', poIds)
          .eq('company_id', _companyId)
          .order('issue_date', ascending: false);

      return (response as List)
          .map((json) => ItemIssueWithDetails.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch issues by cutting: $e');
    }
  }

  /// Get issues by date range
  Future<List<ItemIssueWithDetails>> getIssuesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase
          .from('item_issues')
          .select('''
            *,
            fabrication_pos!inner(
              po_number,
              vendors!inner(name),
              cuttings!inner(cutting_ref)
            )
          ''')
          .gte('issue_date', startDate.toIso8601String().split('T')[0])
          .lte('issue_date', endDate.toIso8601String().split('T')[0])
          .eq('company_id', _companyId)
          .order('issue_date', ascending: false);

      return (response as List)
          .map((json) => ItemIssueWithDetails.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch issues by date range: $e');
    }
  }

  /// Create new issue
  Future<ItemIssue> createIssue({
    required DateTime issueDate,
    required String poId,
    required String itemDescription,
    required int quantity,
    required double rate,
    String? notes,
  }) async {
    try {
      final data = {
        'issue_date': issueDate.toIso8601String().split('T')[0],
        'po_id': poId,
        'item_description': itemDescription,
        'quantity': quantity,
        'rate': rate,
        'notes': notes,
        'company_id': _companyId,
        'user_id': _userId,
      };

      final response = await _supabase
          .from('item_issues')
          .insert(data)
          .select()
          .single();

      return ItemIssue.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create issue: $e');
    }
  }

  /// Update existing issue
  Future<ItemIssue> updateIssue({
    required String id,
    required DateTime issueDate,
    required String poId,
    required String itemDescription,
    required int quantity,
    required double rate,
    String? notes,
  }) async {
    try {
      final data = {
        'issue_date': issueDate.toIso8601String().split('T')[0],
        'po_id': poId,
        'item_description': itemDescription,
        'quantity': quantity,
        'rate': rate,
        'notes': notes,
      };

      final response = await _supabase
          .from('item_issues')
          .update(data)
          .eq('id', id)
          .eq('company_id', _companyId)
          .select()
          .single();

      return ItemIssue.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update issue: $e');
    }
  }

  /// Delete issue
  Future<void> deleteIssue(String id) async {
    try {
      await _supabase
          .from('item_issues')
          .delete()
          .eq('id', id)
          .eq('company_id', _companyId);
    } catch (e) {
      throw Exception('Failed to delete issue: $e');
    }
  }
}
