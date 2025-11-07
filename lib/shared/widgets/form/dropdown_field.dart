import 'package:flutter/material.dart';

/// Reusable dropdown field with Material 3 design
class DropdownField<T> extends StatelessWidget {
  const DropdownField({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    super.key,
    this.validator,
    this.hint,
    this.enabled = true,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final String? hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(labelText: label, hintText: hint),
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
    );
  }
}

/// Helper class to create dropdown items
class DropdownHelper {
  DropdownHelper._();

  /// Create dropdown items from a list of objects
  static List<DropdownMenuItem<T>> createItems<T>({
    required List<T> items,
    required String Function(T) getLabel,
    required T Function(T) getValue,
  }) {
    return items.map((item) {
      return DropdownMenuItem<T>(
        value: getValue(item),
        child: Text(getLabel(item)),
      );
    }).toList();
  }

  /// Create simple string dropdown items
  static List<DropdownMenuItem<String>> createStringItems(List<String> items) {
    return items.map((item) {
      return DropdownMenuItem<String>(value: item, child: Text(item));
    }).toList();
  }
}
