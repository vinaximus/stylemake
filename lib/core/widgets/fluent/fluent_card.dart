import 'package:flutter/material.dart';
import 'package:stylemake/core/theme/fluent_colors.dart';
import 'package:stylemake/core/theme/fluent_text_styles.dart';

/// Fluent Design System card component
class FluentCard extends StatelessWidget {
  const FluentCard({
    required this.child,
    super.key,
    this.onTap,
    this.elevation = 0,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: FluentColors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
        border: Border.all(color: FluentColors.border, width: 1),
        boxShadow: _getShadow(),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
          child: padding != null
              ? Padding(padding: padding!, child: child)
              : child,
        ),
      ),
    );
  }

  List<BoxShadow>? _getShadow() {
    if (elevation <= 0) return null;

    return [
      BoxShadow(
        color: FluentColors.shadow,
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
    ];
  }
}

/// Fluent Design System list card item
class FluentListCard extends StatelessWidget {
  const FluentListCard({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return FluentCard(
      onTap: onTap,
      padding: padding ?? const EdgeInsets.all(16),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FluentTextStyles.bodyStrong.copyWith(
                    color: FluentColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: FluentTextStyles.caption.copyWith(
                      color: FluentColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Row(mainAxisSize: MainAxisSize.min, children: trailing!),
          ],
        ],
      ),
    );
  }
}

/// Fluent Design System data card for displaying key-value pairs
class FluentDataCard extends StatelessWidget {
  const FluentDataCard({
    required this.data,
    super.key,
    this.title,
    this.onTap,
    this.padding,
  });

  final Map<String, String> data;
  final String? title;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return FluentCard(
      onTap: onTap,
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: FluentTextStyles.title.copyWith(
                color: FluentColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...data.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      entry.key,
                      style: FluentTextStyles.caption.copyWith(
                        color: FluentColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: FluentTextStyles.body.copyWith(
                        color: FluentColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
