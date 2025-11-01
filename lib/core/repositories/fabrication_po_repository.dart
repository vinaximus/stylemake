import 'package:stylemake/core/models/fabrication_po.dart';
import 'package:stylemake/core/repositories/po_order_item_repository.dart';
import 'package:stylemake/core/services/supabase_service.dart';
import 'package:stylemake/core/services/realtime_service.dart';
import 'package:stylemake/core/utils/error_handler.dart';
import 'package:stylemake/core/utils/performance_monitor.dart';

/// Repository for Fabrication Purchase Orders
class FabricationPoRepository {
  final _supabase = SupabaseService.instance.client;
  final _orderItemRepo = PoOrderItemRepository();

  // Default company and user IDs for v0.5 single-company mode
  static const String defaultCompanyId = '00000000-0000-0000-0000-000000000000';

  final _companyId = defaultCompanyId;
  final _userId = defaultCompanyId;

  /// Stream of POs with real-time updates
  Stream<List<FabricationPoWithDetails>> watchAllPos() async* {
    // First, yield the initial data
    try {
      final initialData = await getAllPos();
      yield initialData;
    } catch (e, stackTrace) {
      ErrorHandler.logError('watchAllPos - initial load', e, stackTrace);
      yield [];
    }

    // Then, listen for realtime updates and refresh data
    final realtimeStream = RealtimeService.instance.subscribeToCompanyTable(
      table: 'fabrication_pos',
    );

    await for (final _ in realtimeStream) {
      try {
        // Fetch fresh data whenever there's an update
        final freshData = await getAllPos();
        yield freshData;
      } catch (e, stackTrace) {
        ErrorHandler.logError('watchAllPos - realtime update', e, stackTrace);
        // Don't yield on error, keep the previous state
      }
    }
  }

  /// Get all POs with details (JOIN with cuttings, vendors, styles)
  Future<List<FabricationPoWithDetails>> getAllPos() async {
    return PerformanceMonitor.instance.measure('getAllPos', () async {
      try {
        final response = await _supabase
            .from('fabrication_pos')
            .select('''
            *,
            cuttings!inner(cutting_ref, style_id, styles!inner(name)),
            vendors!inner(name, gst, city)
          ''')
            .eq('company_id', _companyId)
            .order('created_at', ascending: false);

        return (response as List)
            .map((json) => FabricationPoWithDetails.fromJson(json))
            .toList();
      } catch (e) {
        throw Exception('Failed to fetch POs: $e');
      }
    });
  }

  /// Get single PO with details
  Future<FabricationPoWithDetails?> getPoWithDetails(String id) async {
    try {
      final response = await _supabase
          .from('fabrication_pos')
          .select('''
            *,
            cuttings!inner(cutting_ref, style_id, styles!inner(name)),
            vendors!inner(name, gst, city, address)
          ''')
          .eq('id', id)
          .eq('company_id', _companyId)
          .maybeSingle();

      if (response == null) return null;

      final po = FabricationPoWithDetails.fromJson(response);
      
      // Fetch order items
      try {
        final orderItems = await _orderItemRepo.getOrderItemsByPo(id);
        return FabricationPoWithDetails(
          id: po.id,
          poNumber: po.poNumber,
          cuttingId: po.cuttingId,
          jobOrderNo: po.jobOrderNo,
          vendorId: po.vendorId,
          fabricationType: po.fabricationType,
          dateOfIssue: po.dateOfIssue,
          completionDate: po.completionDate,
          instructions: po.instructions,
          companyId: po.companyId,
          userId: po.userId,
          createdAt: po.createdAt,
          updatedAt: po.updatedAt,
          cuttingRef: po.cuttingRef,
          vendorName: po.vendorName,
          styleName: po.styleName,
          vendorGst: po.vendorGst,
          vendorCity: po.vendorCity,
          orderItems: orderItems,
        );
      } catch (e) {
        // If order items fail to load, return PO without them
        ErrorHandler.logError('getPoWithDetails - order items', e, StackTrace.current);
        return po;
      }
    } catch (e) {
      throw Exception('Failed to fetch PO: $e');
    }
  }

  /// Get POs by cutting ID
  Future<List<FabricationPoWithDetails>> getPosByCutting(
    String cuttingId,
  ) async {
    try {
      final response = await _supabase
          .from('fabrication_pos')
          .select('''
            *,
            cuttings!inner(cutting_ref, style_id, styles!inner(name)),
            vendors!inner(name, gst, city)
          ''')
          .eq('cutting_id', cuttingId)
          .eq('company_id', _companyId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => FabricationPoWithDetails.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch POs by cutting: $e');
    }
  }

  /// Get POs by vendor ID
  Future<List<FabricationPoWithDetails>> getPosByVendor(String vendorId) async {
    try {
      final response = await _supabase
          .from('fabrication_pos')
          .select('''
            *,
            cuttings!inner(cutting_ref, style_id, styles!inner(name)),
            vendors!inner(name, gst, city)
          ''')
          .eq('vendor_id', vendorId)
          .eq('company_id', _companyId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => FabricationPoWithDetails.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch POs by vendor: $e');
    }
  }

  /// Get POs by fabrication type
  Future<List<FabricationPoWithDetails>> getPosByType(String type) async {
    try {
      final response = await _supabase
          .from('fabrication_pos')
          .select('''
            *,
            cuttings!inner(cutting_ref, style_id, styles!inner(name)),
            vendors!inner(name, gst, city)
          ''')
          .eq('fabrication_type', type)
          .eq('company_id', _companyId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => FabricationPoWithDetails.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch POs by type: $e');
    }
  }

  /// Get POs by date range
  Future<List<FabricationPoWithDetails>> getPosByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase
          .from('fabrication_pos')
          .select('''
            *,
            cuttings!inner(cutting_ref, style_id, styles!inner(name)),
            vendors!inner(name, gst, city)
          ''')
          .gte('date_of_issue', startDate.toIso8601String().split('T')[0])
          .lte('date_of_issue', endDate.toIso8601String().split('T')[0])
          .eq('company_id', _companyId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => FabricationPoWithDetails.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch POs by date range: $e');
    }
  }

  /// Generate next PO number
  Future<String> generatePoNumber() async {
    try {
      // Get the highest PO number for this company
      final response = await _supabase
          .from('fabrication_pos')
          .select('po_number')
          .eq('company_id', _companyId)
          .order('po_number', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        return 'PO-0001';
      }

      final lastPoNumber = response[0]['po_number'] as String;
      // Extract number part (e.g., "PO-0001" -> 1)
      final numberPart = lastPoNumber.split('-').last;
      final nextNumber = int.parse(numberPart) + 1;

      // Format with leading zeros (4 digits)
      return 'PO-${nextNumber.toString().padLeft(4, '0')}';
    } catch (e) {
      // If error, start from 0001
      return 'PO-0001';
    }
  }

  /// Create new PO
  Future<FabricationPo> createPo({
    required String poNumber,
    required String cuttingId,
    required String jobOrderNo,
    required String vendorId,
    required String fabricationType,
    required DateTime dateOfIssue,
    DateTime? completionDate,
    String? instructions,
  }) async {
    try {
      final data = {
        'po_number': poNumber,
        'cutting_id': cuttingId,
        'job_order_no': jobOrderNo,
        'vendor_id': vendorId,
        'fabrication_type': fabricationType,
        'date_of_issue': dateOfIssue.toIso8601String().split('T')[0],
        'completion_date': completionDate?.toIso8601String().split('T')[0],
        'instructions': instructions,
        'company_id': _companyId,
        'user_id': _userId,
      };

      final response = await _supabase
          .from('fabrication_pos')
          .insert(data)
          .select()
          .single();

      return FabricationPo.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create PO: $e');
    }
  }

  /// Update existing PO
  Future<FabricationPo> updatePo({
    required String id,
    required String cuttingId,
    required String jobOrderNo,
    required String vendorId,
    required String fabricationType,
    required DateTime dateOfIssue,
    DateTime? completionDate,
    String? instructions,
  }) async {
    try {
      final data = {
        'cutting_id': cuttingId,
        'job_order_no': jobOrderNo,
        'vendor_id': vendorId,
        'fabrication_type': fabricationType,
        'date_of_issue': dateOfIssue.toIso8601String().split('T')[0],
        'completion_date': completionDate?.toIso8601String().split('T')[0],
        'instructions': instructions,
      };

      final response = await _supabase
          .from('fabrication_pos')
          .update(data)
          .eq('id', id)
          .eq('company_id', _companyId)
          .select()
          .single();

      return FabricationPo.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update PO: $e');
    }
  }

  /// Delete PO
  Future<void> deletePo(String id) async {
    try {
      await _supabase
          .from('fabrication_pos')
          .delete()
          .eq('id', id)
          .eq('company_id', _companyId);
    } catch (e) {
      throw Exception('Failed to delete PO: $e');
    }
  }
}
