/// Bill (Supplier Invoice) model
class Bill {
  Bill({
    required this.id,
    required this.supplierInvoiceNo,
    required this.invoiceDate,
    required this.poId,
    required this.quantity,
    required this.rate,
    this.notes,
    required this.companyId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      supplierInvoiceNo: json['supplier_invoice_no'] as String,
      invoiceDate: DateTime.parse(json['invoice_date'] as String),
      poId: json['po_id'] as String,
      quantity: json['quantity'] as int,
      rate: (json['rate'] as num).toDouble(),
      notes: json['notes'] as String?,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String supplierInvoiceNo;
  final DateTime invoiceDate;
  final String poId;
  final int quantity;
  final double rate;
  final String? notes;
  final String companyId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_invoice_no': supplierInvoiceNo,
      'invoice_date': invoiceDate.toIso8601String().split('T')[0], // DATE
      'po_id': poId,
      'quantity': quantity,
      'rate': rate,
      'notes': notes,
      'company_id': companyId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Bill copyWith({
    String? id,
    String? supplierInvoiceNo,
    DateTime? invoiceDate,
    String? poId,
    int? quantity,
    double? rate,
    String? notes,
    String? companyId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bill(
      id: id ?? this.id,
      supplierInvoiceNo: supplierInvoiceNo ?? this.supplierInvoiceNo,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      poId: poId ?? this.poId,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      notes: notes ?? this.notes,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate total amount
  double get totalAmount => quantity * rate;

  @override
  String toString() {
    return 'Bill(id: $id, supplierInvoiceNo: $supplierInvoiceNo, poId: $poId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Bill &&
        other.id == id &&
        other.supplierInvoiceNo == supplierInvoiceNo;
  }

  @override
  int get hashCode => id.hashCode ^ supplierInvoiceNo.hashCode;
}

/// Extended bill model with joined data for display
class BillWithDetails extends Bill {
  BillWithDetails({
    required super.id,
    required super.supplierInvoiceNo,
    required super.invoiceDate,
    required super.poId,
    required super.quantity,
    required super.rate,
    super.notes,
    required super.companyId,
    required super.userId,
    required super.createdAt,
    required super.updatedAt,
    required this.poNumber,
    required this.vendorName,
    this.cuttingRef,
    this.vendorId,
  });

  factory BillWithDetails.fromJson(Map<String, dynamic> json) {
    // Extract nested data
    final po = json['fabrication_pos'] as Map<String, dynamic>?;
    final vendor = po?['vendors'] as Map<String, dynamic>?;
    final cutting = po?['cuttings'] as Map<String, dynamic>?;

    return BillWithDetails(
      id: json['id'] as String,
      supplierInvoiceNo: json['supplier_invoice_no'] as String,
      invoiceDate: DateTime.parse(json['invoice_date'] as String),
      poId: json['po_id'] as String,
      quantity: json['quantity'] as int,
      rate: (json['rate'] as num).toDouble(),
      notes: json['notes'] as String?,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      poNumber: po?['po_number'] as String? ?? 'Unknown',
      vendorName: vendor?['name'] as String? ?? 'Unknown',
      cuttingRef: cutting?['cutting_ref'] as String?,
      vendorId: vendor?['id'] as String?,
    );
  }

  final String poNumber;
  final String vendorName;
  final String? cuttingRef;
  final String? vendorId;

  @override
  String toString() {
    return 'BillWithDetails(id: $id, supplierInvoiceNo: $supplierInvoiceNo, vendorName: $vendorName)';
  }
}
