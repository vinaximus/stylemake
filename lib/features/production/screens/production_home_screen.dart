import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/router/app_router.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';

/// Production module home screen (placeholder for Phase 3+)
class ProductionHomeScreen extends StatelessWidget {
  const ProductionHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Production')),
      body: ResponsiveCenter(
        maxWidth: 800.0,
        padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Production Management',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: LayoutConstants.spaceSmall),
              Text(
                'Manage your production workflow from cutting to receipts',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: LayoutConstants.spaceLarge),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.content_cut),
                  title: const Text('Cutting Records'),
                  subtitle: const Text('Manage fabric cuttings'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push(AppRouter.cuttingsList);
                  },
                ),
              ),
              const SizedBox(height: LayoutConstants.spaceSmall),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('Purchase Orders'),
                  subtitle: const Text('Manage fabrication POs'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push(AppRouter.posList);
                  },
                ),
              ),
              const SizedBox(height: LayoutConstants.spaceSmall),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: const Text('Item Issues'),
                  subtitle: const Text('Track items issued against POs'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push(AppRouter.issuesList);
                  },
                ),
              ),
              const SizedBox(height: LayoutConstants.spaceSmall),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.request_quote),
                  title: const Text('Bills'),
                  subtitle: const Text('Manage supplier invoices and bills'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(AppRouter.billsList),
                ),
              ),
              const SizedBox(height: LayoutConstants.spaceSmall),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: const Text('Receipts'),
                  subtitle: const Text('Coming in Phase 8'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: null,
                  enabled: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
