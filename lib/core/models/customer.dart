/// Customer model representing a dispatch customer
class Customer {
  Customer({
    required this.id,
    required this.customerName,
    this.contactPerson,
    this.phone,
    this.address,
    this.gstNo,
    required this.companyId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      customerName: json['customer_name'] as String,
      contactPerson: json['contact_person'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      gstNo: json['gst_no'] as String?,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String customerName;
  final String? contactPerson;
  final String? phone;
  final String? address;
  final String? gstNo;
  final String companyId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'contact_person': contactPerson,
      'phone': phone,
      'address': address,
      'gst_no': gstNo,
      'company_id': companyId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Customer copyWith({
    String? id,
    String? customerName,
    String? contactPerson,
    String? phone,
    String? address,
    String? gstNo,
    String? companyId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gstNo: gstNo ?? this.gstNo,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, customerName: $customerName, contactPerson: $contactPerson)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Customer && 
           other.id == id && 
           other.customerName == customerName;
  }

  @override
  int get hashCode => id.hashCode ^ customerName.hashCode;
}
