import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Command-line script to verify Supabase backup status
/// Run with: dart scripts/verify_backup.dart

void main() async {
  print('=== Stylemake Backup Verification Script ===\n');

  try {
    // Load environment variables
    await dotenv.load(fileName: '.env');

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      print(
        '❌ Error: SUPABASE_URL or SUPABASE_ANON_KEY not found in .env file',
      );
      exit(1);
    }

    print('📡 Connecting to Supabase...');
    print('URL: $supabaseUrl\n');

    // Initialize Supabase
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

    final client = Supabase.instance.client;
    const companyId = '00000000-0000-0000-0000-000000000000';

    print('✅ Connected successfully\n');

    // Test connection
    print('🔍 Verifying database connection...');
    await client.from('styles').select('id').limit(1);
    print('✅ Database connection verified\n');

    // Get record counts
    print('📊 Fetching record counts...\n');

    final tables = [
      'styles',
      'vendors',
      'cuttings',
      'fabrication_pos',
      'item_issues',
      'bills',
      'receipts',
    ];

    var totalRecords = 0;
    final counts = <String, int>{};

    for (final table in tables) {
      try {
        final response = await client
            .from(table)
            .select('id')
            .eq('company_id', companyId)
            .count();

        final count = response.count;
        counts[table] = count;
        totalRecords += count;

        final emoji = count > 0 ? '✅' : '⚠️';
        print('$emoji $table: $count records');
      } catch (e) {
        print('❌ $table: ERROR - $e');
        counts[table] = -1;
      }
    }

    print('\n' + '=' * 45);
    print('Total Records: $totalRecords');
    print('=' * 45);

    // Data integrity checks
    print('\n🔍 Running data integrity checks...\n');

    // Check for orphaned records
    final orphanedChecks = [
      {'table': 'cuttings', 'fk': 'style_id', 'ref_table': 'styles'},
      {'table': 'fabrication_pos', 'fk': 'cutting_id', 'ref_table': 'cuttings'},
      {'table': 'fabrication_pos', 'fk': 'vendor_id', 'ref_table': 'vendors'},
    ];

    for (final check in orphanedChecks) {
      final table = check['table']!;
      final fk = check['fk']!;
      final refTable = check['ref_table']!;

      try {
        final records = await client
            .from(table)
            .select(fk)
            .eq('company_id', companyId);

        final refIds = await client
            .from(refTable)
            .select('id')
            .eq('company_id', companyId);

        final refIdSet = (refIds as List).map((r) => r['id'] as String).toSet();

        var orphanedCount = 0;
        for (final record in records as List) {
          final fkValue = record[fk] as String?;
          if (fkValue != null && !refIdSet.contains(fkValue)) {
            orphanedCount++;
          }
        }

        if (orphanedCount > 0) {
          print(
            '⚠️  $table: $orphanedCount orphaned records (missing $fk in $refTable)',
          );
        } else {
          print('✅ $table: No orphaned records');
        }
      } catch (e) {
        print('⚠️  Error checking $table: $e');
      }
    }

    // Generate backup report
    print('\n' + '=' * 45);
    print('Backup Verification Report');
    print('=' * 45);
    print('Generated: ${DateTime.now().toIso8601String()}');
    print('Company ID: $companyId');
    print('Connection: OK');
    print('Total Tables: ${tables.length}');
    print('Total Records: $totalRecords');
    print('Status: ${totalRecords > 0 ? 'READY FOR BACKUP' : 'NO DATA'}');
    print('=' * 45);

    print('\n✅ Backup verification complete!');
    print('\nNOTE: This script verifies data accessibility.');
    print('Configure automatic backups in the Supabase dashboard:');
    print('Dashboard > Settings > Database > Backups\n');

    exit(0);
  } catch (e, stackTrace) {
    print('\n❌ Error during backup verification:');
    print(e);
    print('\nStack trace:');
    print(stackTrace);
    exit(1);
  }
}
