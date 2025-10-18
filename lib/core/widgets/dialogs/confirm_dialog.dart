import 'package:flutter/material.dart';

/// Shows a confirmation dialog and returns true if confirmed
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDangerous = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDangerous
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                )
              : null,
          child: Text(confirmText),
        ),
      ],
    ),
  );

  return result ?? false;
}

/// Shows a delete confirmation dialog
Future<bool> showDeleteConfirmDialog({
  required BuildContext context,
  required String itemName,
}) {
  return showConfirmDialog(
    context: context,
    title: 'Delete $itemName?',
    message: 'This action cannot be undone.',
    confirmText: 'Delete',
    cancelText: 'Cancel',
    isDangerous: true,
  );
}
