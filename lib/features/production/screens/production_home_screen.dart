import 'package:flutter/material.dart';
import 'package:stylemake/core/constants/layout_constants.dart';

/// Production module home screen (placeholder for Phase 3+)
class ProductionHomeScreen extends StatelessWidget {
  const ProductionHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Production')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.factory,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: LayoutConstants.spaceLarge),
              Text(
                'Production Module',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: LayoutConstants.spaceMedium),
              Text(
                'Manage cuttings, fabrication POs, item issues, bills, and receipts',
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
                      const Icon(Icons.construction, size: 48),
                      const SizedBox(height: LayoutConstants.spaceMedium),
                      Text(
                        'Coming in Phase 4-8',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: LayoutConstants.spaceSmall),
                      Text(
                        'Cuttings, POs, Issues, Bills, and Receipts will be implemented in upcoming phases',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
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
