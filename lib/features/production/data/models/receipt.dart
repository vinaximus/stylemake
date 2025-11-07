/// Receipt (Finished Goods) model
class Receipt {
  Receipt({
    required this.id,
    required this.receiptId,
    required this.cuttingId,
    required this.styleId,
    required this.quantityReceived,
    required this.dateOfReceipt,
    this.notes,
    required this.companyId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String,
      receiptId: json['receipt_id'] as String,
      cuttingId: json['cutting_id'] as String,
      styleId: json['style_id'] as String,
      quantityReceived: json['quantity_received'] as int,
      dateOfReceipt: DateTime.parse(json['date_of_receipt'] as String),
      notes: json['notes'] as String?,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String receiptId;
  final String cuttingId;
  final String styleId;
  final int quantityReceived;
  final DateTime dateOfReceipt;
  final String? notes;
  final String companyId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receipt_id': receiptId,
      'cutting_id': cuttingId,
      'style_id': styleId,
      'quantity_received': quantityReceived,
      'date_of_receipt': dateOfReceipt.toIso8601String().split('T')[0],
      'notes': notes,
      'company_id': companyId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Receipt copyWith({
    String? id,
    String? receiptId,
    String? cuttingId,
    String? styleId,
    int? quantityReceived,
    DateTime? dateOfReceipt,
    String? notes,
    String? companyId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      cuttingId: cuttingId ?? this.cuttingId,
      styleId: styleId ?? this.styleId,
      quantityReceived: quantityReceived ?? this.quantityReceived,
      dateOfReceipt: dateOfReceipt ?? this.dateOfReceipt,
      notes: notes ?? this.notes,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Extended receipt model with joined data for display
class ReceiptWithDetails extends Receipt {
  ReceiptWithDetails({
    required super.id,
    required super.receiptId,
    required super.cuttingId,
    required super.styleId,
    required super.quantityReceived,
    required super.dateOfReceipt,
    super.notes,
    required super.companyId,
    required super.userId,
    required super.createdAt,
    required super.updatedAt,
    required this.cuttingRef,
    required this.styleName,
  });

  factory ReceiptWithDetails.fromJson(Map<String, dynamic> json) {
    final cutting = json['cuttings'] as Map<String, dynamic>?;
    final style = json['styles'] as Map<String, dynamic>?;
    return ReceiptWithDetails(
      id: json['id'] as String,
      receiptId: json['receipt_id'] as String,
      cuttingId: json['cutting_id'] as String,
      styleId: json['style_id'] as String,
      quantityReceived: json['quantity_received'] as int,
      dateOfReceipt: DateTime.parse(json['date_of_receipt'] as String),
      notes: json['notes'] as String?,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      cuttingRef: cutting?['cutting_ref'] as String? ?? 'Unknown',
      styleName: style?['name'] as String? ?? 'Unknown',
    );
  }

  final String cuttingRef;
  final String styleName;
}


