import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/providers/dropdown_providers.dart';
import 'package:stylemake/core/router/app_router.dart';
import 'package:stylemake/core/utils/snackbar_utils.dart';
import 'package:stylemake/core/widgets/app_fab.dart';
import 'package:stylemake/core/widgets/dialogs/confirm_dialog.dart';
import 'package:stylemake/core/widgets/list_card_item.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';
import 'package:stylemake/features/production/providers/cutting_providers.dart';

/// Cutting Records list screen
class CuttingsListScreen extends ConsumerWidget {
  const CuttingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuttingsAsync = ref.watch(cuttingsListProvider);
    final filteredCuttings = ref.watch(filteredCuttingsProvider);
    final searchQuery = ref.watch(cuttingSearchQueryProvider);
    final styleFilter = ref.watch(cuttingStyleFilterProvider);
    final dateRange = ref.watch(cuttingDateRangeProvider);
    final stylesDropdown = ref.watch(stylesDropdownProvider);

    final hasActiveFilters = styleFilter != null || dateRange != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cutting Records'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.paddingMedium,
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by cutting ref or style...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(cuttingSearchQueryProvider.notifier).state = value;
                  },
                ),
              ),
              const SizedBox(height: LayoutConstants.spaceSmall),
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: LayoutConstants.paddingMedium,
                  ),
                  children: [
                    // Style filter
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          styleFilter == null
                              ? 'All Styles'
                              : stylesDropdown
                                    .firstWhere(
                                      (item) => item.value == styleFilter,
                                      orElse: () => stylesDropdown.first,
                                    )
                                    .child
                                    .toString()
                                    .replaceAll('Text("', '')
                                    .replaceAll('")', ''),
                        ),
                        selected: styleFilter != null,
                        onSelected: (selected) {
                          _showStyleFilterDialog(context, ref, stylesDropdown);
                        },
                        avatar: Icon(
                          Icons.style,
                          size: 16,
                          color: styleFilter != null
                              ? Theme.of(context).colorScheme.onPrimary
                              : null,
                        ),
                      ),
                    ),
                    // Date range filter
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          dateRange == null
                              ? 'Date Range'
                              : '${DateFormat('dd/MM/yy').format(dateRange.start)} - ${DateFormat('dd/MM/yy').format(dateRange.end)}',
                        ),
                        selected: dateRange != null,
                        onSelected: (selected) {
                          _showDateRangeDialog(context, ref);
                        },
                        avatar: Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: dateRange != null
                              ? Theme.of(context).colorScheme.onPrimary
                              : null,
                        ),
                      ),
                    ),
                    // Clear filters
                    if (hasActiveFilters)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: const Text('Clear Filters'),
                          onPressed: () {
                            ref
                                    .read(cuttingStyleFilterProvider.notifier)
                                    .state =
                                null;
                            ref.read(cuttingDateRangeProvider.notifier).state =
                                null;
                          },
                          avatar: const Icon(Icons.clear, size: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(cuttingsListProvider);
        },
        child: cuttingsAsync.when(
          data: (cuttings) {
            if (cuttings.isEmpty) {
              return _buildEmptyState(context);
            }

            if (filteredCuttings.isEmpty &&
                (searchQuery.isNotEmpty || hasActiveFilters)) {
              return _buildNoResultsState(context);
            }

            return ResponsiveListContainer(
              child: ListView.builder(
                padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
                itemCount: filteredCuttings.length,
                itemBuilder: (context, index) {
                  final cutting = filteredCuttings[index];
                  return ListCardItem(
                    title: cutting.cuttingRef,
                    subtitle:
                        '${cutting.styleName} • ${DateFormat('dd MMM yyyy').format(cutting.cuttingDate)} • Qty: ${cutting.quantityCut}',
                    leading: const CircleAvatar(child: Icon(Icons.content_cut)),
                    trailing: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          context.push(AppRouter.cuttingsEdit(cutting.id));
                        },
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteCutting(
                          context,
                          ref,
                          cutting.id,
                          cutting.cuttingRef,
                        ),
                        tooltip: 'Delete',
                      ),
                    ],
                    onTap: () {
                      context.push(AppRouter.cuttingsDetail(cutting.id));
                    },
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(context, ref, error),
        ),
      ),
      floatingActionButton: AppFab(
        onPressed: () {
          context.push(AppRouter.cuttingsAdd);
        },
        label: 'Add Cutting',
        icon: Icons.add,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.content_cut_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: LayoutConstants.spaceLarge),
          Text(
            'No cutting records yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: LayoutConstants.spaceSmall),
          Text(
            'Tap the + button to add your first cutting',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: LayoutConstants.spaceLarge),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: LayoutConstants.spaceSmall),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
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
              'Error loading cuttings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: LayoutConstants.spaceSmall),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LayoutConstants.spaceLarge),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(cuttingsListProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStyleFilterDialog(
    BuildContext context,
    WidgetRef ref,
    List<DropdownMenuItem<String>> styles,
  ) async {
    final selected = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Style'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Styles'),
              onTap: () => Navigator.of(context).pop(null),
            ),
            ...styles.map((item) {
              return ListTile(
                title: item.child,
                onTap: () => Navigator.of(context).pop(item.value),
              );
            }),
          ],
        ),
      ),
    );

    if (selected != null || context.mounted) {
      ref.read(cuttingStyleFilterProvider.notifier).state = selected;
    }
  }

  Future<void> _showDateRangeDialog(BuildContext context, WidgetRef ref) async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: ref.read(cuttingDateRangeProvider),
    );

    if (dateRange != null) {
      ref.read(cuttingDateRangeProvider.notifier).state = dateRange;
    }
  }

  Future<void> _deleteCutting(
    BuildContext context,
    WidgetRef ref,
    String cuttingId,
    String cuttingRef,
  ) async {
    final confirmed = await showDeleteConfirmDialog(
      context: context,
      itemName: cuttingRef,
    );

    if (!confirmed || !context.mounted) return;

    try {
      final repository = ref.read(cuttingRepositoryProvider);
      await repository.deleteCutting(cuttingId);

      if (context.mounted) {
        SnackbarUtils.showSuccess(context, 'Cutting deleted successfully');
        ref.invalidate(cuttingsListProvider);
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to delete cutting: ${e.toString()}',
        );
      }
    }
  }
}
