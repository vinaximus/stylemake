import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/app/theme/fluent_colors.dart';
import 'package:stylemake/app/theme/fluent_text_styles.dart';

/// Provider for expanded menu items
final expandedMenuItemsProvider = StateProvider<Set<String>>((ref) => {});

/// Fluent Design System navigation pane for desktop
class FluentNavigationPane extends ConsumerWidget {
  const FluentNavigationPane({
    required this.selectedIndex,
    required this.onSelectionChanged,
    super.key,
    this.items,
    this.footerItems,
    this.header,
    this.footer,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectionChanged;
  final List<FluentNavigationItem>? items;
  final List<FluentNavigationItem>? footerItems;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expandedItems = ref.watch(expandedMenuItemsProvider);

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: FluentColors.surface,
        border: Border(right: BorderSide(color: FluentColors.border, width: 1)),
      ),
      child: Column(
        children: [
          // Header
          if (header != null) ...[header!, const Divider(height: 1)],
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (items != null)
                  ...items!.asMap().entries.expand((entry) {
                    final item = entry.value;
                    final index = entry.key;
                    final isExpanded = expandedItems.contains(
                      item.key ?? item.label,
                    );

                    return [
                      _NavigationItemWidget(
                        item: item,
                        isSelected: selectedIndex == index,
                        isExpanded: isExpanded,
                        onTap: () {
                          if (item.children != null &&
                              item.children!.isNotEmpty) {
                            // Toggle expansion
                            final key = item.key ?? item.label;
                            final newExpanded = {...expandedItems};
                            if (isExpanded) {
                              newExpanded.remove(key);
                            } else {
                              newExpanded.add(key);
                            }
                            ref.read(expandedMenuItemsProvider.notifier).state =
                                newExpanded;
                          } else {
                            onSelectionChanged(index);
                          }
                        },
                        onChildTap: (childPath) {
                          item.onChildTap?.call(childPath);
                        },
                      ),
                      // Render children if expanded
                      if (item.children != null && isExpanded)
                        ...item.children!.map(
                          (child) => _NavigationChildItemWidget(
                            item: child,
                            onTap: () {
                              final path = child.path ?? child.label;
                              item.onChildTap?.call(path);
                            },
                          ),
                        ),
                    ];
                  }),
              ],
            ),
          ),
          // Footer items
          if (footerItems != null) ...[
            const Divider(height: 1),
            ...footerItems!.map(
              (item) => _NavigationItemWidget(
                item: item,
                isSelected: false,
                isExpanded: false,
                onTap: item.onTap ?? () {},
              ),
            ),
          ],
          // Footer
          if (footer != null) ...[const Divider(height: 1), footer!],
        ],
      ),
    );
  }
}

/// Fluent Design System navigation item
class FluentNavigationItem {
  const FluentNavigationItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.badge,
    this.tooltip,
    this.children,
    this.onChildTap,
    this.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? badge;
  final String? tooltip;
  final List<FluentNavigationChildItem>? children;
  final Function(String path)? onChildTap;
  final String? key;
}

/// Fluent Design System navigation child item
class FluentNavigationChildItem {
  const FluentNavigationChildItem({
    required this.icon,
    required this.label,
    this.path,
  });

  final IconData icon;
  final String label;
  final String? path;
}

/// Navigation item widget
class _NavigationItemWidget extends StatelessWidget {
  const _NavigationItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.isExpanded,
    this.onChildTap,
  });

  final FluentNavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isExpanded;
  final Function(String)? onChildTap;

  @override
  Widget build(BuildContext context) {
    final hasChildren = item.children != null && item.children!.isNotEmpty;

    return Tooltip(
      message: item.tooltip ?? item.label,
      child: Material(
        color: isSelected
            ? FluentColors.accent.withOpacity(0.1)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: isSelected
                      ? FluentColors.accent
                      : FluentColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: FluentTextStyles.navigation.copyWith(
                      color: isSelected
                          ? FluentColors.accent
                          : FluentColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.badge != null) ...[
                  const SizedBox(width: 8),
                  item.badge!,
                ],
                if (hasChildren) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 16,
                    color: FluentColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigation child item widget
class _NavigationChildItemWidget extends StatelessWidget {
  const _NavigationChildItemWidget({required this.item, required this.onTap});

  final FluentNavigationChildItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.only(left: 48, right: 16),
          child: Row(
            children: [
              Icon(item.icon, size: 16, color: FluentColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: FluentTextStyles.navigation.copyWith(
                    fontSize: 13,
                    color: FluentColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fluent Design System navigation pane with default items
class FluentDefaultNavigationPane extends ConsumerWidget {
  const FluentDefaultNavigationPane({
    required this.selectedIndex,
    required this.onSelectionChanged,
    required this.onChildNavigation,
    super.key,
    this.onSettingsTap,
    this.onHelpTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectionChanged;
  final Function(String path) onChildNavigation;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onHelpTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FluentNavigationPane(
      selectedIndex: selectedIndex,
      onSelectionChanged: onSelectionChanged,
      header: _AppHeader(),
      items: [
        FluentNavigationItem(
          key: 'production',
          icon: Icons.factory,
          label: 'Production',
          children: const [
            FluentNavigationChildItem(
              icon: Icons.content_cut,
              label: 'Cuttings',
              path: '/production/cuttings',
            ),
            FluentNavigationChildItem(
              icon: Icons.assignment,
              label: 'POs',
              path: '/production/pos',
            ),
            FluentNavigationChildItem(
              icon: Icons.output,
              label: 'Issues',
              path: '/production/issues',
            ),
            FluentNavigationChildItem(
              icon: Icons.receipt_long,
              label: 'Bills',
              path: '/production/bills',
            ),
            FluentNavigationChildItem(
              icon: Icons.inbox,
              label: 'Receipts',
              path: '/production/receipts',
            ),
          ],
          onChildTap: onChildNavigation,
        ),
        const FluentNavigationItem(
          key: 'fabric',
          icon: Icons.texture,
          label: 'Fabric',
        ),
        FluentNavigationItem(
          key: 'dispatch',
          icon: Icons.local_shipping,
          label: 'Dispatch',
          onTap: () => onChildNavigation('/dispatch/list'),
        ),
        FluentNavigationItem(
          key: 'masters',
          icon: Icons.inventory_2,
          label: 'Masters',
          children: const [
            FluentNavigationChildItem(
              icon: Icons.style,
              label: 'Styles',
              path: '/masters/styles',
            ),
            FluentNavigationChildItem(
              icon: Icons.business,
              label: 'Vendors',
              path: '/masters/vendors',
            ),
            FluentNavigationChildItem(
              icon: Icons.people,
              label: 'Customers',
              path: '/masters/customers',
            ),
          ],
          onChildTap: onChildNavigation,
        ),
        const FluentNavigationItem(
          key: 'reports',
          icon: Icons.analytics,
          label: 'Reports',
        ),
      ],
      footerItems: [
        FluentNavigationItem(
          icon: Icons.settings,
          label: 'Settings',
          onTap: onSettingsTap,
        ),
        FluentNavigationItem(icon: Icons.help, label: 'Help', onTap: onHelpTap),
      ],
    );
  }
}

/// App header widget
class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.factory, color: FluentColors.accent, size: 20),
          const SizedBox(width: 8),
          Text('Stylemake', style: FluentTextStyles.title),
        ],
      ),
    );
  }
}
