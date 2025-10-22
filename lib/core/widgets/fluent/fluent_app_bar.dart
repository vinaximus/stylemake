import 'package:flutter/material.dart';
import 'package:stylemake/core/theme/fluent_colors.dart';
import 'package:stylemake/core/theme/fluent_text_styles.dart';

/// Fluent Design System app bar component
class FluentAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FluentAppBar({
    required this.title,
    super.key,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.elevation = 0,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: FluentColors.surface,
        border: Border(
          bottom: BorderSide(
            color: FluentColors.border,
            width: 1,
          ),
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: FluentColors.shadow,
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          if (leading != null || automaticallyImplyLeading) ...[
            leading ??
                (automaticallyImplyLeading
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                        color: FluentColors.textPrimary,
                      )
                    : const SizedBox.shrink()),
            const SizedBox(width: 8),
          ],
          if (centerTitle)
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: FluentTextStyles.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          else
            Expanded(
              child: Text(
                title,
                style: FluentTextStyles.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (actions != null) ...[
            const SizedBox(width: 8),
            Row(mainAxisSize: MainAxisSize.min, children: actions!),
          ],
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

/// Fluent Design System command bar (toolbar)
class FluentCommandBar extends StatelessWidget {
  const FluentCommandBar({
    super.key,
    this.primaryCommands,
    this.secondaryCommands,
    this.overflowButtonBuilder,
  });

  final List<Widget>? primaryCommands;
  final List<Widget>? secondaryCommands;
  final Widget Function(BuildContext context)? overflowButtonBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: FluentColors.surface,
        border: Border(
          bottom: BorderSide(
            color: FluentColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (primaryCommands != null) ...[
            const SizedBox(width: 8),
            ...primaryCommands!,
            const SizedBox(width: 8),
          ],
          const Spacer(),
          if (secondaryCommands != null) ...[
            ...secondaryCommands!,
            const SizedBox(width: 8),
          ],
          if (overflowButtonBuilder != null) ...[
            overflowButtonBuilder!(context),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

/// Fluent Design System command bar button
class FluentCommandBarButton extends StatelessWidget {
  const FluentCommandBarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
    this.isSelected = false,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? label,
      child: Material(
        color: isSelected
            ? FluentColors.accent.withOpacity(0.1)
            : Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? FluentColors.accent
                      : FluentColors.textPrimary,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: FluentTextStyles.caption.copyWith(
                    color: isSelected
                        ? FluentColors.accent
                        : FluentColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fluent Design System command bar separator
class FluentCommandBarSeparator extends StatelessWidget {
  const FluentCommandBarSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: FluentColors.border,
    );
  }
}
