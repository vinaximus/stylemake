import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stylemake/core/constants/layout_constants.dart';
import 'package:stylemake/core/router/app_router.dart';
import 'package:stylemake/core/widgets/responsive_center.dart';
import 'package:stylemake/features/production/providers/cutting_providers.dart';

/// Cutting detail screen showing cutting information and linked POs
class CuttingDetailScreen extends ConsumerWidget {
  const CuttingDetailScreen({required this.cuttingId, super.key});

  final String cuttingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuttingAsync = ref.watch(cuttingByIdProvider(cuttingId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cutting Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push(AppRouter.cuttingsEdit(cuttingId));
            },
            tooltip: 'Edit',
          ),
        ],
      ),
      body: cuttingAsync.when(
        data: (cutting) {
          if (cutting == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: LayoutConstants.spaceLarge),
                  Text('Cutting not found', style: theme.textTheme.titleLarge),
                  const SizedBox(height: LayoutConstants.spaceLarge),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: 800.0,
              padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cutting Information Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        LayoutConstants.paddingLarge,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cutting Information',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Cutting Reference',
                            cutting.cuttingRef,
                            Icons.tag,
                          ),
                          const SizedBox(height: LayoutConstants.spaceMedium),
                          _buildInfoRow(
                            'Cutting Date',
                            DateFormat(
                              'dd MMMM yyyy',
                            ).format(cutting.cuttingDate),
                            Icons.calendar_today,
                          ),
                          const SizedBox(height: LayoutConstants.spaceMedium),
                          _buildInfoRow(
                            'Style',
                            cutting.styleName,
                            Icons.style,
                          ),
                          const SizedBox(height: LayoutConstants.spaceMedium),
                          _buildInfoRow(
                            'Quantity Cut',
                            '${cutting.quantityCut} pieces',
                            Icons.inventory_2,
                          ),
                          if (cutting.notes != null &&
                              cutting.notes!.isNotEmpty) ...[
                            const SizedBox(height: LayoutConstants.spaceMedium),
                            _buildInfoRow('Notes', cutting.notes!, Icons.note),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: LayoutConstants.spaceLarge),

                  // Fabrication POs Section (placeholder for Phase 5)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        LayoutConstants.paddingLarge,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Fabrication Purchase Orders',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              FilledButton.icon(
                                onPressed: null, // Will be enabled in Phase 5
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Create PO'),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 64,
                                  color: theme.colorScheme.outline,
                                ),
                                const SizedBox(
                                  height: LayoutConstants.spaceMedium,
                                ),
                                Text(
                                  'No POs linked yet',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(
                                  height: LayoutConstants.spaceSmall,
                                ),
                                Text(
                                  'Purchase orders will be created in Phase 5',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
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
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LayoutConstants.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: LayoutConstants.spaceLarge),
                Text(
                  'Error loading cutting',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: LayoutConstants.spaceSmall),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: LayoutConstants.spaceLarge),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: LayoutConstants.spaceSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

