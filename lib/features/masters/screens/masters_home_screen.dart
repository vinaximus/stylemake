import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/router/app_router.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';

/// Masters module home screen
class MastersHomeScreen extends StatelessWidget {
  const MastersHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Masters')),
      body: ResponsiveCenter(
        maxWidth: 800.0,
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
                  context.push(AppRouter.stylesList);
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
                  context.push(AppRouter.vendorsList);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
