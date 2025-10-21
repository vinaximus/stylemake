import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/core/models/bill.dart';
import 'package:stylemake/core/repositories/bill_repository.dart';

/// Provider for BillRepository instance
final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository();
});

/// Provider for all bills list
final billsListProvider = FutureProvider<List<BillWithDetails>>((ref) async {
  final repository = ref.read(billRepositoryProvider);
  return repository.getAllBills();
});

/// Provider for bill search query
final billSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for PO filter
final billPoFilterProvider = StateProvider<String?>((ref) => null);

/// Provider for vendor filter
final billVendorFilterProvider = StateProvider<String?>((ref) => null);

/// Provider for date range filter
final billDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Provider for filtered bills based on search, PO, vendor, and date range
final filteredBillsProvider = Provider<List<BillWithDetails>>((ref) {
  final billsAsync = ref.watch(billsListProvider);
  final searchQuery = ref.watch(billSearchQueryProvider).toLowerCase();
  final poFilter = ref.watch(billPoFilterProvider);
  final vendorFilter = ref.watch(billVendorFilterProvider);
  final dateRange = ref.watch(billDateRangeProvider);

  return billsAsync.when(
    data: (bills) {
      var filtered = bills;

      // Apply search filter (supplier invoice no, PO number, vendor name)
      if (searchQuery.isNotEmpty) {
        filtered = filtered
            .where(
              (bill) =>
                  bill.supplierInvoiceNo.toLowerCase().contains(searchQuery) ||
                  bill.poNumber.toLowerCase().contains(searchQuery) ||
                  bill.vendorName.toLowerCase().contains(searchQuery),
            )
            .toList();
      }

      // Apply PO filter
      if (poFilter != null) {
        filtered = filtered.where((bill) => bill.poId == poFilter).toList();
      }

      // Apply vendor filter
      if (vendorFilter != null) {
        filtered = filtered
            .where((bill) => bill.vendorId == vendorFilter)
            .toList();
      }

      // Apply date range filter
      if (dateRange != null) {
        filtered = filtered.where((bill) {
          final invoiceDate = bill.invoiceDate;
          return invoiceDate.isAfter(
                dateRange.start.subtract(const Duration(days: 1)),
              ) &&
              invoiceDate.isBefore(dateRange.end.add(const Duration(days: 1)));
        }).toList();
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for single bill by ID with details
final billByIdProvider = FutureProvider.family<BillWithDetails?, String>((
  ref,
  id,
) async {
  final repository = ref.read(billRepositoryProvider);
  return repository.getBillById(id);
});

/// Provider for bills by PO ID
final billsByPoProvider = FutureProvider.family<List<BillWithDetails>, String>((
  ref,
  poId,
) async {
  final repository = ref.read(billRepositoryProvider);
  return repository.getBillsByPo(poId);
});

/// Provider for bills by cutting ID (all bills from POs linked to that cutting)
final billsByCuttingProvider =
    FutureProvider.family<List<BillWithDetails>, String>((
      ref,
      cuttingId,
    ) async {
      final repository = ref.read(billRepositoryProvider);
      return repository.getBillsByCutting(cuttingId);
    });

/// Provider for bills by vendor ID
final billsByVendorProvider =
    FutureProvider.family<List<BillWithDetails>, String>((ref, vendorId) async {
      final repository = ref.read(billRepositoryProvider);
      return repository.getBillsByVendor(vendorId);
    });
