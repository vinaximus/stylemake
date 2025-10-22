import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/providers/production_summary_providers.dart';
import 'package:stylemake/core/utils/csv_exporter.dart';
import 'package:stylemake/features/masters/providers/style_providers.dart';

class ProductionSummaryScreen extends ConsumerWidget {
  const ProductionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final totalsAsync = ref.watch(productionSummaryTotalsProvider);
    final stylesAsync = ref.watch(stylesListProvider);
    final range = ref.watch(summaryDateRangeProvider);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Production Summary')),
      body: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Date range display (read-only for v0.5)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${dateFormat.format(range.start)}  —  ${dateFormat.format(range.end)}'),
                ),
                // Style filter
                stylesAsync.when(
                  data: (styles) {
                    return DropdownButton<String?>(
                      value: ref.watch(summaryStyleFilterProvider),
                      hint: const Text('Filter by Style'),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('All Styles')),
                        ...styles.map((s) => DropdownMenuItem<String?>(value: s.id, child: Text(s.name))),
                      ],
                      onChanged: (v) => ref.read(summaryStyleFilterProvider.notifier).state = v,
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: LayoutConstants.spaceLarge),
            totalsAsync.when(
              data: (t) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KPIs', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const Divider(height: 24),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _kpi('Qty Cut', t.qtyCut.toString(), theme),
                            _kpi('Qty Issued', t.qtyIssued.toString(), theme),
                            _kpi('Qty Received', t.qtyReceived.toString(), theme),
                            _kpi('Total Bill Cost', '₹${t.totalBillCost.toStringAsFixed(2)}', theme),
                          ],
                        ),
                        const SizedBox(height: LayoutConstants.spaceLarge),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: () {
                              final rows = [
                                {
                                  'Qty Cut': t.qtyCut,
                                  'Qty Issued': t.qtyIssued,
                                  'Qty Received': t.qtyReceived,
                                  'Total Bill Cost': t.totalBillCost.toStringAsFixed(2),
                                }
                              ];
                              final csv = CsvExporter.listOfMapsToCsv(rows);
                              // For now, just show a dialog with CSV; integration with sharing/downloading can be added
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('CSV Export'),
                                  content: SingleChildScrollView(child: Text(csv)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Export CSV'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error loading summary: $e', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpi(String label, String value, ThemeData theme) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}


