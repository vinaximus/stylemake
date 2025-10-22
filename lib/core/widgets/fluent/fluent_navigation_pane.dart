import 'package:flutter/material.dart';
import 'package:stylemake/core/theme/fluent_colors.dart';
import 'package:stylemake/core/theme/fluent_text_styles.dart';

/// Fluent Design System navigation pane for desktop
class FluentNavigationPane extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: FluentColors.surface,
        border: Border(
          right: BorderSide(
            color: FluentColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          if (header != null) ...[
            header!,
            const Divider(height: 1),
          ],
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (items != null)
                  ...items!.asMap().entries.map(
                        (entry) => _NavigationItemWidget(
                          item: entry.value,
                          isSelected: selectedIndex == entry.key,
                          onTap: () => onSelectionChanged(entry.key),
                        ),
                      ),
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
                onTap: item.onTap ?? () {},
              ),
            ),
          ],
          // Footer
          if (footer != null) ...[
            const Divider(height: 1),
            footer!,
          ],
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
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? badge;
  final String? tooltip;
}

/// Navigation item widget
class _NavigationItemWidget extends StatelessWidget {
  const _NavigationItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final FluentNavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.tooltip ?? item.label,
      child: Material(
        color: isSelected
            ? FluentColors.accent.withOpacity(0.1)
            : Colors.transparent,
        child: InkWell(
          onTap: item.onTap ?? () => onTap(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fluent Design System navigation pane with default items
class FluentDefaultNavigationPane extends StatelessWidget {
  const FluentDefaultNavigationPane({
    required this.selectedIndex,
    required this.onSelectionChanged,
    super.key,
    this.onSettingsTap,
    this.onHelpTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectionChanged;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onHelpTap;

  @override
  Widget build(BuildContext context) {
    return FluentNavigationPane(
      selectedIndex: selectedIndex,
      onSelectionChanged: onSelectionChanged,
      header: _AppHeader(),
      items: const [
        FluentNavigationItem(
          icon: Icons.factory,
          label: 'Production',
        ),
        FluentNavigationItem(
          icon: Icons.inventory_2,
          label: 'Masters',
        ),
        FluentNavigationItem(
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
        FluentNavigationItem(
          icon: Icons.help,
          label: 'Help',
          onTap: onHelpTap,
        ),
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
          Icon(
            Icons.factory,
            color: FluentColors.accent,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Stylemake',
            style: FluentTextStyles.title,
          ),
        ],
      ),
    );
  }
}
