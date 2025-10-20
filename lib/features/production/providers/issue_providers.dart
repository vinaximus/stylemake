import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/core/models/item_issue.dart';
import 'package:stylemake/core/repositories/item_issue_repository.dart';

/// Provider for ItemIssueRepository instance
final issueRepositoryProvider = Provider<ItemIssueRepository>((ref) {
  return ItemIssueRepository();
});

/// Provider for all issues list
final issuesListProvider = FutureProvider<List<ItemIssueWithDetails>>((
  ref,
) async {
  final repository = ref.read(issueRepositoryProvider);
  return repository.getAllIssues();
});

/// Provider for issue search query
final issueSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for PO filter
final issuePoFilterProvider = StateProvider<String?>((ref) => null);

/// Provider for date range filter
final issueDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Provider for filtered issues based on search, PO, and date range
final filteredIssuesProvider = Provider<List<ItemIssueWithDetails>>((ref) {
  final issuesAsync = ref.watch(issuesListProvider);
  final searchQuery = ref.watch(issueSearchQueryProvider).toLowerCase();
  final poFilter = ref.watch(issuePoFilterProvider);
  final dateRange = ref.watch(issueDateRangeProvider);

  return issuesAsync.when(
    data: (issues) {
      var filtered = issues;

      // Apply search filter (item description, PO number)
      if (searchQuery.isNotEmpty) {
        filtered = filtered
            .where(
              (issue) =>
                  issue.itemDescription.toLowerCase().contains(searchQuery) ||
                  issue.poNumber.toLowerCase().contains(searchQuery),
            )
            .toList();
      }

      // Apply PO filter
      if (poFilter != null) {
        filtered = filtered.where((issue) => issue.poId == poFilter).toList();
      }

      // Apply date range filter
      if (dateRange != null) {
        filtered = filtered.where((issue) {
          final issueDate = issue.issueDate;
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

/// Provider for single issue by ID with details
final issueByIdProvider = FutureProvider.family<ItemIssueWithDetails?, String>((
  ref,
  id,
) async {
  final repository = ref.read(issueRepositoryProvider);
  return repository.getIssueById(id);
});

/// Provider for issues by PO ID
final issuesByPoProvider =
    FutureProvider.family<List<ItemIssueWithDetails>, String>((
      ref,
      poId,
    ) async {
      final repository = ref.read(issueRepositoryProvider);
      return repository.getIssuesByPo(poId);
    });

/// Provider for issues by cutting ID (all issues from POs linked to that cutting)
final issuesByCuttingProvider =
    FutureProvider.family<List<ItemIssueWithDetails>, String>((
      ref,
      cuttingId,
    ) async {
      final repository = ref.read(issueRepositoryProvider);
      return repository.getIssuesByCutting(cuttingId);
    });
