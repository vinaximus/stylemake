import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/utils/snackbar_utils.dart';
import 'package:stylemake/core/widgets/app_fab.dart';
import 'package:stylemake/core/widgets/dialogs/confirm_dialog.dart';
import 'package:stylemake/core/widgets/list_card_item.dart';
import 'package:stylemake/features/masters/providers/vendor_providers.dart';

/// Vendor Master list screen
class VendorsListScreen extends ConsumerWidget {
  const VendorsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorsAsync = ref.watch(vendorsListProvider);
    final filteredVendors = ref.watch(filteredVendorsProvider);
    final searchQuery = ref.watch(vendorSearchQueryProvider);
    final cityFilter = ref.watch(vendorCityFilterProvider);
    final citiesAsync = ref.watch(vendorCitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Master'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.paddingMedium,
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search vendors...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(vendorSearchQueryProvider.notifier).state = value;
                  },
                ),
              ),
              const SizedBox(height: LayoutConstants.spaceSmall),
              SizedBox(
                height: 50,
                child: citiesAsync.when(
                  data: (cities) {
                    if (cities.isEmpty) return const SizedBox.shrink();
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: LayoutConstants.paddingMedium,
                      ),
                      children: [
                        if (cityFilter != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: const Text('Clear filter'),
                              onPressed: () {
                                ref
                                        .read(vendorCityFilterProvider.notifier)
                                        .state =
                                    null;
                              },
                              avatar: const Icon(Icons.close, size: 16),
                            ),
                          ),
                        ...cities.map((city) {
                          final isSelected = cityFilter == city;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(city),
                              selected: isSelected,
                              onSelected: (selected) {
                                ref
                                    .read(vendorCityFilterProvider.notifier)
                                    .state = selected
                                    ? city
                                    : null;
                              },
                            ),
                          );
                        }),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(vendorsListProvider);
          ref.invalidate(vendorCitiesProvider);
        },
        child: vendorsAsync.when(
          data: (vendors) {
            if (vendors.isEmpty) {
              return _buildEmptyState(context);
            }

            if (filteredVendors.isEmpty &&
                (searchQuery.isNotEmpty || cityFilter != null)) {
              return _buildNoResultsState(context, searchQuery, cityFilter);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
              itemCount: filteredVendors.length,
              itemBuilder: (context, index) {
                final vendor = filteredVendors[index];
                return ListCardItem(
                  title: vendor.name,
                  subtitle: _buildVendorSubtitle(vendor),
                  leading: CircleAvatar(
                    child: Text(
                      vendor.name.isNotEmpty
                          ? vendor.name[0].toUpperCase()
                          : 'V',
                    ),
                  ),
                  trailing: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        context.go('/masters/vendors/${vendor.id}/edit');
                      },
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          _deleteVendor(context, ref, vendor.id, vendor.name),
                      tooltip: 'Delete',
                    ),
                  ],
                  onTap: () {
                    // Could navigate to detail view in future
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(context, ref, error),
        ),
      ),
      floatingActionButton: AppFab(
        onPressed: () {
          context.go('/masters/vendors/add');
        },
        label: 'Add Vendor',
        icon: Icons.add,
      ),
    );
  }

  String _buildVendorSubtitle(vendor) {
    final parts = <String>[];
    if (vendor.city != null && vendor.city!.isNotEmpty) {
      parts.add(vendor.city!);
    }
    if (vendor.gst != null && vendor.gst!.isNotEmpty) {
      parts.add('GST: ${vendor.gst}');
    }
    return parts.isEmpty ? 'No additional info' : parts.join(' • ');
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: LayoutConstants.spaceLarge),
          Text('No vendors yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: LayoutConstants.spaceSmall),
          Text(
            'Tap the + button to add your first vendor',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(
    BuildContext context,
    String query,
    String? cityFilter,
  ) {
    final filters = <String>[];
    if (query.isNotEmpty) filters.add('"$query"');
    if (cityFilter != null) filters.add('city: $cityFilter');

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
            'No vendors match ${filters.join(" and ")}',
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
      child: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
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
              'Error loading vendors',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: LayoutConstants.spaceSmall),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LayoutConstants.spaceLarge),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(vendorsListProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteVendor(
    BuildContext context,
    WidgetRef ref,
    String vendorId,
    String vendorName,
  ) async {
    final confirmed = await showDeleteConfirmDialog(
      context: context,
      itemName: vendorName,
    );

    if (!confirmed || !context.mounted) return;

    try {
      final repository = ref.read(vendorRepositoryProvider);
      await repository.deleteVendor(vendorId);

      if (context.mounted) {
        SnackbarUtils.showSuccess(context, 'Vendor deleted successfully');
        ref.invalidate(vendorsListProvider);
        ref.invalidate(vendorCitiesProvider);
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to delete vendor: ${e.toString()}',
        );
      }
    }
  }
}
