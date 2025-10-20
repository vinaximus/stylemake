import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/router/app_router.dart';
import 'package:stylemake/core/utils/pdf_generator.dart';
import 'package:stylemake/core/utils/snackbar_utils.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';
import 'package:stylemake/features/production/providers/issue_providers.dart';
import 'package:stylemake/features/production/providers/po_providers.dart';

/// Purchase Order detail screen
class PoDetailScreen extends ConsumerWidget {
  const PoDetailScreen({required this.poId, super.key});

  final String poId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poAsync = ref.watch(poByIdProvider(poId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PO Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push(AppRouter.posEditPath(poId));
            },
            tooltip: 'Edit',
          ),
        ],
      ),
      body: poAsync.when(
        data: (po) {
          if (po == null) {
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
                  Text('PO not found', style: theme.textTheme.titleLarge),
                  const SizedBox(height: LayoutConstants.spaceLarge),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final isCompleted =
              po.completionDate != null &&
              po.completionDate!.isBefore(DateTime.now());

          return SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: LayoutConstants.maxFormWidth,
              padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // PO Information Card
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
                              Text(
                                po.poNumber,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              if (isCompleted)
                                Chip(
                                  label: const Text('Completed'),
                                  backgroundColor:
                                      theme.colorScheme.tertiaryContainer,
                                ),
                            ],
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.work_outline,
                            label: 'Job Order No',
                            value: po.jobOrderNo,
                          ),
                          const SizedBox(height: LayoutConstants.spaceSmall),
                          _InfoRow(
                            icon: Icons.precision_manufacturing,
                            label: 'Fabrication Type',
                            value: po.fabricationType,
                            valueWidget: Chip(
                              label: Text(
                                po.fabricationType,
                                style: const TextStyle(fontSize: 12),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const SizedBox(height: LayoutConstants.spaceSmall),
                          _InfoRow(
                            icon: Icons.calendar_today,
                            label: 'Issue Date',
                            value: DateFormat(
                              'dd/MM/yyyy',
                            ).format(po.dateOfIssue),
                          ),
                          if (po.completionDate != null) ...[
                            const SizedBox(height: LayoutConstants.spaceSmall),
                            _InfoRow(
                              icon: Icons.event_available,
                              label: 'Completion Date',
                              value: DateFormat(
                                'dd/MM/yyyy',
                              ).format(po.completionDate!),
                            ),
                          ],
                          const SizedBox(height: LayoutConstants.spaceSmall),
                          _InfoRow(
                            icon: Icons.content_cut,
                            label: 'Cutting Reference',
                            value: po.cuttingRef,
                            isLink: true,
                            onTap: () {
                              context.push(
                                AppRouter.cuttingsDetail(po.cuttingId),
                              );
                            },
                          ),
                          const SizedBox(height: LayoutConstants.spaceSmall),
                          _InfoRow(
                            icon: Icons.style,
                            label: 'Style',
                            value: po.styleName,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: LayoutConstants.spaceMedium),

                  // Vendor Information Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        LayoutConstants.paddingLarge,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vendor Information',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.business,
                            label: 'Vendor Name',
                            value: po.vendorName,
                          ),
                          if (po.vendorGst != null) ...[
                            const SizedBox(height: LayoutConstants.spaceSmall),
                            _InfoRow(
                              icon: Icons.receipt,
                              label: 'GST Number',
                              value: po.vendorGst!,
                            ),
                          ],
                          if (po.vendorCity != null) ...[
                            const SizedBox(height: LayoutConstants.spaceSmall),
                            _InfoRow(
                              icon: Icons.location_city,
                              label: 'City',
                              value: po.vendorCity!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: LayoutConstants.spaceMedium),

                  // Quantity & Rate Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        LayoutConstants.paddingLarge,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity & Rate',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.inventory_2_outlined,
                            label: 'Quantity Issued',
                            value: '${po.quantityIssued} pcs',
                          ),
                          const SizedBox(height: LayoutConstants.spaceSmall),
                          _InfoRow(
                            icon: Icons.currency_rupee,
                            label: 'Rate per Unit',
                            value: '₹${po.ratePerUnit.toStringAsFixed(2)}',
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₹${po.totalAmount.toStringAsFixed(2)}',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: LayoutConstants.spaceMedium),

                  // Instructions Card
                  if (po.instructions != null && po.instructions!.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          LayoutConstants.paddingLarge,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instructions',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 24),
                            Text(
                              po.instructions!,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: LayoutConstants.spaceMedium),

                  // Export to PDF Button
                  FilledButton.icon(
                    onPressed: () async {
                      try {
                        await PdfGenerator.generateAndShowPoPdf(po);
                      } catch (e) {
                        if (context.mounted) {
                          SnackbarUtils.showError(
                            context,
                            'Failed to generate PDF: ${e.toString()}',
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export to PDF'),
                  ),

                  const SizedBox(height: LayoutConstants.spaceLarge),

                  // Linked Issues Section
                  _IssuesSection(poId: poId),
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
                Text('Error loading PO', style: theme.textTheme.titleLarge),
                const SizedBox(height: LayoutConstants.spaceSmall),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: LayoutConstants.spaceLarge),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(poByIdProvider(poId));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueWidget,
    this.isLink = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? valueWidget;
  final bool isLink;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              valueWidget ??
                  (isLink
                      ? InkWell(
                          onTap: onTap,
                          child: Text(
                            value,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      : Text(value, style: theme.textTheme.bodyLarge)),
            ],
          ),
        ),
      ],
    );
  }
}

class _IssuesSection extends ConsumerWidget {
  const _IssuesSection({required this.poId});

  final String poId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final issuesAsync = ref.watch(issuesByPoProvider(poId));

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
                  'Item Issues',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.push('${AppRouter.issuesAdd}?poId=$poId');
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Issue'),
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
                            'Click "Add Issue" to record items issued for this PO',
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
                  children: [
                    // Issues list
                    ...issues.map((issue) {
                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: LayoutConstants.spaceSmall,
                        ),
                        color: theme.colorScheme.surfaceVariant.withOpacity(
                          0.3,
                        ),
                        child: InkWell(
                          onTap: () {
                            context.push(AppRouter.issuesEdit(issue.id));
                          },
                          borderRadius: BorderRadius.circular(
                            LayoutConstants.radiusMedium,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              LayoutConstants.paddingMedium,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        issue.itemDescription,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(issue.issueDate),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.chevron_right,
                                          size: 20,
                                          color: theme.colorScheme.outline,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Qty: ${issue.quantity} × ₹${issue.rate.toStringAsFixed(2)}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '₹${issue.totalAmount.toStringAsFixed(2)}',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const Divider(height: 24),
                    // Grand total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Issues Amount',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${grandTotal.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
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
