import 'package:stylemake/core/models/bill.dart';
import 'package:stylemake/core/services/supabase_service.dart';

/// Repository for Bills (Supplier Invoices)
class BillRepository {
  final _supabase = SupabaseService.instance.client;

  // Default company and user IDs for v0.5 single-company mode
  static const String defaultCompanyId = '00000000-0000-0000-0000-000000000000';

  final _companyId = defaultCompanyId;
  final _userId = defaultCompanyId;

  /// Get all bills with details (JOIN with PO, vendor, cutting)
  Future<List<BillWithDetails>> getAllBills() async {
    try {
      final response = await _supabase
          .from('bills')
          .select('''
            *,
            fabrication_pos!inner(
              po_number,
              vendors!inner(id, name),
              cuttings!inner(cutting_ref)
            )
          ''')
          .eq('company_id', _companyId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => BillWithDetails.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bills: $e');
    }
  }

  /// Get single bill with details
  Future<BillWithDetails?> getBillById(String id) async {
    try {
      final response = await _supabase
          .from('bills')
          .select('''
            *,
            fabrication_pos!inner(
              po_number,
              vendors!inner(id, name),
              cuttings!inner(cutting_ref)
            )
          ''')
          .eq('id', id)
          .eq('company_id', _companyId)
          .maybeSingle();

      if (response == null) return null;

      return BillWithDetails.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch bill: $e');
    }
  }

  /// Get bills by PO ID
  Future<List<BillWithDetails>> getBillsByPo(String poId) async {
    try {
      final response = await _supabase
          .from('bills')
          .select('''
            *,
            fabrication_pos!inner(
              po_number,
              vendors!inner(id, name),
              cuttings!inner(cutting_ref)
            )
          ''')
          .eq('po_id', poId)
          .eq('company_id', _companyId)
          .order('invoice_date', ascending: false);

      return (response as List)
          .map((json) => BillWithDetails.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bills by PO: $e');
    }
  }

  /// Get bills by cutting ID (via POs linked to that cutting)
  Future<List<BillWithDetails>> getBillsByCutting(String cuttingId) async {
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

      // Then get all bills for these POs
      final response = await _supabase
          .from('bills')
          .select('''
            *,
            fabrication_pos!inner(
              po_number,
              vendors!inner(id, name),
              cuttings!inner(cutting_ref)
            )
          ''')
          .inFilter('po_id', poIds)
          .eq('company_id', _companyId)
          .order('invoice_date', ascending: false);

      return (response as List)
          .map((json) => BillWithDetails.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bills by cutting: $e');
    }
  }

  /// Get bills by vendor ID
  Future<List<BillWithDetails>> getBillsByVendor(String vendorId) async {
    try {
      // Get all POs for this vendor
      final posResponse = await _supabase
          .from('fabrication_pos')
          .select('id')
          .eq('vendor_id', vendorId)
          .eq('company_id', _companyId);

      final poIds = (posResponse as List)
          .map((po) => po['id'] as String)
          .toList();

      if (poIds.isEmpty) {
        return [];
      }

      // Then get all bills for these POs
      final response = await _supabase
          .from('bills')
          .select('''
            *,
            fabrication_pos!inner(
              po_number,
              vendors!inner(id, name),
              cuttings!inner(cutting_ref)
            )
          ''')
          .inFilter('po_id', poIds)
          .eq('company_id', _companyId)
          .order('invoice_date', ascending: false);

      return (response as List)
          .map((json) => BillWithDetails.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bills by vendor: $e');
    }
  }

  /// Get bills by date range
  Future<List<BillWithDetails>> getBillsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase
          .from('bills')
          .select('''
            *,
            fabrication_pos!inner(
              po_number,
              vendors!inner(id, name),
              cuttings!inner(cutting_ref)
            )
          ''')
          .gte('invoice_date', startDate.toIso8601String().split('T')[0])
          .lte('invoice_date', endDate.toIso8601String().split('T')[0])
          .eq('company_id', _companyId)
          .order('invoice_date', ascending: false);

      return (response as List)
          .map((json) => BillWithDetails.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bills by date range: $e');
    }
  }

  /// Create new bill
  Future<Bill> createBill({
    required String supplierInvoiceNo,
    required DateTime invoiceDate,
    required String poId,
    required int quantity,
    required double rate,
    String? notes,
  }) async {
    try {
      final data = {
        'supplier_invoice_no': supplierInvoiceNo,
        'invoice_date': invoiceDate.toIso8601String().split('T')[0],
        'po_id': poId,
        'quantity': quantity,
        'rate': rate,
        'notes': notes,
        'company_id': _companyId,
        'user_id': _userId,
      };

      final response = await _supabase
          .from('bills')
          .insert(data)
          .select()
          .single();

      return Bill.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create bill: $e');
    }
  }

  /// Update existing bill
  Future<Bill> updateBill({
    required String id,
    required String supplierInvoiceNo,
    required DateTime invoiceDate,
    required String poId,
    required int quantity,
    required double rate,
    String? notes,
  }) async {
    try {
      final data = {
        'supplier_invoice_no': supplierInvoiceNo,
        'invoice_date': invoiceDate.toIso8601String().split('T')[0],
        'po_id': poId,
        'quantity': quantity,
        'rate': rate,
        'notes': notes,
      };

      final response = await _supabase
          .from('bills')
          .update(data)
          .eq('id', id)
          .eq('company_id', _companyId)
          .select()
          .single();

      return Bill.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update bill: $e');
    }
  }

  /// Delete bill
  Future<void> deleteBill(String id) async {
    try {
      await _supabase
          .from('bills')
          .delete()
          .eq('id', id)
          .eq('company_id', _companyId);
    } catch (e) {
      throw Exception('Failed to delete bill: $e');
    }
  }
}
