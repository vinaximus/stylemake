import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stylemake/app/services/supabase_service.dart';

/// Service for backup verification and data snapshot generation
class BackupService {
  BackupService._();

  static BackupService? _instance;
  static BackupService get instance {
    _instance ??= BackupService._();
    return _instance!;
  }

  final _supabase = SupabaseService.instance.client;

  /// Default company ID for v0.5 single-company mode
  static const String defaultCompanyId = '00000000-0000-0000-0000-000000000000';

  /// Verify Supabase connection
  Future<bool> verifyConnection() async {
    try {
      await _supabase.from('styles').select('id').limit(1);
      debugPrint('✅ Supabase connection verified');
      return true;
    } catch (e) {
      debugPrint('❌ Supabase connection failed: $e');
      return false;
    }
  }

  /// Fetch record counts from all tables
  Future<Map<String, int>> getRecordCounts() async {
    final counts = <String, int>{};

    final tables = [
      'styles',
      'vendors',
      'cuttings',
      'fabrication_pos',
      'item_issues',
      'bills',
      'receipts',
    ];

    for (final table in tables) {
      try {
        final response = await _supabase
            .from(table)
            .select('id')
            .eq('company_id', defaultCompanyId)
            .count();

        counts[table] = response.count;
      } catch (e) {
        debugPrint('Error fetching count for $table: $e');
        counts[table] = -1; // Indicate error
      }
    }

    return counts;
  }

  /// Generate backup report with timestamps
  Future<Map<String, dynamic>> generateBackupReport() async {
    final now = DateTime.now();
    final connectionOk = await verifyConnection();
    final counts = await getRecordCounts();

    return {
      'generated_at': now.toIso8601String(),
      'connection_status': connectionOk ? 'connected' : 'disconnected',
      'company_id': defaultCompanyId,
      'record_counts': counts,
      'total_records': counts.values
          .where((c) => c >= 0)
          .fold(0, (a, b) => a + b),
    };
  }

  /// Export data snapshot to JSON for local backup
  Future<String> exportDataSnapshot() async {
    final snapshot = <String, dynamic>{};

    try {
      // Export styles
      final stylesResponse = await _supabase
          .from('styles')
          .select()
          .eq('company_id', defaultCompanyId);
      snapshot['styles'] = stylesResponse;

      // Export vendors
      final vendorsResponse = await _supabase
          .from('vendors')
          .select()
          .eq('company_id', defaultCompanyId);
      snapshot['vendors'] = vendorsResponse;

      // Export cuttings
      final cuttingsResponse = await _supabase
          .from('cuttings')
          .select()
          .eq('company_id', defaultCompanyId);
      snapshot['cuttings'] = cuttingsResponse;

      // Export fabrication_pos
      final posResponse = await _supabase
          .from('fabrication_pos')
          .select()
          .eq('company_id', defaultCompanyId);
      snapshot['fabrication_pos'] = posResponse;

      // Export item_issues
      final issuesResponse = await _supabase
          .from('item_issues')
          .select()
          .eq('company_id', defaultCompanyId);
      snapshot['item_issues'] = issuesResponse;

      // Export bills
      final billsResponse = await _supabase
          .from('bills')
          .select()
          .eq('company_id', defaultCompanyId);
      snapshot['bills'] = billsResponse;

      // Export receipts
      final receiptsResponse = await _supabase
          .from('receipts')
          .select()
          .eq('company_id', defaultCompanyId);
      snapshot['receipts'] = receiptsResponse;

      snapshot['metadata'] = {
        'exported_at': DateTime.now().toIso8601String(),
        'company_id': defaultCompanyId,
        'version': '0.5.0',
      };

      debugPrint('✅ Data snapshot exported successfully');
      return jsonEncode(snapshot);
    } catch (e) {
      debugPrint('❌ Failed to export data snapshot: $e');
      rethrow;
    }
  }

  /// Get backup status summary
  Future<String> getBackupStatusSummary() async {
    final report = await generateBackupReport();
    final buffer = StringBuffer();

    buffer.writeln('=== Backup Status Report ===');
    buffer.writeln('Generated: ${report['generated_at']}');
    buffer.writeln('Connection: ${report['connection_status']}');
    buffer.writeln('Company ID: ${report['company_id']}');
    buffer.writeln('\nRecord Counts:');

    final counts = report['record_counts'] as Map<String, int>;
    counts.forEach((table, count) {
      buffer.writeln('  $table: ${count >= 0 ? count : 'ERROR'}');
    });

    buffer.writeln('\nTotal Records: ${report['total_records']}');
    buffer.writeln('===========================');

    return buffer.toString();
  }
}
