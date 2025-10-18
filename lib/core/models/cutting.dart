/// Cutting model representing a fabric cutting record
class Cutting {
  Cutting({
    required this.id,
    required this.cuttingRef,
    required this.cuttingDate,
    required this.quantityCut,
    required this.styleId,
    this.notes,
    required this.companyId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cutting.fromJson(Map<String, dynamic> json) {
    return Cutting(
      id: json['id'] as String,
      cuttingRef: json['cutting_ref'] as String,
      cuttingDate: DateTime.parse(json['cutting_date'] as String),
      quantityCut: json['quantity_cut'] as int,
      styleId: json['style_id'] as String,
      notes: json['notes'] as String?,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String cuttingRef;
  final DateTime cuttingDate;
  final int quantityCut;
  final String styleId;
  final String? notes;
  final String companyId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cutting_ref': cuttingRef,
      'cutting_date': cuttingDate.toIso8601String().split(
        'T',
      )[0], // DATE format
      'quantity_cut': quantityCut,
      'style_id': styleId,
      'notes': notes,
      'company_id': companyId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Cutting copyWith({
    String? id,
    String? cuttingRef,
    DateTime? cuttingDate,
    int? quantityCut,
    String? styleId,
    String? notes,
    String? companyId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cutting(
      id: id ?? this.id,
      cuttingRef: cuttingRef ?? this.cuttingRef,
      cuttingDate: cuttingDate ?? this.cuttingDate,
      quantityCut: quantityCut ?? this.quantityCut,
      styleId: styleId ?? this.styleId,
      notes: notes ?? this.notes,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Cutting(id: $id, cuttingRef: $cuttingRef, quantityCut: $quantityCut)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Cutting &&
        other.id == id &&
        other.cuttingRef == cuttingRef &&
        other.cuttingDate == cuttingDate;
  }

  @override
  int get hashCode => id.hashCode ^ cuttingRef.hashCode ^ cuttingDate.hashCode;
}

/// Extended cutting model with style name for display
class CuttingWithStyle extends Cutting {
  CuttingWithStyle({
    required super.id,
    required super.cuttingRef,
    required super.cuttingDate,
    required super.quantityCut,
    required super.styleId,
    super.notes,
    required super.companyId,
    required super.userId,
    required super.createdAt,
    required super.updatedAt,
    required this.styleName,
  });

  factory CuttingWithStyle.fromJson(Map<String, dynamic> json) {
    return CuttingWithStyle(
      id: json['id'] as String,
      cuttingRef: json['cutting_ref'] as String,
      cuttingDate: DateTime.parse(json['cutting_date'] as String),
      quantityCut: json['quantity_cut'] as int,
      styleId: json['style_id'] as String,
      notes: json['notes'] as String?,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      styleName: json['style_name'] as String? ?? 'Unknown Style',
    );
  }

  final String styleName;

  @override
  String toString() {
    return 'CuttingWithStyle(id: $id, cuttingRef: $cuttingRef, styleName: $styleName)';
  }
}

