import 'package:flutter/material.dart';
import 'package:stylemake/core/theme/fluent_colors.dart';
import 'package:stylemake/core/theme/fluent_text_styles.dart';

/// Fluent Design button variants
enum FluentButtonVariant {
  primary,
  secondary,
  outline,
  subtle,
  transparent,
}

/// Fluent Design button sizes
enum FluentButtonSize {
  small,
  medium,
  large,
}

/// Fluent Design System button component
class FluentButton extends StatelessWidget {
  const FluentButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.variant = FluentButtonVariant.primary,
    this.size = FluentButtonSize.medium,
    this.isLoading = false,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final FluentButtonVariant variant;
  final FluentButtonSize size;
  final bool isLoading;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    
    Widget button = Container(
      height: _getHeight(),
      decoration: BoxDecoration(
        color: _getBackgroundColor(isEnabled),
        borderRadius: BorderRadius.circular(2),
        border: _getBorder(isEnabled),
        boxShadow: _getShadow(),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(2),
          child: Padding(
            padding: _getPadding(),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTextColor(isEnabled),
                        ),
                      ),
                    )
                  : DefaultTextStyle(
                      style: _getTextStyle(isEnabled),
                      child: child,
                    ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  double _getHeight() {
    switch (size) {
      case FluentButtonSize.small:
        return 24;
      case FluentButtonSize.medium:
        return 32;
      case FluentButtonSize.large:
        return 40;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case FluentButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case FluentButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case FluentButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  Color _getBackgroundColor(bool isEnabled) {
    if (!isEnabled) {
      return FluentColors.neutralGray30;
    }

    switch (variant) {
      case FluentButtonVariant.primary:
        return FluentColors.accent;
      case FluentButtonVariant.secondary:
        return FluentColors.accent.withOpacity(0.1);
      case FluentButtonVariant.outline:
      case FluentButtonVariant.subtle:
      case FluentButtonVariant.transparent:
        return Colors.transparent;
    }
  }

  Border? _getBorder(bool isEnabled) {
    if (!isEnabled) {
      return Border.all(color: FluentColors.neutralGray30, width: 1);
    }

    switch (variant) {
      case FluentButtonVariant.primary:
      case FluentButtonVariant.secondary:
        return null;
      case FluentButtonVariant.outline:
        return Border.all(color: FluentColors.border, width: 1);
      case FluentButtonVariant.subtle:
      case FluentButtonVariant.transparent:
        return null;
    }
  }

  List<BoxShadow>? _getShadow() {
    switch (variant) {
      case FluentButtonVariant.primary:
        return [
          BoxShadow(
            color: FluentColors.shadow,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ];
      default:
        return null;
    }
  }

  Color _getTextColor(bool isEnabled) {
    if (!isEnabled) {
      return FluentColors.textDisabled;
    }

    switch (variant) {
      case FluentButtonVariant.primary:
        return FluentColors.neutralWhite;
      case FluentButtonVariant.secondary:
        return FluentColors.accent;
      case FluentButtonVariant.outline:
        return FluentColors.accent;
      case FluentButtonVariant.subtle:
        return FluentColors.accent;
      case FluentButtonVariant.transparent:
        return FluentColors.accent;
    }
  }

  TextStyle _getTextStyle(bool isEnabled) {
    final baseStyle = FluentTextStyles.button.copyWith(
      color: _getTextColor(isEnabled),
    );

    switch (size) {
      case FluentButtonSize.small:
        return baseStyle.copyWith(fontSize: 12);
      case FluentButtonSize.medium:
        return baseStyle;
      case FluentButtonSize.large:
        return baseStyle.copyWith(fontSize: 16);
    }
  }
}

/// Fluent Design System icon button
class FluentIconButton extends StatelessWidget {
  const FluentIconButton({
    required this.onPressed,
    required this.icon,
    super.key,
    this.variant = FluentButtonVariant.primary,
    this.size = FluentButtonSize.medium,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final FluentButtonVariant variant;
  final FluentButtonSize size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return FluentButton(
      onPressed: onPressed,
      variant: variant,
      size: size,
      tooltip: tooltip,
      child: Icon(
        icon,
        size: _getIconSize(),
      ),
    );
  }

  double _getIconSize() {
    switch (size) {
      case FluentButtonSize.small:
        return 16;
      case FluentButtonSize.medium:
        return 20;
      case FluentButtonSize.large:
        return 24;
    }
  }
}
