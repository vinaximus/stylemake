import 'package:flutter/material.dart';
import 'package:stylemake/core/constants/layout_constants.dart';

/// Reusable list card item with Material 3 design
class ListCardItem extends StatelessWidget {
  const ListCardItem({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: LayoutConstants.spaceSmall),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(LayoutConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(LayoutConstants.paddingMedium),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: LayoutConstants.spaceMedium),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: LayoutConstants.spaceXSmall),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: LayoutConstants.spaceSmall),
                Row(mainAxisSize: MainAxisSize.min, children: trailing!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
