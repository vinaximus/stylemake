import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/providers/receipt_providers.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';
import 'package:stylemake/core/router/app_router.dart';

class ReceiptsListScreen extends ConsumerWidget {
  const ReceiptsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final receipts = ref.watch(filteredReceiptsProvider);
    final searchController = TextEditingController(text: ref.watch(receiptSearchQueryProvider));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts'),
        actions: [
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
              onChanged: (v) => ref.read(receiptSearchQueryProvider.notifier).state = v,
            ),
            const SizedBox(height: LayoutConstants.spaceMedium),

            Expanded(
              child: receipts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_outlined, size: 64, color: theme.colorScheme.outline),
                          const SizedBox(height: LayoutConstants.spaceMedium),
                          Text('No receipts found', style: theme.textTheme.titleMedium),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemBuilder: (context, index) {
                        final r = receipts[index];
                        return InkWell(
                          onTap: () => context.push(AppRouter.receiptsEdit(r.id)),
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
                                        '${r.cuttingRef} • ${r.styleName}',
                                        style: theme.textTheme.bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Qty: ${r.quantityReceived} • ${DateFormat('dd MMM yyyy').format(r.dateOfReceipt)}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: LayoutConstants.spaceSmall),
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


