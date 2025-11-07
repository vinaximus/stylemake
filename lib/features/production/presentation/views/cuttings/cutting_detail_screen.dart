import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/shared/constants/layout_constants.dart';
import 'package:stylemake/app/router/app_router.dart';
import 'package:stylemake/shared/widgets/responsive_center.dart';
import 'package:stylemake/features/production/presentation/viewmodels/bill_view_model.dart';
import 'package:stylemake/features/production/presentation/viewmodels/cutting_view_model.dart';
import 'package:stylemake/features/production/presentation/viewmodels/issue_view_model.dart';
import 'package:stylemake/features/production/presentation/viewmodels/po_view_model.dart';
import 'package:stylemake/features/production/presentation/viewmodels/receipt_view_model.dart';

/// Cutting detail screen showing cutting information and linked POs
class CuttingDetailScreen extends ConsumerWidget {
  const CuttingDetailScreen({required this.cuttingId, super.key});

  final String cuttingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuttingAsync = ref.watch(cuttingByIdProvider(cuttingId));
    final posAsync = ref.watch(posByCuttingProvider(cuttingId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cutting Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push(AppRouter.cuttingsEdit(cuttingId));
            },
            tooltip: 'Edit',
          ),
        ],
      ),
      body: cuttingAsync.when(
        data: (cutting) {
          if (cutting == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: LayoutConstants.spaceLarge),
                  Text('Cutting not found', style: theme.textTheme.titleLarge),
                  const SizedBox(height: LayoutConstants.spaceLarge),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: 800.0,
              padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cutting Information Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        LayoutConstants.paddingLarge,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cutting Information',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Cutting Reference',
                            cutting.cuttingRef,
                            Icons.tag,
                          ),
                          const SizedBox(height: LayoutConstants.spaceMedium),
                          _buildInfoRow(
                            'Cutting Date',
                            DateFormat(
                              'dd MMMM yyyy',
                            ).format(cutting.cuttingDate),
                            Icons.calendar_today,
                          ),
                          const SizedBox(height: LayoutConstants.spaceMedium),
                          _buildInfoRow(
                            'Style',
                            cutting.styleName,
                            Icons.style,
                          ),
                          const SizedBox(height: LayoutConstants.spaceMedium),
                          _buildInfoRow(
                            'Quantity Cut',
                            '${cutting.quantityCut} pieces',
                            Icons.inventory_2,
                          ),
                          if (cutting.notes != null &&
                              cutting.notes!.isNotEmpty) ...[
                            const SizedBox(height: LayoutConstants.spaceMedium),
                            _buildInfoRow('Notes', cutting.notes!, Icons.note),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: LayoutConstants.spaceLarge),

                  // Fabrication POs Section (placeholder for Phase 5)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        LayoutConstants.paddingLarge,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Purchase Orders',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.icon(
                                onPressed: () {
                                  context.push(
                                    '${AppRouter.posAdd}?cuttingId=$cuttingId',
                                  );
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          posAsync.when(
                            data: (pos) {
                              if (pos.isEmpty) {
                                return Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        size: 64,
                                        color: theme.colorScheme.outline,
                                      ),
                                      const SizedBox(
                                        height: LayoutConstants.spaceMedium,
                                      ),
                                      Text(
                                        'No POs linked yet',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      const SizedBox(
                                        height: LayoutConstants.spaceSmall,
                                      ),
                                      Text(
                                        'Click "Create PO" to add a purchase order',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${pos.length} Purchase ${pos.length == 1 ? 'Order' : 'Orders'}',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: LayoutConstants.spaceSmall,
                                  ),
                                  ...pos.map(
                                    (po) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: LayoutConstants.spaceSmall,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          context.push(
                                            AppRouter.posDetailPath(po.id),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: theme.colorScheme.outline
                                                  .withOpacity(0.5),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.receipt_long,
                                                size: 20,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      po.poNumber,
                                                      style: theme
                                                          .textTheme
                                                          .titleSmall
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${po.vendorName} • ${po.fabricationType}',
                                                      style: theme
                                                          .textTheme
                                                          .bodySmall,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                    Text(
                                                      po.orderItems != null && po.orderItems!.isNotEmpty
                                                          ? '${po.orderItems!.length} item(s) • ₹${po.totalAmountFromItems.toStringAsFixed(2)}'
                                                          : 'No items • ₹0.00',
                                                      style: theme
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: theme
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right,
                                                color:
                                                    theme.colorScheme.outline,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stack) => Center(
                              child: Text(
                                'Error loading POs',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: LayoutConstants.spaceLarge),

                  // Item Issues Section (Phase 6)
                  _IssuesSection(cuttingId: cuttingId),

                  const SizedBox(height: LayoutConstants.spaceLarge),

                  // Bills Section (Phase 7)
                  _BillsSection(cuttingId: cuttingId),

          const SizedBox(height: LayoutConstants.spaceLarge),

          // Receipts Section (Phase 8)
          _ReceiptsSection(cuttingId: cuttingId),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: LayoutConstants.spaceLarge),
                Text(
                  'Error loading cutting',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: LayoutConstants.spaceSmall),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: LayoutConstants.spaceLarge),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: LayoutConstants.spaceSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IssuesSection extends ConsumerWidget {
  const _IssuesSection({required this.cuttingId});

  final String cuttingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final issuesAsync = ref.watch(issuesByCuttingProvider(cuttingId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item Issues',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            issuesAsync.when(
              data: (issues) {
                if (issues.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        LayoutConstants.paddingLarge,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_outlined,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: LayoutConstants.spaceMedium),
                          Text(
                            'No issues recorded yet',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: LayoutConstants.spaceSmall),
                          Text(
                            'Issues will appear here when items are issued for linked POs',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Calculate grand total
                final grandTotal = issues.fold<double>(
                  0,
                  (sum, issue) => sum + issue.totalAmount,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${issues.length} ${issues.length == 1 ? 'Issue' : 'Issues'} recorded',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: LayoutConstants.spaceSmall),
                    // Issues cards
                    ...issues.map(
                      (issue) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: LayoutConstants.spaceSmall,
                        ),
                        child: InkWell(
                          onTap: () {
                            context.push(AppRouter.issuesEdit(issue.id));
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.5,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.inventory_2,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        issue.itemDescription,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'PO: ${issue.poNumber}',
                                        style: theme.textTheme.bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Qty: ${issue.quantity} × ₹${issue.rate.toStringAsFixed(2)} = ₹${issue.totalAmount.toStringAsFixed(2)}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: theme.colorScheme.outline,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    // Grand total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            'Total Issues Amount',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '₹${grandTotal.toStringAsFixed(2)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(LayoutConstants.paddingLarge),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: LayoutConstants.spaceMedium),
                      Text(
                        'Error loading issues',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: LayoutConstants.spaceSmall),
                      Text(
                        error.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillsSection extends ConsumerWidget {
  const _BillsSection({required this.cuttingId});

  final String cuttingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final billsAsync = ref.watch(billsByCuttingProvider(cuttingId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bills',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            billsAsync.when(
              data: (bills) {
                if (bills.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        LayoutConstants.paddingLarge,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.request_quote_outlined,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: LayoutConstants.spaceMedium),
                          Text(
                            'No bills recorded yet',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: LayoutConstants.spaceSmall),
                          Text(
                            'Bills will appear here when invoices are recorded for linked POs',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Calculate grand total
                final grandTotal = bills.fold<double>(
                  0,
                  (sum, bill) => sum + bill.totalAmount,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${bills.length} ${bills.length == 1 ? 'Bill' : 'Bills'} recorded',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: LayoutConstants.spaceSmall),
                    // Bills cards
                    ...bills.map(
                      (bill) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: LayoutConstants.spaceSmall,
                        ),
                        child: InkWell(
                          onTap: () {
                            context.push(AppRouter.billsEdit(bill.id));
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.5,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.request_quote,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bill.supplierInvoiceNo,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'PO: ${bill.poNumber} • ${bill.vendorName}',
                                        style: theme.textTheme.bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                      Text(
                                        'Qty: ${bill.quantity} × ₹${bill.rate.toStringAsFixed(2)} = ₹${bill.totalAmount.toStringAsFixed(2)}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: theme.colorScheme.outline,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    // Grand total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            'Total Bills Amount',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '₹${grandTotal.toStringAsFixed(2)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(LayoutConstants.paddingLarge),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: LayoutConstants.spaceMedium),
                      Text(
                        'Error loading bills',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: LayoutConstants.spaceSmall),
                      Text(
                        error.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptsSection extends ConsumerWidget {
  const _ReceiptsSection({required this.cuttingId});

  final String cuttingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final receiptsAsync = ref.watch(receiptsByCuttingProvider(cuttingId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Receipts',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    context.push('${AppRouter.receiptsAdd}?cuttingId=$cuttingId');
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            receiptsAsync.when(
              data: (receipts) {
                if (receipts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_outlined,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: LayoutConstants.spaceMedium),
                          Text('No receipts recorded yet', style: theme.textTheme.titleMedium),
                          const SizedBox(height: LayoutConstants.spaceSmall),
                          Text(
                            'Receipts will appear here when finished goods are recorded for this cutting',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final totalReceived = receipts.fold<int>(0, (sum, r) => sum + r.quantityReceived);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${receipts.length} ${receipts.length == 1 ? 'Receipt' : 'Receipts'} recorded',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: LayoutConstants.spaceSmall),
                    ...receipts.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: LayoutConstants.spaceSmall),
                        child: InkWell(
                          onTap: () {
                            context.push(AppRouter.receiptsEdit(r.id));
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.inventory_2, size: 20, color: theme.colorScheme.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.receiptId,
                                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Qty: ${r.quantityReceived}',
                                        style: theme.textTheme.bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Quantity Received',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$totalReceived',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(LayoutConstants.paddingLarge),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: LayoutConstants.spaceMedium),
                      Text('Error loading receipts', style: theme.textTheme.titleMedium),
                      const SizedBox(height: LayoutConstants.spaceSmall),
                      Text(
                        error.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
