import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stylemake/shared/constants/layout_constants.dart';
import 'package:stylemake/app/router/app_router.dart';
import 'package:stylemake/shared/widgets/responsive_center.dart';

/// Reports module home screen (placeholder for Phase 8+)
class ReportsHomeScreen extends StatelessWidget {
  const ReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ResponsiveCenter(
        maxWidth: 800.0,
        padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
        child: SingleChildScrollView(
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
                child: ListTile(
                  leading: const Icon(Icons.timeline),
                  title: const Text('Production Summary'),
                  subtitle: const Text('KPIs and CSV export'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(AppRouter.productionSummary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
