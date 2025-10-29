import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stylemake/core/router/app_router.dart';

/// Provider for bottom navigation index
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Provider for drawer expanded menu items
final drawerExpandedItemsProvider = StateProvider<Set<String>>((ref) => {});

/// App shell with side drawer navigation
class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text('Stylemake v0.5'),
      ),
      drawer: _NavigationDrawer(),
      body: child,
    );
  }
}

/// Navigation drawer widget
class _NavigationDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final expandedItems = ref.watch(drawerExpandedItemsProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.factory,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Stylemake',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'v0.5',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Production with expandable children
          _DrawerMenuItem(
            icon: Icons.factory,
            label: 'Production',
            isSelected: currentIndex == 0,
            isExpanded: expandedItems.contains('production'),
            hasChildren: true,
            onTap: () {
              ref.read(bottomNavIndexProvider.notifier).state = 0;
              // Toggle expansion
              final newExpanded = {...expandedItems};
              if (expandedItems.contains('production')) {
                newExpanded.remove('production');
              } else {
                newExpanded.add('production');
              }
              ref.read(drawerExpandedItemsProvider.notifier).state =
                  newExpanded;
            },
          ),
          if (expandedItems.contains('production')) ...[
            _DrawerChildMenuItem(
              icon: Icons.content_cut,
              label: 'Cuttings',
              onTap: () {
                context.go(AppRouter.cuttingsList);
                Navigator.pop(context);
              },
            ),
            _DrawerChildMenuItem(
              icon: Icons.assignment,
              label: 'POs',
              onTap: () {
                context.go(AppRouter.posList);
                Navigator.pop(context);
              },
            ),
            _DrawerChildMenuItem(
              icon: Icons.output,
              label: 'Issues',
              onTap: () {
                context.go(AppRouter.issuesList);
                Navigator.pop(context);
              },
            ),
            _DrawerChildMenuItem(
              icon: Icons.receipt_long,
              label: 'Bills',
              onTap: () {
                context.go(AppRouter.billsList);
                Navigator.pop(context);
              },
            ),
            _DrawerChildMenuItem(
              icon: Icons.inbox,
              label: 'Receipts',
              onTap: () {
                context.go(AppRouter.receiptsList);
                Navigator.pop(context);
              },
            ),
          ],
          // Fabric
          _DrawerMenuItem(
            icon: Icons.texture,
            label: 'Fabric',
            isSelected: currentIndex == 1,
            onTap: () {
              ref.read(bottomNavIndexProvider.notifier).state = 1;
              context.go(AppRouter.fabric);
              Navigator.pop(context);
            },
          ),
          // Dispatch
          _DrawerMenuItem(
            icon: Icons.local_shipping,
            label: 'Dispatch',
            isSelected: currentIndex == 2,
            onTap: () {
              ref.read(bottomNavIndexProvider.notifier).state = 2;
              context.go(AppRouter.dispatch);
              Navigator.pop(context);
            },
          ),
          // Masters with expandable children
          _DrawerMenuItem(
            icon: Icons.inventory_2,
            label: 'Masters',
            isSelected: currentIndex == 3,
            isExpanded: expandedItems.contains('masters'),
            hasChildren: true,
            onTap: () {
              ref.read(bottomNavIndexProvider.notifier).state = 3;
              // Toggle expansion
              final newExpanded = {...expandedItems};
              if (expandedItems.contains('masters')) {
                newExpanded.remove('masters');
              } else {
                newExpanded.add('masters');
              }
              ref.read(drawerExpandedItemsProvider.notifier).state =
                  newExpanded;
            },
          ),
          if (expandedItems.contains('masters')) ...[
            _DrawerChildMenuItem(
              icon: Icons.style,
              label: 'Styles',
              onTap: () {
                context.go(AppRouter.stylesList);
                Navigator.pop(context);
              },
            ),
            _DrawerChildMenuItem(
              icon: Icons.business,
              label: 'Vendors',
              onTap: () {
                context.go(AppRouter.vendorsList);
                Navigator.pop(context);
              },
            ),
            _DrawerChildMenuItem(
              icon: Icons.people,
              label: 'Customers',
              onTap: () {
                context.go(AppRouter.customersList);
                Navigator.pop(context);
              },
            ),
          ],
          // Reports
          _DrawerMenuItem(
            icon: Icons.analytics,
            label: 'Reports',
            isSelected: currentIndex == 4,
            onTap: () {
              ref.read(bottomNavIndexProvider.notifier).state = 4;
              context.go(AppRouter.reports);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          // Settings
          _DrawerMenuItem(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () {
              Navigator.pop(context);
              context.go(AppRouter.settings);
            },
          ),
          // Help
          _DrawerMenuItem(
            icon: Icons.help,
            label: 'Help',
            onTap: () {
              Navigator.pop(context);
              context.go(AppRouter.help);
            },
          ),
        ],
      ),
    );
  }
}

/// Drawer menu item widget
class _DrawerMenuItem extends StatelessWidget {
  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.isExpanded = false,
    this.hasChildren = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isExpanded;
  final bool hasChildren;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: hasChildren
          ? Icon(isExpanded ? Icons.expand_more : Icons.chevron_right, size: 20)
          : null,
      selected: isSelected,
      onTap: onTap,
    );
  }
}

/// Drawer child menu item widget
class _DrawerChildMenuItem extends StatelessWidget {
  const _DrawerChildMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
      ),
      dense: true,
      onTap: onTap,
    );
  }
}
