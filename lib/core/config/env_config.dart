import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration helper
class EnvConfig {
  /// Supabase URL from environment
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase anonymous key from environment
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Check if environment is properly configured
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}

