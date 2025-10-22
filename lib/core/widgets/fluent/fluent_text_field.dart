import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stylemake/core/theme/fluent_colors.dart';
import 'package:stylemake/core/theme/fluent_text_styles.dart';

/// Fluent Design System text field component
class FluentTextField extends StatelessWidget {
  const FluentTextField({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FluentTextStyles.caption.copyWith(
            color: FluentColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          maxLength: maxLength,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          autofocus: autofocus,
          style: FluentTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            counterText: maxLength != null ? '' : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.border,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.focus,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.neutralGray30,
                width: 1,
              ),
            ),
            filled: true,
            fillColor: enabled
                ? FluentColors.surface
                : FluentColors.neutralGray20,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            hintStyle: FluentTextStyles.body.copyWith(
              color: FluentColors.textTertiary,
            ),
            errorStyle: FluentTextStyles.caption.copyWith(
              color: FluentColors.error,
            ),
          ),
        ),
      ],
    );
  }
}

/// Fluent Design System dropdown field
class FluentDropdownField<T> extends StatelessWidget {
  const FluentDropdownField({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    super.key,
    this.hint,
    this.validator,
    this.enabled = true,
    this.itemBuilder,
  });

  final String label;
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final String? Function(T?)? validator;
  final bool enabled;
  final Widget Function(T)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FluentTextStyles.caption.copyWith(
            color: FluentColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<T>(
          value: value,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.border,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.focus,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.neutralGray30,
                width: 1,
              ),
            ),
            filled: true,
            fillColor: enabled
                ? FluentColors.surface
                : FluentColors.neutralGray20,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            hintStyle: FluentTextStyles.body.copyWith(
              color: FluentColors.textTertiary,
            ),
            errorStyle: FluentTextStyles.caption.copyWith(
              color: FluentColors.error,
            ),
          ),
          style: FluentTextStyles.body,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: itemBuilder != null
                  ? itemBuilder!(item)
                  : Text(item.toString()),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Fluent Design System date picker field
class FluentDateField extends StatelessWidget {
  const FluentDateField({
    required this.controller,
    required this.label,
    super.key,
    this.validator,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(DateTime?)? validator;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FluentTextStyles.caption.copyWith(
            color: FluentColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          readOnly: true,
          enabled: enabled,
          validator: validator != null
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return validator!(null);
                  }
                  // Parse date and validate
                  try {
                    final date = DateTime.parse(value);
                    return validator!(date);
                  } catch (e) {
                    return 'Invalid date format';
                  }
                }
              : null,
          decoration: InputDecoration(
            hintText: 'Select date',
            suffixIcon: Icon(
              Icons.calendar_today,
              color: FluentColors.textSecondary,
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.border,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.focus,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: FluentColors.neutralGray30,
                width: 1,
              ),
            ),
            filled: true,
            fillColor: enabled
                ? FluentColors.surface
                : FluentColors.neutralGray20,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            hintStyle: FluentTextStyles.body.copyWith(
              color: FluentColors.textTertiary,
            ),
            errorStyle: FluentTextStyles.caption.copyWith(
              color: FluentColors.error,
            ),
          ),
          onTap: enabled
              ? () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: firstDate ?? DateTime(1900),
                    lastDate: lastDate ?? DateTime(2100),
                  );
                  if (date != null) {
                    controller.text = date.toIso8601String().split('T')[0];
                    onChanged?.call(date);
                  }
                }
              : null,
        ),
      ],
    );
  }
}
