import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/features/production/data/models/fabrication_po.dart';
import 'package:stylemake/features/production/data/repositories/fabrication_po_repository.dart';

/// Provider for FabricationPoRepository instance
final poRepositoryProvider = Provider<FabricationPoRepository>((ref) {
  return FabricationPoRepository();
});

/// Provider for all POs list with real-time updates
final posListProvider = StreamProvider<List<FabricationPoWithDetails>>((ref) {
  final repository = ref.read(poRepositoryProvider);
  return repository.watchAllPos();
});

/// Provider for PO search query
final poSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for vendor filter
final poVendorFilterProvider = StateProvider<String?>((ref) => null);

/// Provider for fabrication type filter
final poTypeFilterProvider = StateProvider<String?>((ref) => null);

/// Provider for date range filter
final poDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Provider for filtered POs based on search, vendor, type, and date range
final filteredPosProvider = Provider<List<FabricationPoWithDetails>>((ref) {
  final posAsync = ref.watch(posListProvider);
  final searchQuery = ref.watch(poSearchQueryProvider).toLowerCase();
  final vendorFilter = ref.watch(poVendorFilterProvider);
  final typeFilter = ref.watch(poTypeFilterProvider);
  final dateRange = ref.watch(poDateRangeProvider);

  return posAsync.when(
    data: (pos) {
      var filtered = pos;

      // Apply search filter (PO number, job order no, vendor name)
      if (searchQuery.isNotEmpty) {
        filtered = filtered
            .where(
              (po) =>
                  po.poNumber.toLowerCase().contains(searchQuery) ||
                  po.jobOrderNo.toLowerCase().contains(searchQuery) ||
                  po.vendorName.toLowerCase().contains(searchQuery),
            )
            .toList();
      }

      // Apply vendor filter
      if (vendorFilter != null) {
        filtered = filtered.where((po) => po.vendorId == vendorFilter).toList();
      }

      // Apply type filter
      if (typeFilter != null) {
        filtered = filtered
            .where((po) => po.fabricationType == typeFilter)
            .toList();
      }

      // Apply date range filter
      if (dateRange != null) {
        filtered = filtered.where((po) {
          final issueDate = po.dateOfIssue;
          return issueDate.isAfter(
                dateRange.start.subtract(const Duration(days: 1)),
              ) &&
              issueDate.isBefore(dateRange.end.add(const Duration(days: 1)));
        }).toList();
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for single PO by ID with details
final poByIdProvider = FutureProvider.family<FabricationPoWithDetails?, String>(
  (ref, id) async {
    final repository = ref.read(poRepositoryProvider);
    return repository.getPoWithDetails(id);
  },
);

/// Provider for POs by cutting ID
final posByCuttingProvider =
    FutureProvider.family<List<FabricationPoWithDetails>, String>((
      ref,
      cuttingId,
    ) async {
      final repository = ref.read(poRepositoryProvider);
      return repository.getPosByCutting(cuttingId);
    });
