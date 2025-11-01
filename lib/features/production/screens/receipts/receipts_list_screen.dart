import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/models/receipt.dart';
import 'package:stylemake/core/providers/receipt_providers.dart';
import 'package:stylemake/core/utils/csv_exporter.dart';
import 'package:stylemake/core/utils/snackbar_utils.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';
import 'package:stylemake/core/widgets/dialogs/confirm_dialog.dart';
import 'package:stylemake/core/router/app_router.dart';

class ReceiptsListScreen extends ConsumerWidget {
  const ReceiptsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final receipts = ref.watch(filteredReceiptsProvider);
    final searchController = TextEditingController(
      text: ref.watch(receiptSearchQueryProvider),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export to CSV',
            onPressed: () => _exportReceiptsToCsv(context, receipts),
          ),
          IconButton(
            tooltip: 'Add',
            onPressed: () => context.push(AppRouter.receiptsAdd),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ResponsiveCenter(
        maxWidth: 900,
        padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by Receipt ID, Cutting Ref, Style',
              ),
              onChanged: (v) =>
                  ref.read(receiptSearchQueryProvider.notifier).state = v,
            ),
            const SizedBox(height: LayoutConstants.spaceMedium),

            Expanded(
              child: receipts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_outlined,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: LayoutConstants.spaceMedium),
                          Text(
                            'No receipts found',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemBuilder: (context, index) {
                        final r = receipts[index];
                        return Container(
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
                                child: InkWell(
                                  onTap: () =>
                                      context.push(AppRouter.receiptsEdit(r.id)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.receiptId,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${r.cuttingRef} • ${r.styleName}',
                                        style: theme.textTheme.bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Qty: ${r.quantityReceived} • ${DateFormat('dd MMM yyyy').format(r.dateOfReceipt)}',
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
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () =>
                                    context.push(AppRouter.receiptsEdit(r.id)),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => _deleteReceipt(
                                  context,
                                  ref,
                                  r.id,
                                  r.receiptId,
                                ),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: LayoutConstants.spaceSmall),
                      itemCount: receipts.length,
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRouter.receiptsAdd),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Delete a receipt
Future<void> _deleteReceipt(
  BuildContext context,
  WidgetRef ref,
  String receiptId,
  String receiptIdDisplay,
) async {
  final confirmed = await showDeleteConfirmDialog(
    context: context,
    itemName: receiptIdDisplay,
  );

  if (!confirmed || !context.mounted) return;

  try {
    final repository = ref.read(receiptRepositoryProvider);
    await repository.deleteReceipt(receiptId);

    if (context.mounted) {
      SnackbarUtils.showSuccess(context, 'Receipt deleted successfully');
      ref.invalidate(receiptsListProvider);
    }
  } catch (e) {
    if (context.mounted) {
      SnackbarUtils.showError(
        context,
        'Failed to delete receipt: ${e.toString()}',
      );
    }
  }
}

/// Export receipts to CSV
void _exportReceiptsToCsv(
  BuildContext context,
  List<ReceiptWithDetails> receipts,
) async {
  try {
    if (receipts.isEmpty) {
      SnackbarUtils.showInfo(context, 'No receipts to export');
      return;
    }

    final csvContent = CsvExporter.receiptsToCsv(receipts);
    final filename = CsvExporter.generateFilename('receipts');

    await CsvExporter.downloadOrShareCsv(
      csvContent: csvContent,
      filename: filename,
    );

    if (context.mounted) {
      SnackbarUtils.showSuccess(
        context,
        'Exported ${receipts.length} receipts',
      );
    }
  } catch (e) {
    if (context.mounted) {
      SnackbarUtils.showError(context, 'Failed to export CSV: ${e.toString()}');
    }
  }
}
