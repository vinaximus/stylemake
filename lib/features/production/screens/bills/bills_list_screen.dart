import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/models/bill.dart';
import 'package:stylemake/core/router/app_router.dart';
import 'package:stylemake/core/utils/snackbar_utils.dart';
import 'package:stylemake/core/widgets/app_fab.dart';
import 'package:stylemake/core/widgets/dialogs/confirm_dialog.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';
import 'package:stylemake/features/production/providers/bill_providers.dart';
import 'package:stylemake/features/production/providers/po_providers.dart';

/// Bills list screen
class BillsListScreen extends ConsumerWidget {
  const BillsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billsListProvider);
    final filteredBills = ref.watch(filteredBillsProvider);
    final searchQuery = ref.watch(billSearchQueryProvider);
    final poFilter = ref.watch(billPoFilterProvider);
    final vendorFilter = ref.watch(billVendorFilterProvider);
    final dateRange = ref.watch(billDateRangeProvider);
    final posAsync = ref.watch(posListProvider);

    final hasActiveFilters =
        poFilter != null || vendorFilter != null || dateRange != null;
    final activeFilterCount = [
      if (poFilter != null) 1,
      if (vendorFilter != null) 1,
      if (dateRange != null) 1,
    ].length;

    // Build PO dropdown items
    final poDropdownItems = posAsync.when(
      data: (pos) => pos
          .map(
            (po) => DropdownMenuItem(
              value: po.id,
              child: Text('${po.poNumber} - ${po.vendorName}'),
            ),
          )
          .toList(),
      loading: () => <DropdownMenuItem<String>>[],
      error: (_, __) => <DropdownMenuItem<String>>[],
    );

    // Build unique vendor list from bills
    final vendorDropdownItems = billsAsync.when(
      data: (bills) {
        final uniqueVendors = <String, String>{};
        for (final bill in bills) {
          if (bill.vendorId != null) {
            uniqueVendors[bill.vendorId!] = bill.vendorName;
          }
        }
        return uniqueVendors.entries
            .map(
              (entry) =>
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
            )
            .toList();
      },
      loading: () => <DropdownMenuItem<String>>[],
      error: (_, __) => <DropdownMenuItem<String>>[],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills'),
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
                    hintText: 'Search by invoice number, PO, or vendor...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(billSearchQueryProvider.notifier).state = value;
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
                      child: DropdownButtonFormField<String>(
                        value: poFilter,
                        decoration: const InputDecoration(
                          labelText: 'PO',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All POs'),
                          ),
                          ...poDropdownItems,
                        ],
                        onChanged: (value) {
                          ref.read(billPoFilterProvider.notifier).state = value;
                        },
                      ),
                    ),
                    const SizedBox(width: LayoutConstants.spaceSmall),
                    // Vendor filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: vendorFilter,
                        decoration: const InputDecoration(
                          labelText: 'Vendor',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Vendors'),
                          ),
                          ...vendorDropdownItems,
                        ],
                        onChanged: (value) {
                          ref.read(billVendorFilterProvider.notifier).state =
                              value;
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
                            ref.read(billDateRangeProvider.notifier).state =
                                picked;
                          }
                        },
                        icon: const Icon(Icons.date_range, size: 16),
                        label: Text(
                          dateRange == null
                              ? 'Date Range'
                              : '${DateFormat('dd/MM/yy').format(dateRange.start)}-${DateFormat('dd/MM/yy').format(dateRange.end)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
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
                            ref.invalidate(billPoFilterProvider);
                            ref.invalidate(billVendorFilterProvider);
                            ref.invalidate(billDateRangeProvider);
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
        child: billsAsync.when(
          data: (_) {
            if (filteredBills.isEmpty) {
              final hasData = billsAsync.value?.isNotEmpty ?? false;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasData && searchQuery.isNotEmpty
                          ? Icons.search_off
                          : Icons.request_quote_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: LayoutConstants.spaceLarge),
                    Text(
                      hasData && searchQuery.isNotEmpty
                          ? 'No bills found'
                          : 'No Bills yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: LayoutConstants.spaceSmall),
                    Text(
                      hasData && searchQuery.isNotEmpty
                          ? 'Try adjusting your search or filters'
                          : 'Create your first bill to get started',
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
                ref.invalidate(billsListProvider);
              },
              child: ListView.builder(
                itemCount: filteredBills.length,
                itemBuilder: (context, index) {
                  final bill = filteredBills[index];
                  return _BillCard(bill: bill);
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
                  'Error loading bills',
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
                    ref.invalidate(billsListProvider);
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
        onPressed: () => context.push(AppRouter.billsAdd),
        label: 'Add Bill',
        icon: Icons.add,
      ),
    );
  }
}

class _BillCard extends ConsumerWidget {
  const _BillCard({required this.bill});

  final BillWithDetails bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: LayoutConstants.spaceSmall),
      child: InkWell(
        onTap: () {
          context.push(AppRouter.billsEdit(bill.id));
        },
        borderRadius: BorderRadius.circular(LayoutConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.tertiaryContainer,
                foregroundColor: theme.colorScheme.onTertiaryContainer,
                child: const Icon(Icons.request_quote),
              ),
              const SizedBox(width: LayoutConstants.spaceMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.supplierInvoiceNo,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            bill.poNumber,
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
                            bill.vendorName,
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(bill.invoiceDate)} • Qty: ${bill.quantity} • Rate: ₹${bill.rate.toStringAsFixed(2)} • Total: ₹${bill.totalAmount.toStringAsFixed(2)}',
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
                  context.push(AppRouter.billsEdit(bill.id));
                },
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () async {
                  final confirmed = await showDeleteConfirmDialog(
                    context: context,
                    itemName: bill.supplierInvoiceNo,
                  );
                  if (confirmed && context.mounted) {
                    try {
                      final repository = ref.read(billRepositoryProvider);
                      await repository.deleteBill(bill.id);
                      ref.invalidate(billsListProvider);
                      if (context.mounted) {
                        SnackbarUtils.showSuccess(
                          context,
                          'Bill deleted successfully',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        SnackbarUtils.showError(
                          context,
                          'Failed to delete bill: ${e.toString()}',
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
