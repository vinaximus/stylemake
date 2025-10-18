import 'package:flutter/material.dart';

/// Shows a loading dialog with a progress indicator
void showLoadingDialog({required BuildContext context, String? message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[const SizedBox(height: 16), Text(message)],
          ],
        ),
      ),
    ),
  );
}

/// Hides the loading dialog
void hideLoadingDialog(BuildContext context) {
  Navigator.of(context).pop();
}

/// Executes an async operation with loading dialog
Future<T> withLoadingDialog<T>({
  required BuildContext context,
  required Future<T> Function() operation,
  String? message,
}) async {
  showLoadingDialog(context: context, message: message);
  try {
    final result = await operation();
    if (context.mounted) {
      hideLoadingDialog(context);
    }
    return result;
  } catch (e) {
    if (context.mounted) {
      hideLoadingDialog(context);
    }
    rethrow;
  }
}
