import 'package:stylemake/features/production/data/models/po_order_item.dart';

/// Fabrication Purchase Order model
class FabricationPo {
  FabricationPo({
    required this.id,
    required this.poNumber,
    required this.cuttingId,
    required this.jobOrderNo,
    required this.vendorId,
    required this.fabricationType,
    required this.dateOfIssue,
    this.completionDate,
    this.instructions,
    required this.companyId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FabricationPo.fromJson(Map<String, dynamic> json) {
    return FabricationPo(
      id: json['id'] as String,
      poNumber: json['po_number'] as String,
      cuttingId: json['cutting_id'] as String,
      jobOrderNo: json['job_order_no'] as String,
      vendorId: json['vendor_id'] as String,
      fabricationType: json['fabrication_type'] as String,
      dateOfIssue: DateTime.parse(json['date_of_issue'] as String),
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'] as String)
          : null,
      instructions: json['instructions'] as String?,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String poNumber;
  final String cuttingId;
  final String jobOrderNo;
  final String vendorId;
  final String fabricationType; // 'Embroidery' or 'Stitching & Finishing'
  final DateTime dateOfIssue;
  final DateTime? completionDate;
  final String? instructions;
  final String companyId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'po_number': poNumber,
      'cutting_id': cuttingId,
      'job_order_no': jobOrderNo,
      'vendor_id': vendorId,
      'fabrication_type': fabricationType,
      'date_of_issue': dateOfIssue.toIso8601String().split('T')[0], // DATE
      'completion_date': completionDate?.toIso8601String().split('T')[0],
      'instructions': instructions,
      'company_id': companyId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FabricationPo copyWith({
    String? id,
    String? poNumber,
    String? cuttingId,
    String? jobOrderNo,
    String? vendorId,
    String? fabricationType,
    DateTime? dateOfIssue,
    DateTime? completionDate,
    String? instructions,
    String? companyId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FabricationPo(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      cuttingId: cuttingId ?? this.cuttingId,
      jobOrderNo: jobOrderNo ?? this.jobOrderNo,
      vendorId: vendorId ?? this.vendorId,
      fabricationType: fabricationType ?? this.fabricationType,
      dateOfIssue: dateOfIssue ?? this.dateOfIssue,
      completionDate: completionDate ?? this.completionDate,
      instructions: instructions ?? this.instructions,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'FabricationPo(id: $id, poNumber: $poNumber, jobOrderNo: $jobOrderNo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FabricationPo &&
        other.id == id &&
        other.poNumber == poNumber;
  }

  @override
  int get hashCode => id.hashCode ^ poNumber.hashCode;
}

/// Extended fabrication PO model with joined data for display
class FabricationPoWithDetails extends FabricationPo {
  FabricationPoWithDetails({
    required super.id,
    required super.poNumber,
    required super.cuttingId,
    required super.jobOrderNo,
    required super.vendorId,
    required super.fabricationType,
    required super.dateOfIssue,
    super.completionDate,
    super.instructions,
    required super.companyId,
    required super.userId,
    required super.createdAt,
    required super.updatedAt,
    required this.cuttingRef,
    required this.vendorName,
    required this.styleName,
    this.vendorGst,
    this.vendorCity,
    this.orderItems,
  });

  factory FabricationPoWithDetails.fromJson(Map<String, dynamic> json) {
    // Extract nested data
    final cutting = json['cuttings'] as Map<String, dynamic>?;
    final vendor = json['vendors'] as Map<String, dynamic>?;
    final style = cutting?['styles'] as Map<String, dynamic>?;

    return FabricationPoWithDetails(
      id: json['id'] as String,
      poNumber: json['po_number'] as String,
      cuttingId: json['cutting_id'] as String,
      jobOrderNo: json['job_order_no'] as String,
      vendorId: json['vendor_id'] as String,
      fabricationType: json['fabrication_type'] as String,
      dateOfIssue: DateTime.parse(json['date_of_issue'] as String),
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'] as String)
          : null,
      instructions: json['instructions'] as String?,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      cuttingRef: cutting?['cutting_ref'] as String? ?? 'Unknown',
      vendorName: vendor?['name'] as String? ?? 'Unknown',
      styleName: style?['name'] as String? ?? 'Unknown',
      vendorGst: vendor?['gst'] as String?,
      vendorCity: vendor?['city'] as String?,
    );
  }

  final String cuttingRef;
  final String vendorName;
  final String styleName;
  final String? vendorGst;
  final String? vendorCity;
  final List<PoOrderItem>? orderItems;

  /// Calculate total amount from order items
  double get totalAmountFromItems {
    if (orderItems != null && orderItems!.isNotEmpty) {
      return orderItems!.fold<double>(
        0,
        (sum, item) => sum + item.totalAmount,
      );
    }
    return 0.0; // No items, no total
  }

  @override
  String toString() {
    return 'FabricationPoWithDetails(id: $id, poNumber: $poNumber, vendor: $vendorName)';
  }
}

/// Fabrication type enum helper
class FabricationType {
  static const String embroidery = 'Embroidery';
  static const String stitchingFinishing = 'Stitching & Finishing';

  static List<String> get all => [embroidery, stitchingFinishing];
}
