/// Purchase Order Order Item model
class PoOrderItem {
  PoOrderItem({
    required this.id,
    required this.poId,
    required this.orderDescription,
    required this.quantity,
    required this.rate,
    this.note,
    this.displayOrder = 0,
    required this.companyId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PoOrderItem.fromJson(Map<String, dynamic> json) {
    return PoOrderItem(
      id: json['id'] as String,
      poId: json['po_id'] as String,
      orderDescription: json['order_description'] as String,
      quantity: json['quantity'] as int,
      rate: (json['rate'] as num).toDouble(),
      note: json['note'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String poId;
  final String orderDescription;
  final int quantity;
  final double rate;
  final String? note;
  final int displayOrder;
  final String companyId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'po_id': poId,
      'order_description': orderDescription,
      'quantity': quantity,
      'rate': rate,
      'note': note,
      'display_order': displayOrder,
      'company_id': companyId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForInsert() {
    return {
      'po_id': poId,
      'order_description': orderDescription,
      'quantity': quantity,
      'rate': rate,
      'note': note,
      'display_order': displayOrder,
      'company_id': companyId,
      'user_id': userId,
    };
  }

  PoOrderItem copyWith({
    String? id,
    String? poId,
    String? orderDescription,
    int? quantity,
    double? rate,
    String? note,
    int? displayOrder,
    String? companyId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PoOrderItem(
      id: id ?? this.id,
      poId: poId ?? this.poId,
      orderDescription: orderDescription ?? this.orderDescription,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      note: note ?? this.note,
      displayOrder: displayOrder ?? this.displayOrder,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate total amount for this item
  double get totalAmount => quantity * rate;

  @override
  String toString() {
    return 'PoOrderItem(id: $id, description: $orderDescription, qty: $quantity, rate: $rate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PoOrderItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

