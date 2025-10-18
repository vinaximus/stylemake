import 'package:flutter/material.dart';
import 'package:stylemake/core/constants/layout_constants.dart';

/// Reports module home screen (placeholder for Phase 8+)
class ReportsHomeScreen extends StatelessWidget {
  const ReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: LayoutConstants.spaceLarge),
              Text(
                'Reports & Analytics',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: LayoutConstants.spaceMedium),
              Text(
                'Production summaries, vendor bills, and performance analytics',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LayoutConstants.spaceXLarge),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
                  child: Column(
                    children: [
                      const Icon(Icons.timeline, size: 48),
                      const SizedBox(height: LayoutConstants.spaceMedium),
                      Text(
                        'Coming in Phase 8',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: LayoutConstants.spaceSmall),
                      const Text(
                        'Production Summary Report',
                        textAlign: TextAlign.center,
                      ),
                      const Divider(height: 24),
                      const Text(
                        'Features:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Cutting vs Receipt analysis\n'
                        '• Vendor bill summaries\n'
                        '• Style-wise production tracking\n'
                        '• Date range filtering\n'
                        '• CSV export capability',
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
