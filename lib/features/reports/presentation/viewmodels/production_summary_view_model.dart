import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/features/reports/data/repositories/production_summary_repository.dart';

final summaryRepositoryProvider = Provider<ProductionSummaryRepository>((ref) {
  return ProductionSummaryRepository();
});

final summaryDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0);
  return DateTimeRange(start: start, end: end);
});

final summaryStyleFilterProvider = StateProvider<String?>((ref) => null);

final productionSummaryTotalsProvider = FutureProvider((ref) async {
  final repo = ref.read(summaryRepositoryProvider);
  final range = ref.watch(summaryDateRangeProvider);
  final styleId = ref.watch(summaryStyleFilterProvider);
  return repo.getTotals(from: range.start, to: range.end, styleId: styleId);
});


