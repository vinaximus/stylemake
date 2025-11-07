import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/features/production/data/models/cutting.dart';
import 'package:stylemake/features/production/data/repositories/cutting_repository.dart';

/// Provider for CuttingRepository instance
final cuttingRepositoryProvider = Provider<CuttingRepository>((ref) {
  return CuttingRepository();
});

/// Provider for all cuttings list with real-time updates
final cuttingsListProvider = StreamProvider<List<CuttingWithStyle>>((ref) {
  final repository = ref.read(cuttingRepositoryProvider);
  return repository.watchAllCuttings();
});

/// Provider for cutting search query
final cuttingSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for style filter
final cuttingStyleFilterProvider = StateProvider<String?>((ref) => null);

/// Provider for date range filter
final cuttingDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Provider for filtered cuttings based on search, style, and date range
final filteredCuttingsProvider = Provider<List<CuttingWithStyle>>((ref) {
  final cuttingsAsync = ref.watch(cuttingsListProvider);
  final searchQuery = ref.watch(cuttingSearchQueryProvider).toLowerCase();
  final styleFilter = ref.watch(cuttingStyleFilterProvider);
  final dateRange = ref.watch(cuttingDateRangeProvider);

  return cuttingsAsync.when(
    data: (cuttings) {
      var filtered = cuttings;

      // Apply search filter
      if (searchQuery.isNotEmpty) {
        filtered = filtered
            .where(
              (cutting) =>
                  cutting.cuttingRef.toLowerCase().contains(searchQuery) ||
                  cutting.styleName.toLowerCase().contains(searchQuery),
            )
            .toList();
      }

      // Apply style filter
      if (styleFilter != null) {
        filtered = filtered
            .where((cutting) => cutting.styleId == styleFilter)
            .toList();
      }

      // Apply date range filter
      if (dateRange != null) {
        filtered = filtered.where((cutting) {
          final cuttingDate = cutting.cuttingDate;
          return cuttingDate.isAfter(
                dateRange.start.subtract(const Duration(days: 1)),
              ) &&
              cuttingDate.isBefore(dateRange.end.add(const Duration(days: 1)));
        }).toList();
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for single cutting by ID with style
final cuttingByIdProvider = FutureProvider.family<CuttingWithStyle?, String>((
  ref,
  id,
) async {
  final repository = ref.read(cuttingRepositoryProvider);
  return repository.getCuttingWithStyle(id);
});
