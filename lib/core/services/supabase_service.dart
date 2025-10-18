import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stylemake/core/config/env_config.dart';

/// Supabase service singleton for managing database connections
class SupabaseService {
  SupabaseService._();

  static SupabaseService? _instance;
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseClient? _client;
  bool _initialized = false;
  String? _initializationError;

  /// Get the Supabase client instance
  SupabaseClient get client {
    if (!_initialized) {
      throw StateError(
        'SupabaseService not initialized. Call initialize() first.',
      );
    }
    if (_client == null) {
      throw StateError(
        'Supabase client is null. Error during initialization: $_initializationError',
      );
    }
    return _client!;
  }

  /// Check if Supabase is properly initialized
  bool get isInitialized => _initialized && _client != null;

  /// Get initialization error if any
  String? get initializationError => _initializationError;

  /// Initialize Supabase with credentials from environment
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('SupabaseService already initialized');
      return;
    }

    try {
      // Check if environment is configured
      if (!EnvConfig.isConfigured) {
        throw Exception(
          'Supabase credentials not configured. Please check your .env file.',
        );
      }

      final supabaseUrl = EnvConfig.supabaseUrl;
      final supabaseAnonKey = EnvConfig.supabaseAnonKey;

      debugPrint('Initializing Supabase...');
      debugPrint('URL: $supabaseUrl');

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );

      _client = Supabase.instance.client;
      _initialized = true;
      _initializationError = null;

      debugPrint('✅ Supabase initialized successfully');
    } catch (e, stackTrace) {
      _initializationError = e.toString();
      _initialized =
          true; // Mark as initialized even on error to prevent re-init
      debugPrint('❌ Supabase initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Test database connection by fetching table count
  Future<bool> testConnection() async {
    try {
      if (!isInitialized) {
        return false;
      }

      // Simple query to test connection
      await client.from('styles').select('id').limit(1);

      debugPrint('✅ Database connection test successful');
      return true;
    } catch (e) {
      debugPrint('❌ Database connection test failed: $e');
      return false;
    }
  }

  /// Get count of styles (for testing)
  Future<int> getStylesCount() async {
    try {
      final response = await client
          .from('styles')
          .select()
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      debugPrint('Error fetching styles count: $e');
      rethrow;
    }
  }
}
