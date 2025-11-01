import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/models/fabrication_po.dart';
import 'package:stylemake/core/providers/dropdown_providers.dart';
import 'package:stylemake/core/router/app_router.dart';
import 'package:stylemake/core/utils/csv_exporter.dart';
import 'package:stylemake/core/utils/snackbar_utils.dart';
import 'package:stylemake/core/widgets/app_fab.dart';
import 'package:stylemake/core/widgets/dialogs/confirm_dialog.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';
import 'package:stylemake/features/masters/providers/vendor_providers.dart';
import 'package:stylemake/features/production/providers/po_providers.dart';

/// Purchase Orders list screen
class PosListScreen extends ConsumerWidget {
  const PosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posAsync = ref.watch(posListProvider);
    final filteredPos = ref.watch(filteredPosProvider);
    final searchQuery = ref.watch(poSearchQueryProvider);
    final vendorFilter = ref.watch(poVendorFilterProvider);
    final typeFilter = ref.watch(poTypeFilterProvider);
    final dateRange = ref.watch(poDateRangeProvider);
    final vendorsDropdown = ref.watch(vendorsDropdownProvider);
    final vendorsAsync = ref.watch(vendorsListProvider);

    final hasActiveFilters =
        vendorFilter != null || typeFilter != null || dateRange != null;
    final activeFilterCount = [
      if (vendorFilter != null) 1,
      if (typeFilter != null) 1,
      if (dateRange != null) 1,
    ].length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export to CSV',
            onPressed: () => _exportToCsv(context, filteredPos),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(170),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.paddingMedium,
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search POs...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(poSearchQueryProvider.notifier).state = value;
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
                    // Vendor filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: vendorFilter,
                        decoration: const InputDecoration(
                          labelText: 'Vendor',
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
                          ...vendorsDropdown,
                        ],
                        selectedItemBuilder: (BuildContext context) {
                          return [
                            const Text('All', overflow: TextOverflow.ellipsis),
                            ...vendorsAsync.maybeWhen(
                              data: (vendors) => vendors
                                  .map(
                                    (vendor) => Text(
                                      vendor.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                  .toList(),
                              orElse: () => [],
                            ),
                          ];
                        },
                        onChanged: (value) {
                          ref.read(poVendorFilterProvider.notifier).state =
                              value;
                        },
                      ),
                    ),
                    const SizedBox(width: LayoutConstants.spaceSmall),
                    // Type filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: typeFilter,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        isExpanded: true,
                        menuMaxHeight: 300,
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All', overflow: TextOverflow.ellipsis),
                          ),
                          DropdownMenuItem(
                            value: 'Embroidery',
                            child: Text(
                              'Embroidery',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Stitching & Finishing',
                            child: Text(
                              'Stitching & Finishing',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        selectedItemBuilder: (BuildContext context) {
                          return const [
                            Text('All', overflow: TextOverflow.ellipsis),
                            Text('Embroidery', overflow: TextOverflow.ellipsis),
                            Text(
                              'Stitching & Finishing',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ];
                        },
                        onChanged: (value) {
                          ref.read(poTypeFilterProvider.notifier).state = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LayoutConstants.spaceSmall),
              // Date range and clear filters
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.paddingMedium,
                ),
                child: Row(
                  children: [
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
                            ref.read(poDateRangeProvider.notifier).state =
                                picked;
                          }
                        },
                        icon: const Icon(Icons.date_range, size: 16),
                        label: Flexible(
                          child: Text(
                            dateRange == null
                                ? 'Date Range'
                                : '${DateFormat('dd/MM/yy').format(dateRange.start)}-${DateFormat('dd/MM/yy').format(dateRange.end)}',
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    if (hasActiveFilters) ...[
                      const SizedBox(width: LayoutConstants.spaceSmall),
                      Badge(
                        label: Text('$activeFilterCount'),
                        child: IconButton(
                          onPressed: () {
                            ref.invalidate(poVendorFilterProvider);
                            ref.invalidate(poTypeFilterProvider);
                            ref.invalidate(poDateRangeProvider);
                          },
                          icon: const Icon(Icons.filter_alt_off),
                          tooltip: 'Clear filters',
                        ),
                      ),
                    ],
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
        child: posAsync.when(
          data: (_) {
            if (filteredPos.isEmpty) {
              final hasData = posAsync.value?.isNotEmpty ?? false;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasData && searchQuery.isNotEmpty
                          ? Icons.search_off
                          : Icons.receipt_long_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: LayoutConstants.spaceLarge),
                    Text(
                      hasData && searchQuery.isNotEmpty
                          ? 'No POs found'
                          : 'No Purchase Orders yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: LayoutConstants.spaceSmall),
                    Text(
                      hasData && searchQuery.isNotEmpty
                          ? 'Try adjusting your search or filters'
                          : 'Create your first PO to get started',
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
                ref.invalidate(posListProvider);
              },
              child: ListView.builder(
                itemCount: filteredPos.length,
                itemBuilder: (context, index) {
                  final po = filteredPos[index];
                  return _PoCard(po: po);
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
                  'Error loading POs',
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
                    ref.invalidate(posListProvider);
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
        onPressed: () => context.push(AppRouter.posAdd),
        label: 'Add PO',
        icon: Icons.add,
      ),
    );
  }
}

class _PoCard extends ConsumerWidget {
  const _PoCard({required this.po});

  final FabricationPoWithDetails po;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: LayoutConstants.spaceSmall),
      child: InkWell(
        onTap: () {
          context.push(AppRouter.posDetailPath(po.id));
        },
        borderRadius: BorderRadius.circular(LayoutConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: const Icon(Icons.receipt_long),
              ),
              const SizedBox(width: LayoutConstants.spaceMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      po.poNumber,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            po.fabricationType,
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
                            po.vendorName,
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cutting: ${po.cuttingRef} • ${DateFormat('dd/MM/yyyy').format(po.dateOfIssue)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      po.orderItems != null && po.orderItems!.isNotEmpty
                          ? '${po.orderItems!.length} item(s) • Total: ₹${po.totalAmountFromItems.toStringAsFixed(2)}'
                          : 'No items • Total: ₹0.00',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () {
                  context.push(AppRouter.posEditPath(po.id));
                },
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () async {
                  final confirmed = await showDeleteConfirmDialog(
                    context: context,
                    itemName: po.poNumber,
                  );
                  if (confirmed && context.mounted) {
                    try {
                      final repository = ref.read(poRepositoryProvider);
                      await repository.deletePo(po.id);
                      ref.invalidate(posListProvider);
                      if (context.mounted) {
                        SnackbarUtils.showSuccess(
                          context,
                          'PO deleted successfully',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        SnackbarUtils.showError(
                          context,
                          'Failed to delete PO: ${e.toString()}',
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

/// Export POs to CSV
void _exportToCsv(
  BuildContext context,
  List<FabricationPoWithDetails> filteredPos,
) async {
  try {
    if (filteredPos.isEmpty) {
      SnackbarUtils.showInfo(context, 'No POs to export');
      return;
    }

    final csvContent = CsvExporter.posToCsv(filteredPos);
    final filename = CsvExporter.generateFilename('purchase_orders');

    await CsvExporter.downloadOrShareCsv(
      csvContent: csvContent,
      filename: filename,
    );

    if (context.mounted) {
      SnackbarUtils.showSuccess(context, 'Exported ${filteredPos.length} POs');
    }
  } catch (e) {
    if (context.mounted) {
      SnackbarUtils.showError(context, 'Failed to export CSV: ${e.toString()}');
    }
  }
}
