import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/features/masters/providers/style_providers.dart';
import 'package:stylemake/features/masters/providers/vendor_providers.dart';
import 'package:stylemake/features/production/providers/cutting_providers.dart';

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
