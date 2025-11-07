import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/features/masters/presentation/viewmodels/style_view_model.dart';
import 'package:stylemake/features/masters/presentation/viewmodels/vendor_view_model.dart';
import 'package:stylemake/features/masters/presentation/viewmodels/customer_view_model.dart';
import 'package:stylemake/features/production/presentation/viewmodels/cutting_view_model.dart';

/// Provider for styles dropdown items
final stylesDropdownProvider = Provider<List<DropdownMenuItem<String>>>((ref) {
  final styles = ref.watch(stylesListProvider).value ?? [];

  return styles.map((style) {
    return DropdownMenuItem<String>(value: style.id, child: Text(style.name));
  }).toList();
});

/// Provider for vendors dropdown items
final vendorsDropdownProvider = Provider<List<DropdownMenuItem<String>>>((ref) {
  final vendors = ref.watch(vendorsListProvider).value ?? [];

  return vendors.map((vendor) {
    return DropdownMenuItem<String>(value: vendor.id, child: Text(vendor.name));
  }).toList();
});

/// Provider for cuttings dropdown items
final cuttingsDropdownProvider = Provider<List<DropdownMenuItem<String>>>((
  ref,
) {
  final cuttings = ref.watch(cuttingsListProvider).value ?? [];

  return cuttings.map((cutting) {
    return DropdownMenuItem<String>(
      value: cutting.id,
      child: Text('${cutting.cuttingRef} - ${cutting.styleName}'),
    );
  }).toList();
});

/// Provider for customers dropdown items
final customersDropdownProvider = Provider<List<DropdownMenuItem<String>>>((ref) {
  final customersAsync = ref.watch(customersListProvider);
  
  return customersAsync.when(
    data: (customers) => customers.map((customer) {
      return DropdownMenuItem<String>(
        value: customer.id,
        child: Text(customer.customerName),
      );
    }).toList(),
    loading: () => <DropdownMenuItem<String>>[],
    error: (_, __) => <DropdownMenuItem<String>>[],
  );
});
