import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/shared/constants/layout_constants.dart';
import 'package:stylemake/features/dispatch/data/models/dispatch_master.dart';
import 'package:stylemake/app/router/app_router.dart';
import 'package:stylemake/shared/utils/snackbar_utils.dart';
import 'package:stylemake/shared/widgets/app_fab.dart';
import 'package:stylemake/shared/widgets/dialogs/confirm_dialog.dart';
import 'package:stylemake/shared/widgets/list_card_item.dart';
import 'package:stylemake/shared/widgets/responsive_center.dart';
import 'package:stylemake/features/dispatch/presentation/viewmodels/dispatch_view_model.dart';

/// Dispatch list screen
class DispatchesListScreen extends ConsumerStatefulWidget {
  const DispatchesListScreen({super.key});

  @override
  ConsumerState<DispatchesListScreen> createState() =>
      _DispatchesListScreenState();
}

class _DispatchesListScreenState extends ConsumerState<DispatchesListScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh the list when the app becomes active
      ref.invalidate(dispatchesListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dispatchesAsync = ref.watch(dispatchesListProvider);
    final filteredDispatches = ref.watch(filteredDispatchesProvider);
    final searchQuery = ref.watch(dispatchSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by dispatch no, vehicle, or LR no...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(dispatchSearchQueryProvider.notifier).state =
                              '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    LayoutConstants.radiusSmall,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onChanged: (value) {
                ref.read(dispatchSearchQueryProvider.notifier).state = value;
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dispatchesListProvider);
        },
        child: dispatchesAsync.when(
          data: (dispatches) {
            if (dispatches.isEmpty) {
              return _buildEmptyState(context);
            }

            if (filteredDispatches.isEmpty && searchQuery.isNotEmpty) {
              return _buildNoResultsState(context, searchQuery);
            }

            return ResponsiveListContainer(
              child: ListView.builder(
                padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
                itemCount: filteredDispatches.length,
                itemBuilder: (context, index) {
                  final dispatch = filteredDispatches[index];
                  return _buildDispatchCard(dispatch);
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
          context.push(AppRouter.dispatchesAdd);
        },
        label: 'Add Dispatch',
        icon: Icons.add,
      ),
    );
  }

  Widget _buildDispatchCard(DispatchMaster dispatch) {
    return ListCardItem(
      title: dispatch.dispatchNo,
      subtitle: _buildSubtitleText(dispatch),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          dispatch.dispatchNo.isNotEmpty ? dispatch.dispatchNo[0] : 'D',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      trailing: [
        IconButton(
          icon: const Icon(Icons.visibility),
          onPressed: () {
            context.push(AppRouter.dispatchesDetail(dispatch.id));
          },
          tooltip: 'View Details',
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            context.push(AppRouter.dispatchesEdit(dispatch.id));
          },
          tooltip: 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () =>
              _deleteDispatch(context, ref, dispatch.id, dispatch.dispatchNo),
          tooltip: 'Delete',
        ),
      ],
      onTap: () {
        context.push(AppRouter.dispatchesDetail(dispatch.id));
      },
    );
  }

  String _buildSubtitleText(DispatchMaster dispatch) {
    final parts = <String>[];

    // Add customer info (we'll need to fetch this separately for now)
    parts.add('Customer: Loading...');

    // Add date
    parts.add(
      'Date: ${DateFormat('MMM dd, yyyy').format(dispatch.dispatchDate)}',
    );

    // Add quantity
    parts.add('Qty: ${dispatch.totalQuantity.toInt()}');

    // Add vehicle if available
    if (dispatch.vehicleNo != null && dispatch.vehicleNo!.isNotEmpty) {
      parts.add('Vehicle: ${dispatch.vehicleNo}');
    }

    return parts.join(' • ');
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: LayoutConstants.spaceMedium),
          Text(
            'No dispatches found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: LayoutConstants.spaceSmall),
          Text(
            'Add your first dispatch to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context, String query) {
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
            'No dispatches match "$query"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
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
            'Failed to load dispatches: $error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LayoutConstants.spaceLarge),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(dispatchesListProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDispatch(
    BuildContext context,
    WidgetRef ref,
    String id,
    String dispatchNo,
  ) async {
    final confirmed = await showDeleteConfirmDialog(
      context: context,
      itemName: dispatchNo,
    );

    if (!confirmed) return;

    try {
      final repository = ref.read(dispatchRepositoryProvider);
      await repository.deleteDispatch(id);

      // Invalidate providers to refresh the list
      ref.invalidate(dispatchesListProvider);
      ref.invalidate(filteredDispatchesProvider);

      if (context.mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Dispatch "$dispatchNo" deleted successfully',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showError(context, 'Failed to delete dispatch: $e');
      }
    }
  }
}
