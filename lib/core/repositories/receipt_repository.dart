import 'package:stylemake/core/models/receipt.dart';
import 'package:stylemake/core/services/supabase_service.dart';

/// Repository for Receipts (Finished Goods)
class ReceiptRepository {
  final _supabase = SupabaseService.instance.client;

  // Default company and user IDs for v0.5 single-company mode
  static const String defaultCompanyId = '00000000-0000-0000-0000-000000000000';

  final _companyId = defaultCompanyId;
  final _userId = defaultCompanyId;

  Future<List<ReceiptWithDetails>> getAllReceipts({
    DateTime? from,
    DateTime? to,
    String? styleId,
  }) async {
    try {
      var query = _supabase
          .from('receipts')
          .select('''
            *,
            cuttings!inner(cutting_ref),
            styles!inner(name)
          ''')
          .eq('company_id', _companyId);

      if (from != null) {
        query = query.gte('date_of_receipt', from.toIso8601String().split('T')[0]);
      }
      if (to != null) {
        query = query.lte('date_of_receipt', to.toIso8601String().split('T')[0]);
      }
      if (styleId != null) {
        query = query.eq('style_id', styleId);
      }

      final response = await query.order('date_of_receipt', ascending: false);
      return (response as List)
          .map((json) => ReceiptWithDetails.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch receipts: $e');
    }
  }

  Future<List<ReceiptWithDetails>> getReceiptsByCutting(String cuttingId) async {
    try {
      final response = await _supabase
          .from('receipts')
          .select('''
            *,
            cuttings!inner(cutting_ref),
            styles!inner(name)
          ''')
          .eq('cutting_id', cuttingId)
          .eq('company_id', _companyId)
          .order('date_of_receipt', ascending: false);

      return (response as List)
          .map((json) => ReceiptWithDetails.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch receipts by cutting: $e');
    }
  }

  Future<ReceiptWithDetails?> getReceiptById(String id) async {
    try {
      final response = await _supabase
          .from('receipts')
          .select('''
            *,
            cuttings!inner(cutting_ref),
            styles!inner(name)
          ''')
          .eq('id', id)
          .eq('company_id', _companyId)
          .maybeSingle();

      if (response == null) return null;
      return ReceiptWithDetails.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch receipt: $e');
    }
  }

  Future<String> generateNextReceiptId() async {
    // Simple client-side sequence: REC-0001, REC-0002 ...
    try {
      final response = await _supabase
          .from('receipts')
          .select('receipt_id')
          .eq('company_id', _companyId)
          .order('created_at', ascending: false)
          .limit(1);

      int next = 1;
      if ((response as List).isNotEmpty) {
        final last = response.first['receipt_id'] as String;
        final parts = last.split('-');
        if (parts.length == 2) {
          next = int.tryParse(parts[1]) != null ? int.parse(parts[1]) + 1 : 1;
        }
      }
      return 'REC-${next.toString().padLeft(4, '0')}';
    } catch (_) {
      return 'REC-0001';
    }
  }

  Future<Receipt> createReceipt({
    required String cuttingId,
    required String styleId,
    required int quantityReceived,
    required DateTime dateOfReceipt,
    String? notes,
  }) async {
    try {
      final receiptId = await generateNextReceiptId();
      final data = {
        'receipt_id': receiptId,
        'cutting_id': cuttingId,
        'style_id': styleId,
        'quantity_received': quantityReceived,
        'date_of_receipt': dateOfReceipt.toIso8601String().split('T')[0],
        'notes': notes,
        'company_id': _companyId,
        'user_id': _userId,
      };

      final response = await _supabase.from('receipts').insert(data).select().single();
      return Receipt.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create receipt: $e');
    }
  }

  Future<Receipt> updateReceipt({
    required String id,
    required String cuttingId,
    required String styleId,
    required int quantityReceived,
    required DateTime dateOfReceipt,
    String? notes,
  }) async {
    try {
      final data = {
        'cutting_id': cuttingId,
        'style_id': styleId,
        'quantity_received': quantityReceived,
        'date_of_receipt': dateOfReceipt.toIso8601String().split('T')[0],
        'notes': notes,
      };

      final response = await _supabase
          .from('receipts')
          .update(data)
          .eq('id', id)
          .eq('company_id', _companyId)
          .select()
          .single();

      return Receipt.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update receipt: $e');
    }
  }

  Future<void> deleteReceipt(String id) async {
    try {
      await _supabase
          .from('receipts')
          .delete()
          .eq('id', id)
          .eq('company_id', _companyId);
    } catch (e) {
      throw Exception('Failed to delete receipt: $e');
    }
  }
}


