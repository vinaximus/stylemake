import 'package:stylemake/core/services/supabase_service.dart';

class ProductionSummaryTotals {
  ProductionSummaryTotals({
    required this.qtyCut,
    required this.qtyIssued,
    required this.qtyReceived,
    required this.totalBillCost,
  });

  final int qtyCut;
  final int qtyIssued;
  final int qtyReceived;
  final double totalBillCost;
}

class ProductionSummaryRepository {
  final _supabase = SupabaseService.instance.client;
  static const String defaultCompanyId = '00000000-0000-0000-0000-000000000000';
  final _companyId = defaultCompanyId;

  Future<ProductionSummaryTotals> getTotals({
    required DateTime from,
    required DateTime to,
    String? styleId,
  }) async {
    final fromStr = from.toIso8601String().split('T')[0];
    final toStr = to.toIso8601String().split('T')[0];

    // qty cut from cuttings
    final cuttings = await _supabase
        .from('cuttings')
        .select('quantity_cut, style_id')
        .eq('company_id', _companyId)
        .gte('cutting_date', fromStr)
        .lte('cutting_date', toStr);

    // qty issued from po_order_items (sum of quantities)
    final pos = await _supabase
        .from('fabrication_pos')
        .select('id, style_id:cuttings(style_id), cuttings!inner(style_id), po_order_items(quantity)')
        .eq('company_id', _companyId)
        .gte('date_of_issue', fromStr)
        .lte('date_of_issue', toStr);

    // qty received from receipts
    final receipts = await _supabase
        .from('receipts')
        .select('quantity_received, style_id')
        .eq('company_id', _companyId)
        .gte('date_of_receipt', fromStr)
        .lte('date_of_receipt', toStr);

    // total bill cost from bills
    final bills = await _supabase
        .from('bills')
        .select('quantity, rate, po_id, fabrication_pos!inner(cuttings!inner(style_id))')
        .eq('company_id', _companyId)
        .gte('invoice_date', fromStr)
        .lte('invoice_date', toStr);

    int qtyCut = 0;
    int qtyIssued = 0;
    int qtyReceived = 0;
    double totalBillCost = 0;

    for (final c in cuttings as List) {
      if (styleId == null || c['style_id'] == styleId) {
        qtyCut += (c['quantity_cut'] as int);
      }
    }
    for (final p in pos as List) {
      // style_id is via join on cuttings
      final cut = (p['cuttings'] as Map<String, dynamic>?);
      final sid = cut?['style_id'] as String?;
      if (styleId == null || sid == styleId) {
        // Sum quantities from order items
        final orderItems = p['po_order_items'] as List?;
        if (orderItems != null) {
          for (final item in orderItems) {
            qtyIssued += (item['quantity'] as int? ?? 0);
          }
        }
      }
    }
    for (final r in receipts as List) {
      if (styleId == null || r['style_id'] == styleId) {
        qtyReceived += (r['quantity_received'] as int);
      }
    }
    for (final b in bills as List) {
      final fp = b['fabrication_pos'] as Map<String, dynamic>?;
      final cut = fp?['cuttings'] as Map<String, dynamic>?;
      final sid = cut?['style_id'] as String?;
      if (styleId == null || sid == styleId) {
        totalBillCost += (b['quantity'] as int) * (b['rate'] as num).toDouble();
      }
    }

    return ProductionSummaryTotals(
      qtyCut: qtyCut,
      qtyIssued: qtyIssued,
      qtyReceived: qtyReceived,
      totalBillCost: totalBillCost,
    );
  }
}


