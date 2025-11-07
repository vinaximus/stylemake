import 'package:flutter/material.dart';

/// Reusable Floating Action Button with Material 3 design
class AppFab extends StatelessWidget {
  const AppFab({
    required this.onPressed,
    required this.label,
    super.key,
    this.icon,
    this.extended = true,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    if (extended && icon != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    } else if (icon != null) {
      return FloatingActionButton(
        onPressed: onPressed,
        tooltip: label,
        child: Icon(icon),
      );
    } else {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        label: Text(label),
      );
    }
  }
}
