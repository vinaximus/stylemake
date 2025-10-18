import 'package:flutter/material.dart';
import 'package:stylemake/core/constants/layout_constants.dart';

/// Masters module home screen (placeholder for Phase 3)
class MastersHomeScreen extends StatelessWidget {
  const MastersHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Masters')),
      body: Padding(
        padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Master Data Management',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: LayoutConstants.spaceSmall),
            Text(
              'Manage styles and vendors for your production',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: LayoutConstants.spaceLarge),
            Card(
              child: ListTile(
                leading: const Icon(Icons.style),
                title: const Text('Style Master'),
                subtitle: const Text('Manage garment styles'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Navigate to Style Master (Phase 3)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Style Master - Coming in Phase 3'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: LayoutConstants.spaceSmall),
            Card(
              child: ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Vendor Master'),
                subtitle: const Text('Manage fabrication vendors'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Navigate to Vendor Master (Phase 3)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vendor Master - Coming in Phase 3'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: LayoutConstants.spaceLarge),
            Card(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: LayoutConstants.spaceMedium),
                    Expanded(
                      child: Text(
                        'Full CRUD functionality for Styles and Vendors will be available in Phase 3',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
