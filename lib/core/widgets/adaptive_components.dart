import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stylemake/core/services/platform_service.dart';
import 'package:stylemake/core/widgets/fluent/fluent_button.dart';
import 'package:stylemake/core/widgets/fluent/fluent_card.dart';
import 'package:stylemake/core/widgets/fluent/fluent_text_field.dart';
import 'package:stylemake/core/widgets/fluent/fluent_app_bar.dart';
import 'package:stylemake/core/widgets/app_fab.dart';
import 'package:stylemake/core/widgets/list_card_item.dart';
import 'package:stylemake/core/widgets/form/text_input_field.dart';

/// Adaptive button that uses Fluent Design on desktop and Material 3 on mobile
class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.variant = FluentButtonVariant.primary,
    this.size = FluentButtonSize.medium,
    this.isLoading = false,
    this.tooltip,
    this.style,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final FluentButtonVariant variant;
  final FluentButtonSize size;
  final bool isLoading;
  final String? tooltip;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    if (PlatformService.shouldUseFluent) {
      return FluentButton(
        onPressed: onPressed,
        variant: variant,
        size: size,
        isLoading: isLoading,
        tooltip: tooltip,
        child: child,
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : child,
      );
    }
  }
}

/// Adaptive icon button
class AdaptiveIconButton extends StatelessWidget {
  const AdaptiveIconButton({
    required this.onPressed,
    required this.icon,
    super.key,
    this.variant = FluentButtonVariant.primary,
    this.size = FluentButtonSize.medium,
    this.tooltip,
    this.style,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final FluentButtonVariant variant;
  final FluentButtonSize size;
  final String? tooltip;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    if (PlatformService.shouldUseFluent) {
      return FluentIconButton(
        onPressed: onPressed,
        icon: icon,
        variant: variant,
        size: size,
        tooltip: tooltip,
      );
    } else {
      return IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        tooltip: tooltip,
        style: style,
      );
    }
  }
}

/// Adaptive card that uses Fluent Design on desktop and Material 3 on mobile
class AdaptiveCard extends StatelessWidget {
  const AdaptiveCard({
    required this.child,
    super.key,
    this.onTap,
    this.elevation,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    if (PlatformService.shouldUseFluent) {
      return FluentCard(
        onTap: onTap,
        elevation: elevation ?? 0,
        padding: padding,
        margin: margin,
        borderRadius: borderRadius,
        child: child,
      );
    } else {
      return Card(
        elevation: elevation,
        margin: margin,
        shape: borderRadius != null
            ? RoundedRectangleBorder(borderRadius: borderRadius!)
            : null,
        child: padding != null
            ? Padding(
                padding: padding!,
                child: child,
              )
            : child,
      );
    }
  }
}

/// Adaptive list card item
class AdaptiveListCard extends StatelessWidget {
  const AdaptiveListCard({
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
    if (PlatformService.shouldUseFluent) {
      return FluentListCard(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        onLongPress: onLongPress,
        padding: padding,
      );
    } else {
      return ListCardItem(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        onLongPress: onLongPress,
      );
    }
  }
}

/// Adaptive text field
class AdaptiveTextField extends StatelessWidget {
  const AdaptiveTextField({
    required this.controller,
    required this.label,
    super.key,
    this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    if (PlatformService.shouldUseFluent) {
      return FluentTextField(
        controller: controller,
        label: label,
        hint: hint,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        enabled: enabled,
        readOnly: readOnly,
        obscureText: obscureText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        autofocus: autofocus,
      );
    } else {
      return TextInputField(
        controller: controller,
        label: label,
        hint: hint,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        enabled: enabled,
        readOnly: readOnly,
        obscureText: obscureText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
      );
    }
  }
}

/// Adaptive app bar
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdaptiveAppBar({
    required this.title,
    super.key,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.elevation,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    if (PlatformService.shouldUseFluent) {
      return FluentAppBar(
        title: title,
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        centerTitle: centerTitle,
        elevation: elevation ?? 0,
      );
    } else {
      return AppBar(
        title: Text(title),
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        centerTitle: centerTitle,
        elevation: elevation,
      );
    }
  }

  @override
  Size get preferredSize {
    if (PlatformService.shouldUseFluent) {
      return const Size.fromHeight(48);
    } else {
      return const Size.fromHeight(kToolbarHeight);
    }
  }
}

/// Adaptive FAB that uses Fluent Design on desktop and Material 3 on mobile
class AdaptiveFab extends StatelessWidget {
  const AdaptiveFab({
    required this.onPressed,
    required this.label,
    super.key,
    this.icon,
    this.extended = true,
    this.tooltip,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final bool extended;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    if (PlatformService.shouldUseFluent) {
      return FluentButton(
        onPressed: onPressed,
        variant: FluentButtonVariant.primary,
        size: FluentButtonSize.large,
        tooltip: tooltip ?? label,
        child: extended && icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : icon != null
                ? Icon(icon)
                : Text(label),
      );
    } else {
      return AppFab(
        onPressed: onPressed,
        label: label,
        icon: icon,
        extended: extended,
      );
    }
  }
}
