import 'package:stylemake/core/models/po_order_item.dart';
import 'package:stylemake/core/services/supabase_service.dart';
import 'package:stylemake/core/utils/error_handler.dart';

/// Repository for PO Order Items
class PoOrderItemRepository {
  final _supabase = SupabaseService.instance.client;

  // Default company and user IDs for v0.5 single-company mode
  static const String defaultCompanyId = '00000000-0000-0000-0000-000000000000';

  final _companyId = defaultCompanyId;
  final _userId = defaultCompanyId;

  /// Get all order items for a PO
  Future<List<PoOrderItem>> getOrderItemsByPo(String poId) async {
    try {
      final response = await _supabase
          .from('po_order_items')
          .select()
          .eq('po_id', poId)
          .eq('company_id', _companyId)
          .order('display_order', ascending: true)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => PoOrderItem.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch order items: $e');
    }
  }

  /// Create a new order item
  Future<PoOrderItem> createOrderItem({
    required String poId,
    required String orderDescription,
    required int quantity,
    required double rate,
    String? note,
    int? displayOrder,
  }) async {
    try {
      final data = {
        'po_id': poId,
        'order_description': orderDescription,
        'quantity': quantity,
        'rate': rate,
        'note': note,
        'display_order': displayOrder ?? 0,
        'company_id': _companyId,
        'user_id': _userId,
      };

      final response = await _supabase
          .from('po_order_items')
          .insert(data)
          .select()
          .single();

      return PoOrderItem.fromJson(response);
    } catch (e) {
      ErrorHandler.logError('createOrderItem', e, StackTrace.current);
      throw Exception('Failed to create order item: $e');
    }
  }

  /// Create multiple order items at once
  Future<List<PoOrderItem>> createOrderItems({
    required String poId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final data = items.map((item) {
        return {
          'po_id': poId,
          'order_description': item['order_description'] as String,
          'quantity': item['quantity'] as int,
          'rate': item['rate'] as double,
          'note': item['note'] as String?,
          'display_order': item['display_order'] as int? ?? 0,
          'company_id': _companyId,
          'user_id': _userId,
        };
      }).toList();

      final response = await _supabase
          .from('po_order_items')
          .insert(data)
          .select();

      return (response as List)
          .map((json) => PoOrderItem.fromJson(json))
          .toList();
    } catch (e) {
      ErrorHandler.logError('createOrderItems', e, StackTrace.current);
      throw Exception('Failed to create order items: $e');
    }
  }

  /// Update an existing order item
  Future<PoOrderItem> updateOrderItem({
    required String id,
    required String orderDescription,
    required int quantity,
    required double rate,
    String? note,
    int? displayOrder,
  }) async {
    try {
      final data = {
        'order_description': orderDescription,
        'quantity': quantity,
        'rate': rate,
        'note': note,
        if (displayOrder != null) 'display_order': displayOrder,
      };

      final response = await _supabase
          .from('po_order_items')
          .update(data)
          .eq('id', id)
          .eq('company_id', _companyId)
          .select()
          .single();

      return PoOrderItem.fromJson(response);
    } catch (e) {
      ErrorHandler.logError('updateOrderItem', e, StackTrace.current);
      throw Exception('Failed to update order item: $e');
    }
  }

  /// Delete an order item
  Future<void> deleteOrderItem(String id) async {
    try {
      await _supabase
          .from('po_order_items')
          .delete()
          .eq('id', id)
          .eq('company_id', _companyId);
    } catch (e) {
      ErrorHandler.logError('deleteOrderItem', e, StackTrace.current);
      throw Exception('Failed to delete order item: $e');
    }
  }

  /// Delete all order items for a PO
  Future<void> deleteOrderItemsByPo(String poId) async {
    try {
      await _supabase
          .from('po_order_items')
          .delete()
          .eq('po_id', poId)
          .eq('company_id', _companyId);
    } catch (e) {
      ErrorHandler.logError('deleteOrderItemsByPo', e, StackTrace.current);
      throw Exception('Failed to delete order items: $e');
    }
  }

  /// Replace all order items for a PO (delete existing and create new)
  Future<List<PoOrderItem>> replaceOrderItems({
    required String poId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      // Delete existing items
      await deleteOrderItemsByPo(poId);

      // Create new items
      if (items.isEmpty) {
        return [];
      }

      return await createOrderItems(poId: poId, items: items);
    } catch (e) {
      ErrorHandler.logError('replaceOrderItems', e, StackTrace.current);
      throw Exception('Failed to replace order items: $e');
    }
  }
}

