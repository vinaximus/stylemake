/// Style model representing a garment style
class Style {
  Style({
    required this.id,
    required this.name,
    required this.companyId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.designer,
  });

  factory Style.fromJson(Map<String, dynamic> json) {
    return Style(
      id: json['id'] as String,
      name: json['name'] as String,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      designer: json['designer'] as String?,
    );
  }

  final String id;
  final String name;
  final String companyId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? designer;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_id': companyId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'designer': designer,
    };
  }

  Style copyWith({
    String? id,
    String? name,
    String? companyId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? designer,
  }) {
    return Style(
      id: id ?? this.id,
      name: name ?? this.name,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      designer: designer ?? this.designer,
    );
  }

  @override
  String toString() {
    return 'Style(id: $id, name: $name, designer: $designer)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Style &&
        other.id == id &&
        other.name == name &&
        other.designer == designer;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ designer.hashCode;
}
