import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/shared/constants/layout_constants.dart';
import 'package:stylemake/features/masters/data/models/customer.dart';
import 'package:stylemake/app/router/app_router.dart';
import 'package:stylemake/shared/utils/snackbar_utils.dart';
import 'package:stylemake/shared/widgets/app_fab.dart';
import 'package:stylemake/shared/widgets/dialogs/confirm_dialog.dart';
import 'package:stylemake/shared/widgets/list_card_item.dart';
import 'package:stylemake/shared/widgets/responsive_center.dart';
import 'package:stylemake/features/masters/presentation/viewmodels/customer_view_model.dart';

/// Screen for displaying and managing customers
class CustomersListScreen extends ConsumerStatefulWidget {
  const CustomersListScreen({super.key});

  @override
  ConsumerState<CustomersListScreen> createState() =>
      _CustomersListScreenState();
}

class _CustomersListScreenState extends ConsumerState<CustomersListScreen>
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
      ref.invalidate(customersListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersListProvider);
    final filteredCustomers = ref.watch(filteredCustomersProvider);
    final searchQuery = ref.watch(customerSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Master'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(customerSearchQueryProvider.notifier).state =
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
                ref.read(customerSearchQueryProvider.notifier).state = value;
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(customersListProvider);
        },
        child: customersAsync.when(
          data: (customers) {
            if (customers.isEmpty) {
              return _buildEmptyState(context);
            }

            if (filteredCustomers.isEmpty && searchQuery.isNotEmpty) {
              return _buildNoResultsState(context, searchQuery);
            }

            return ResponsiveListContainer(
              child: ListView.builder(
                padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
                itemCount: filteredCustomers.length,
                itemBuilder: (context, index) {
                  final customer = filteredCustomers[index];
                  return _buildCustomerCard(customer);
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
          context.push(AppRouter.customersAdd);
        },
        label: 'Add Customer',
        icon: Icons.add,
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return ListCardItem(
      title: customer.customerName,
      subtitle: _buildSubtitleText(customer),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          customer.customerName.isNotEmpty
              ? customer.customerName[0].toUpperCase()
              : 'C',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      trailing: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            context.push(AppRouter.customersEdit(customer.id));
          },
          tooltip: 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () =>
              _deleteCustomer(context, ref, customer.id, customer.customerName),
          tooltip: 'Delete',
        ),
      ],
      onTap: () {
        // Could navigate to detail view in future
      },
    );
  }

  String _buildSubtitleText(Customer customer) {
    final parts = <String>[];

    if (customer.contactPerson != null && customer.contactPerson!.isNotEmpty) {
      parts.add(customer.contactPerson!);
    }

    if (customer.phone != null && customer.phone!.isNotEmpty) {
      parts.add(customer.phone!);
    }

    if (parts.isEmpty) {
      return 'Created: ${DateFormat('MMM dd, yyyy').format(customer.createdAt)}';
    }

    return '${parts.join(' • ')} • Created: ${DateFormat('MMM dd, yyyy').format(customer.createdAt)}';
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: LayoutConstants.spaceMedium),
          Text(
            'No customers found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: LayoutConstants.spaceSmall),
          Text(
            'Add your first customer to get started',
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
            'No customers match "$query"',
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
            'Failed to load customers: $error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LayoutConstants.spaceLarge),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(customersListProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final confirmed = await showDeleteConfirmDialog(
      context: context,
      itemName: name,
    );

    if (!confirmed) return;

    try {
      final repository = ref.read(customerRepositoryProvider);
      await repository.deleteCustomer(id);

      // Invalidate providers to refresh the list
      ref.invalidate(customersListProvider);
      ref.invalidate(filteredCustomersProvider);

      if (context.mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Customer "$name" deleted successfully',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showError(context, 'Failed to delete customer: $e');
      }
    }
  }
}
