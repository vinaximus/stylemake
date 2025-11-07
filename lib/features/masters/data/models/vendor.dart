/// Vendor model representing a fabrication vendor
class Vendor {
  Vendor({
    required this.id,
    required this.name,
    this.gst,
    this.address,
    this.city,
    this.pinCode,
    required this.companyId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as String,
      name: json['name'] as String,
      gst: json['gst'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      pinCode: json['pin_code'] as String?,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String name;
  final String? gst;
  final String? address;
  final String? city;
  final String? pinCode;
  final String companyId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gst': gst,
      'address': address,
      'city': city,
      'pin_code': pinCode,
      'company_id': companyId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Vendor copyWith({
    String? id,
    String? name,
    String? gst,
    String? address,
    String? city,
    String? pinCode,
    String? companyId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      gst: gst ?? this.gst,
      address: address ?? this.address,
      city: city ?? this.city,
      pinCode: pinCode ?? this.pinCode,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Vendor(id: $id, name: $name, city: $city)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Vendor && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
