import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/features/production/data/models/receipt.dart';
import 'package:stylemake/features/production/data/repositories/receipt_repository.dart';

/// Provider for ReceiptRepository instance
final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository();
});

/// Filters
final receiptSearchQueryProvider = StateProvider<String>((ref) => '');
final receiptStyleFilterProvider = StateProvider<String?>((ref) => null);
final receiptDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// All receipts list (unfiltered)
final receiptsListProvider = FutureProvider<List<ReceiptWithDetails>>((ref) async {
  final repository = ref.read(receiptRepositoryProvider);
  return repository.getAllReceipts();
});

/// Filtered receipts
final filteredReceiptsProvider = Provider<List<ReceiptWithDetails>>((ref) {
  final receiptsAsync = ref.watch(receiptsListProvider);
  final search = ref.watch(receiptSearchQueryProvider).toLowerCase();
  final styleFilter = ref.watch(receiptStyleFilterProvider);
  final dateRange = ref.watch(receiptDateRangeProvider);

  return receiptsAsync.when(
    data: (receipts) {
      var result = receipts;

      if (search.isNotEmpty) {
        result = result
            .where((r) =>
                r.receiptId.toLowerCase().contains(search) ||
                r.cuttingRef.toLowerCase().contains(search) ||
                r.styleName.toLowerCase().contains(search))
            .toList();
      }

      if (styleFilter != null) {
        result = result.where((r) => r.styleId == styleFilter).toList();
      }

      if (dateRange != null) {
        result = result.where((r) {
          final d = r.dateOfReceipt;
          return d.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
              d.isBefore(dateRange.end.add(const Duration(days: 1)));
        }).toList();
      }

      return result;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Receipt by ID
final receiptByIdProvider = FutureProvider.family<ReceiptWithDetails?, String>((ref, id) async {
  final repository = ref.read(receiptRepositoryProvider);
  return repository.getReceiptById(id);
});

/// Receipts by cutting ID
final receiptsByCuttingProvider = FutureProvider.family<List<ReceiptWithDetails>, String>((ref, cuttingId) async {
  final repository = ref.read(receiptRepositoryProvider);
  return repository.getReceiptsByCutting(cuttingId);
});


