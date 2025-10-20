/// Item Issue model
class ItemIssue {
  ItemIssue({
    required this.id,
    required this.issueDate,
    required this.poId,
    required this.itemDescription,
    required this.quantity,
    required this.rate,
    this.notes,
    required this.companyId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemIssue.fromJson(Map<String, dynamic> json) {
    return ItemIssue(
      id: json['id'] as String,
      issueDate: DateTime.parse(json['issue_date'] as String),
      poId: json['po_id'] as String,
      itemDescription: json['item_description'] as String,
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
  final DateTime issueDate;
  final String poId;
  final String itemDescription;
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
      'issue_date': issueDate.toIso8601String().split('T')[0], // DATE
      'po_id': poId,
      'item_description': itemDescription,
      'quantity': quantity,
      'rate': rate,
      'notes': notes,
      'company_id': companyId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ItemIssue copyWith({
    String? id,
    DateTime? issueDate,
    String? poId,
    String? itemDescription,
    int? quantity,
    double? rate,
    String? notes,
    String? companyId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItemIssue(
      id: id ?? this.id,
      issueDate: issueDate ?? this.issueDate,
      poId: poId ?? this.poId,
      itemDescription: itemDescription ?? this.itemDescription,
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
    return 'ItemIssue(id: $id, itemDescription: $itemDescription, poId: $poId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemIssue && other.id == id && other.poId == poId;
  }

  @override
  int get hashCode => id.hashCode ^ poId.hashCode;
}

/// Extended item issue model with joined data for display
class ItemIssueWithDetails extends ItemIssue {
  ItemIssueWithDetails({
    required super.id,
    required super.issueDate,
    required super.poId,
    required super.itemDescription,
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
  });

  factory ItemIssueWithDetails.fromJson(Map<String, dynamic> json) {
    // Extract nested data
    final po = json['fabrication_pos'] as Map<String, dynamic>?;
    final vendor = po?['vendors'] as Map<String, dynamic>?;
    final cutting = po?['cuttings'] as Map<String, dynamic>?;

    return ItemIssueWithDetails(
      id: json['id'] as String,
      issueDate: DateTime.parse(json['issue_date'] as String),
      poId: json['po_id'] as String,
      itemDescription: json['item_description'] as String,
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
    );
  }

  final String poNumber;
  final String vendorName;
  final String? cuttingRef;

  @override
  String toString() {
    return 'ItemIssueWithDetails(id: $id, itemDescription: $itemDescription, poNumber: $poNumber)';
  }
}
