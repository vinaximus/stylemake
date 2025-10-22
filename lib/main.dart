import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylemake/core/router/app_router.dart';
import 'package:stylemake/core/services/supabase_service.dart';
import 'package:stylemake/core/services/platform_service.dart';
import 'package:stylemake/core/theme/app_theme.dart';
import 'package:stylemake/core/theme/fluent_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // If .env doesn't exist, continue with default/empty values
    debugPrint('Warning: .env file not found. Using default configuration.');
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
