import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/app/config/env_config.dart';
import 'package:stylemake/app/router/app_router.dart';
import 'package:stylemake/app/services/platform_service.dart';
import 'package:stylemake/app/services/supabase_service.dart';
import 'package:stylemake/app/theme/app_theme.dart';
import 'package:stylemake/app/theme/fluent_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    // Load from assets - flutter_dotenv will look for .env in the assets folder
    await dotenv.load();
    
    // Add these debug prints to verify loading
    debugPrint('🔍 Checking .env file loading...');
    debugPrint('SUPABASE_URL loaded: ${dotenv.env['SUPABASE_URL']?.isNotEmpty ?? false}');
    debugPrint('SUPABASE_ANON_KEY loaded: ${dotenv.env['SUPABASE_ANON_KEY']?.isNotEmpty ?? false}');
    debugPrint('SUPABASE_URL value: ${dotenv.env['SUPABASE_URL'] ?? 'NOT FOUND'}');
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
    debugPrint('SUPABASE_ANON_KEY value: ${anonKey != null && anonKey.length > 20 ? anonKey.substring(0, 20) + '...' : anonKey ?? 'NOT FOUND'}');
    debugPrint('EnvConfig.isConfigured: ${EnvConfig.isConfigured}');
  } catch (e, stackTrace) {
    // If .env doesn't exist or has encoding issues, provide helpful error message
    if (e.toString().contains('Invalid UTF-8')) {
      debugPrint('❌ ERROR: .env file has invalid UTF-8 encoding.');
      debugPrint('💡 SOLUTION: Re-save your .env file as UTF-8 without BOM:');
      debugPrint('   1. Open .env in VS Code');
      debugPrint('   2. Click bottom-right encoding (e.g., "UTF-16" or "UTF-8 with BOM")');
      debugPrint('   3. Select "Save with Encoding" → "UTF-8"');
      debugPrint('   4. Restart the app');
    } else {
      debugPrint('⚠️ Warning: .env file not found or failed to load.');
      debugPrint('Error: $e');
      debugPrint('Make sure .env file exists in project root and is listed in pubspec.yaml assets.');
    }
  }



  // Initialize Supabase
  try {
    await SupabaseService.instance.initialize();
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
    // Continue app startup even if Supabase fails (for development)
  }

  runApp(const ProviderScope(child: StylemakeApp()));
}

class StylemakeApp extends ConsumerWidget {
  const StylemakeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use Fluent Design for desktop, Material 3 for mobile/web
    final theme = PlatformService.shouldUseFluent
        ? FluentTheme.lightTheme
        : AppTheme.lightTheme;

    return MaterialApp.router(
      title: 'Stylemake v0.5',
      theme: theme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
