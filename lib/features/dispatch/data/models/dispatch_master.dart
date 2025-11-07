/// DispatchMaster model representing a dispatch challan
class DispatchMaster {
  DispatchMaster({
    required this.id,
    required this.companyId,
    required this.dispatchNo,
    required this.dispatchDate,
    required this.customerId,
    this.transportName,
    this.vehicleNo,
    this.lrNo,
    required this.totalQuantity,
    this.remarks,
    required this.createdAt,
    required this.userId,
    this.updatedAt,
  });

  factory DispatchMaster.fromJson(Map<String, dynamic> json) {
    return DispatchMaster(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      dispatchNo: json['dispatch_no'] as String,
      dispatchDate: DateTime.parse(json['dispatch_date'] as String),
      customerId: json['customer_id'] as String,
      transportName: json['transport_name'] as String?,
      vehicleNo: json['vehicle_no'] as String?,
      lrNo: json['lr_no'] as String?,
      totalQuantity: (json['total_quantity'] as num).toDouble(),
      remarks: json['remarks'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String companyId;
  final String dispatchNo;
  final DateTime dispatchDate;
  final String customerId;
  final String? transportName;
  final String? vehicleNo;
  final String? lrNo;
  final double totalQuantity;
  final String? remarks;
  final DateTime createdAt;
  final String userId;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'dispatch_no': dispatchNo,
      'dispatch_date': dispatchDate.toIso8601String().split(
        'T',
      )[0], // Date only
      'customer_id': customerId,
      'transport_name': transportName,
      'vehicle_no': vehicleNo,
      'lr_no': lrNo,
      'total_quantity': totalQuantity,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DispatchMaster copyWith({
    String? id,
    String? companyId,
    String? dispatchNo,
    DateTime? dispatchDate,
    String? customerId,
    String? transportName,
    String? vehicleNo,
    String? lrNo,
    double? totalQuantity,
    String? remarks,
    DateTime? createdAt,
    String? userId,
    DateTime? updatedAt,
  }) {
    return DispatchMaster(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      dispatchNo: dispatchNo ?? this.dispatchNo,
      dispatchDate: dispatchDate ?? this.dispatchDate,
      customerId: customerId ?? this.customerId,
      transportName: transportName ?? this.transportName,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      lrNo: lrNo ?? this.lrNo,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DispatchMaster(id: $id, dispatchNo: $dispatchNo, customerId: $customerId, totalQuantity: $totalQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DispatchMaster &&
        other.id == id &&
        other.dispatchNo == dispatchNo &&
        other.customerId == customerId;
  }

  @override
  int get hashCode => id.hashCode ^ dispatchNo.hashCode ^ customerId.hashCode;
}
