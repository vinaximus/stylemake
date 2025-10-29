import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/models/style.dart';
import 'package:stylemake/core/utils/snackbar_utils.dart';
import 'package:stylemake/core/widgets/app_fab.dart';
import 'package:stylemake/core/widgets/dialogs/confirm_dialog.dart';
import 'package:stylemake/core/widgets/list_card_item.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';
import 'package:stylemake/features/masters/providers/style_providers.dart';

/// Style Master list screen
class StylesListScreen extends ConsumerStatefulWidget {
  const StylesListScreen({super.key});

  @override
  ConsumerState<StylesListScreen> createState() => _StylesListScreenState();
}

class _StylesListScreenState extends ConsumerState<StylesListScreen>
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
      ref.invalidate(stylesListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stylesAsync = ref.watch(stylesListProvider);
    final filteredStyles = ref.watch(filteredStylesProvider);
    final searchQuery = ref.watch(styleSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Style Master'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search styles by name or designer...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(styleSearchQueryProvider.notifier).state =
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
                ref.read(styleSearchQueryProvider.notifier).state = value;
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(stylesListProvider);
        },
        child: stylesAsync.when(
          data: (styles) {
            if (styles.isEmpty) {
              return _buildEmptyState(context);
            }

            if (filteredStyles.isEmpty && searchQuery.isNotEmpty) {
              return _buildNoResultsState(context, searchQuery);
            }

            return ResponsiveListContainer(
              child: ListView.builder(
                padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
                itemCount: filteredStyles.length,
                itemBuilder: (context, index) {
                  final style = filteredStyles[index];
                  return _buildStyleCard(style);
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
          context.push('/masters/styles/add');
        },
        label: 'Add Style',
        icon: Icons.add,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.style_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: LayoutConstants.spaceLarge),
          Text('No styles yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: LayoutConstants.spaceSmall),
          Text(
            'Tap the + button to add your first style',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            'No styles match "$query"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
              'Error loading styles',
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
                ref.invalidate(stylesListProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleCard(Style style) {
    return ListCardItem(
      title: style.name,
      subtitle: _buildSubtitleText(style),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          style.name.isNotEmpty ? style.name[0].toUpperCase() : 'S',
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
            context.push('/masters/styles/${style.id}/edit');
          },
          tooltip: 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteStyle(context, ref, style.id, style.name),
          tooltip: 'Delete',
        ),
      ],
      onTap: () {
        // Could navigate to detail view in future
      },
    );
  }

  String _buildSubtitleText(Style style) {
    final parts = <String>[];

    if (style.designer != null && style.designer!.isNotEmpty) {
      parts.add('Designer: ${style.designer!}');
    }

    parts.add('Created: ${DateFormat('MMM dd, yyyy').format(style.createdAt)}');

    return parts.join(' • ');
  }

  Future<void> _deleteStyle(
    BuildContext context,
    WidgetRef ref,
    String styleId,
    String styleName,
  ) async {
    // Check if style can be deleted
    try {
      final canDelete = await ref.read(canDeleteStyleProvider(styleId).future);

      if (!canDelete) {
        if (context.mounted) {
          SnackbarUtils.showError(
            context,
            'Cannot delete style "$styleName" - it is being used in cuttings, dispatch items, or receipts',
          );
        }
        return;
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to check style references: $e',
        );
      }
      return;
    }

    final confirmed = await showDeleteConfirmDialog(
      context: context,
      itemName: styleName,
    );

    if (!confirmed || !context.mounted) return;

    try {
      final repository = ref.read(styleRepositoryProvider);
      await repository.deleteStyle(styleId);

      // Invalidate providers to refresh the list
      ref.invalidate(stylesListProvider);
      ref.invalidate(filteredStylesProvider);

      if (context.mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Style "$styleName" deleted successfully',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to delete style: ${e.toString()}',
        );
      }
    }
  }
}
