import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/shared/constants/layout_constants.dart';
import 'package:stylemake/features/dispatch/data/models/dispatch_master.dart';
import 'package:stylemake/features/dispatch/data/models/dispatch_item.dart';
import 'package:stylemake/app/router/app_router.dart';
import 'package:stylemake/shared/utils/snackbar_utils.dart';
import 'package:stylemake/shared/widgets/dialogs/confirm_dialog.dart';
import 'package:stylemake/shared/widgets/responsive_center.dart';
import 'package:stylemake/features/dispatch/presentation/viewmodels/dispatch_view_model.dart';

/// Dispatch detail screen
class DispatchDetailScreen extends ConsumerWidget {
  const DispatchDetailScreen({super.key, required this.dispatchId});

  final String dispatchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dispatchAsync = ref.watch(dispatchProvider(dispatchId));
    final itemsAsync = ref.watch(dispatchItemsProvider(dispatchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push(AppRouter.dispatchesEdit(dispatchId));
            },
            tooltip: 'Edit Dispatch',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, ref, dispatchAsync),
            tooltip: 'Delete Dispatch',
          ),
        ],
      ),
      body: dispatchAsync.when(
        data: (dispatch) {
          if (dispatch == null) {
            return _buildNotFoundState(context);
          }

          return ResponsiveFormContainer(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDispatchInfoCard(context, dispatch),
                  const SizedBox(height: LayoutConstants.spaceMedium),
                  _buildCustomerInfoCard(context, dispatch),
                  const SizedBox(height: LayoutConstants.spaceMedium),
                  _buildTransportInfoCard(context, dispatch),
                  const SizedBox(height: LayoutConstants.spaceMedium),
                  _buildItemsSection(context, itemsAsync),
                  const SizedBox(height: LayoutConstants.spaceMedium),
                  if (dispatch.remarks != null && dispatch.remarks!.isNotEmpty)
                    _buildRemarksCard(context, dispatch),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, ref, error),
      ),
    );
  }

  Widget _buildDispatchInfoCard(BuildContext context, DispatchMaster dispatch) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dispatch Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: LayoutConstants.spaceMedium),
            _buildInfoRow(context, 'Dispatch No', dispatch.dispatchNo),
            _buildInfoRow(
              context,
              'Date',
              DateFormat('MMM dd, yyyy').format(dispatch.dispatchDate),
            ),
            _buildInfoRow(
              context,
              'Total Quantity',
              dispatch.totalQuantity.toInt().toString(),
            ),
            _buildInfoRow(
              context,
              'Created',
              DateFormat('MMM dd, yyyy HH:mm').format(dispatch.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard(BuildContext context, DispatchMaster dispatch) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: LayoutConstants.spaceMedium),
            _buildInfoRow(context, 'Customer ID', dispatch.customerId),
            // Note: In a real implementation, we'd fetch customer details
            _buildInfoRow(context, 'Customer Name', 'Loading...'),
            _buildInfoRow(context, 'Contact', 'Loading...'),
            _buildInfoRow(context, 'Phone', 'Loading...'),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportInfoCard(
    BuildContext context,
    DispatchMaster dispatch,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transport Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: LayoutConstants.spaceMedium),
            _buildInfoRow(
              context,
              'Transport Name',
              dispatch.transportName ?? 'Not specified',
            ),
            _buildInfoRow(
              context,
              'Vehicle No',
              dispatch.vehicleNo ?? 'Not specified',
            ),
            _buildInfoRow(context, 'LR No', dispatch.lrNo ?? 'Not specified'),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(
    BuildContext context,
    AsyncValue<List<DispatchItem>> itemsAsync,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dispatch Items',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: LayoutConstants.spaceMedium),
            itemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Text('No items found');
                }

                return Column(
                  children: items
                      .map((item) => _buildItemCard(context, item))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error loading items: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, DispatchItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: LayoutConstants.spaceSmall),
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Style ID: ${item.styleId}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Qty: ${item.quantity.toInt()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: LayoutConstants.spaceSmall),
            if (item.color != null && item.color!.isNotEmpty)
              _buildItemInfoRow(context, 'Color', item.color!),
            if (item.size != null && item.size!.isNotEmpty)
              _buildItemInfoRow(context, 'Size', item.size!),
            if (item.rate != null)
              _buildItemInfoRow(
                context,
                'Rate',
                '₹${item.rate!.toStringAsFixed(2)}',
              ),
            if (item.remarks != null && item.remarks!.isNotEmpty)
              _buildItemInfoRow(context, 'Remarks', item.remarks!),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarksCard(BuildContext context, DispatchMaster dispatch) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remarks',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: LayoutConstants.spaceSmall),
            Text(dispatch.remarks!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: LayoutConstants.spaceXSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildItemInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: LayoutConstants.spaceMedium),
          Text(
            'Dispatch not found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: LayoutConstants.spaceSmall),
          Text(
            'The dispatch you are looking for does not exist or has been deleted.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LayoutConstants.spaceLarge),
          ElevatedButton(
            onPressed: () => context.go(AppRouter.dispatchesList),
            child: const Text('Back to Dispatches'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: LayoutConstants.spaceMedium),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: LayoutConstants.spaceSmall),
          Text(
            'Failed to load dispatch: $error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LayoutConstants.spaceLarge),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(dispatchProvider(dispatchId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<DispatchMaster?> dispatchAsync,
  ) async {
    final dispatch = dispatchAsync.value;
    if (dispatch == null) return;

    final confirmed = await showDeleteConfirmDialog(
      context: context,
      itemName: dispatch.dispatchNo,
    );

    if (!confirmed) return;

    try {
      final repository = ref.read(dispatchRepositoryProvider);
      await repository.deleteDispatch(dispatch.id);

      // Invalidate providers to refresh the list
      ref.invalidate(dispatchesListProvider);
      ref.invalidate(filteredDispatchesProvider);

      if (context.mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Dispatch "${dispatch.dispatchNo}" deleted successfully',
        );
        context.go(AppRouter.dispatchesList);
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showError(context, 'Failed to delete dispatch: $e');
      }
    }
  }
}
