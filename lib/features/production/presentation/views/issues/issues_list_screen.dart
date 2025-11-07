import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/shared/constants/layout_constants.dart';
import 'package:stylemake/features/production/data/models/item_issue.dart';
import 'package:stylemake/app/router/app_router.dart';
import 'package:stylemake/shared/utils/snackbar_utils.dart';
import 'package:stylemake/shared/widgets/app_fab.dart';
import 'package:stylemake/shared/widgets/dialogs/confirm_dialog.dart';
import 'package:stylemake/shared/widgets/responsive_center.dart';
import 'package:stylemake/features/production/presentation/viewmodels/issue_view_model.dart';
import 'package:stylemake/features/production/presentation/viewmodels/po_view_model.dart';

/// Item Issues list screen
class IssuesListScreen extends ConsumerWidget {
  const IssuesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(issuesListProvider);
    final filteredIssues = ref.watch(filteredIssuesProvider);
    final searchQuery = ref.watch(issueSearchQueryProvider);
    final poFilter = ref.watch(issuePoFilterProvider);
    final dateRange = ref.watch(issueDateRangeProvider);
    final posAsync = ref.watch(posListProvider);

    final hasActiveFilters = poFilter != null || dateRange != null;
    final activeFilterCount = [
      if (poFilter != null) 1,
      if (dateRange != null) 1,
    ].length;

    // Build PO dropdown items
    final poDropdownItems = posAsync.when(
      data: (pos) => pos
          .map(
            (po) => DropdownMenuItem(
              value: po.id,
              child: Text(
                '${po.poNumber} - ${po.vendorName}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      loading: () => <DropdownMenuItem<String>>[],
      error: (_, __) => <DropdownMenuItem<String>>[],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Issues'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.paddingMedium,
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search issues...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(issueSearchQueryProvider.notifier).state = value;
                  },
                ),
              ),
              const SizedBox(height: LayoutConstants.spaceSmall),
              // Filter row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.paddingMedium,
                ),
                child: Row(
                  children: [
                    // PO filter
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: poFilter,
                        decoration: const InputDecoration(
                          labelText: 'PO',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        isExpanded: true,
                        menuMaxHeight: 300,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All', overflow: TextOverflow.ellipsis),
                          ),
                          ...poDropdownItems,
                        ],
                        selectedItemBuilder: (BuildContext context) {
                          return [
                            const Text('All', overflow: TextOverflow.ellipsis),
                            ...posAsync.maybeWhen(
                              data: (pos) => pos
                                  .map(
                                    (po) => Text(
                                      '${po.poNumber} - ${po.vendorName}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                  .toList(),
                              orElse: () => [],
                            ),
                          ];
                        },
                        onChanged: (value) {
                          ref.read(issuePoFilterProvider.notifier).state =
                              value;
                        },
                      ),
                    ),
                    const SizedBox(width: LayoutConstants.spaceSmall),
                    // Date range button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            initialDateRange: dateRange,
                          );
                          if (picked != null) {
                            ref.read(issueDateRangeProvider.notifier).state =
                                picked;
                          }
                        },
                        icon: const Icon(Icons.date_range, size: 16),
                        label: Text(
                          dateRange == null
                              ? 'Date'
                              : '${DateFormat('dd/MM/yy').format(dateRange.start)}-${DateFormat('dd/MM/yy').format(dateRange.end)}',
                          style: const TextStyle(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LayoutConstants.spaceSmall),
              // Clear filters
              if (hasActiveFilters)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LayoutConstants.paddingMedium,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Badge(
                        label: Text('$activeFilterCount'),
                        child: TextButton.icon(
                          onPressed: () {
                            ref.invalidate(issuePoFilterProvider);
                            ref.invalidate(issueDateRangeProvider);
                          },
                          icon: const Icon(Icons.filter_alt_off),
                          label: const Text('Clear filters'),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: LayoutConstants.spaceSmall),
            ],
          ),
        ),
      ),
      body: ResponsiveCenter(
        maxWidth: LayoutConstants.maxContentWidth,
        padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
        child: issuesAsync.when(
          data: (_) {
            if (filteredIssues.isEmpty) {
              final hasData = issuesAsync.value?.isNotEmpty ?? false;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasData && searchQuery.isNotEmpty
                          ? Icons.search_off
                          : Icons.inventory_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: LayoutConstants.spaceLarge),
                    Text(
                      hasData && searchQuery.isNotEmpty
                          ? 'No issues found'
                          : 'No Item Issues yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: LayoutConstants.spaceSmall),
                    Text(
                      hasData && searchQuery.isNotEmpty
                          ? 'Try adjusting your search or filters'
                          : 'Create your first issue to get started',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(issuesListProvider);
              },
              child: ListView.builder(
                itemCount: filteredIssues.length,
                itemBuilder: (context, index) {
                  final issue = filteredIssues[index];
                  return _IssueCard(issue: issue);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: LayoutConstants.spaceLarge),
                Text(
                  'Error loading issues',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: LayoutConstants.spaceSmall),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: LayoutConstants.spaceLarge),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(issuesListProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AppFab(
        onPressed: () => context.push(AppRouter.issuesAdd),
        label: 'Add Issue',
        icon: Icons.add,
      ),
    );
  }
}

class _IssueCard extends ConsumerWidget {
  const _IssueCard({required this.issue});

  final ItemIssueWithDetails issue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: LayoutConstants.spaceSmall),
      child: InkWell(
        onTap: () {
          context.push(AppRouter.issuesEdit(issue.id));
        },
        borderRadius: BorderRadius.circular(LayoutConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
                child: const Icon(Icons.inventory_2),
              ),
              const SizedBox(width: LayoutConstants.spaceMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.itemDescription,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            issue.poNumber,
                            style: const TextStyle(fontSize: 11),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(issue.issueDate),
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${issue.quantity} • Rate: ₹${issue.rate.toStringAsFixed(2)} • Total: ₹${issue.totalAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () {
                  context.push(AppRouter.issuesEdit(issue.id));
                },
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () async {
                  final confirmed = await showDeleteConfirmDialog(
                    context: context,
                    itemName: issue.itemDescription,
                  );
                  if (confirmed && context.mounted) {
                    try {
                      final repository = ref.read(issueRepositoryProvider);
                      await repository.deleteIssue(issue.id);
                      ref.invalidate(issuesListProvider);
                      if (context.mounted) {
                        SnackbarUtils.showSuccess(
                          context,
                          'Issue deleted successfully',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        SnackbarUtils.showError(
                          context,
                          'Failed to delete issue: ${e.toString()}',
                        );
                      }
                    }
                  }
                },
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
