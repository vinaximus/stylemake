/// DispatchItem model representing an item in a dispatch challan
class DispatchItem {
  DispatchItem({
    required this.id,
    required this.dispatchId,
    required this.styleId,
    this.color,
    this.size,
    required this.quantity,
    this.rate,
    this.remarks,
    required this.createdAt,
  });

  factory DispatchItem.fromJson(Map<String, dynamic> json) {
    return DispatchItem(
      id: json['id'] as String,
      dispatchId: json['dispatch_id'] as String,
      styleId: json['style_id'] as String,
      color: json['color'] as String?,
      size: json['size'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      rate: json['rate'] != null ? (json['rate'] as num).toDouble() : null,
      remarks: json['remarks'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String dispatchId;
  final String styleId;
  final String? color;
  final String? size;
  final double quantity;
  final double? rate;
  final String? remarks;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dispatch_id': dispatchId,
      'style_id': styleId,
      'color': color,
      'size': size,
      'quantity': quantity,
      'rate': rate,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DispatchItem copyWith({
    String? id,
    String? dispatchId,
    String? styleId,
    String? color,
    String? size,
    double? quantity,
    double? rate,
    String? remarks,
    DateTime? createdAt,
  }) {
    return DispatchItem(
      id: id ?? this.id,
      dispatchId: dispatchId ?? this.dispatchId,
      styleId: styleId ?? this.styleId,
      color: color ?? this.color,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DispatchItem(id: $id, dispatchId: $dispatchId, styleId: $styleId, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DispatchItem &&
        other.id == id &&
        other.dispatchId == dispatchId &&
        other.styleId == styleId;
  }

  @override
  int get hashCode => id.hashCode ^ dispatchId.hashCode ^ styleId.hashCode;
}
