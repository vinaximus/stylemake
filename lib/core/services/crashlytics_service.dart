import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Service for Firebase Crashlytics error logging and monitoring
class CrashlyticsService {
  CrashlyticsService._();

  static CrashlyticsService? _instance;
  static CrashlyticsService get instance {
    _instance ??= CrashlyticsService._();
    return _instance!;
  }

  bool _initialized = false;

  /// Initialize Firebase and Crashlytics
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('CrashlyticsService already initialized');
      return;
    }

    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Enable Crashlytics collection
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      );

      // Pass all uncaught errors to Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      _initialized = true;
      debugPrint('✅ Firebase Crashlytics initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to initialize Crashlytics: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't rethrow - app should continue even if Crashlytics fails
    }
  }

  /// Check if Crashlytics is initialized
  bool get isInitialized => _initialized;

  /// Log a non-fatal error with context
  Future<void> logError(
    String context,
    Object error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? additionalInfo,
  }) async {
    if (!_initialized) {
      debugPrint('Crashlytics not initialized, skipping error log');
      return;
    }

    try {
      // Set custom keys for context
      await FirebaseCrashlytics.instance.setCustomKey('error_context', context);

      if (additionalInfo != null) {
        for (final entry in additionalInfo.entries) {
          await FirebaseCrashlytics.instance.setCustomKey(
            entry.key,
            entry.value.toString(),
          );
        }
      }

      // Record the error
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: context,
        fatal: false,
      );

      debugPrint('📊 Error logged to Crashlytics: $context');
    } catch (e) {
      debugPrint('Failed to log error to Crashlytics: $e');
    }
  }

  /// Log a custom event/message
  Future<void> log(String message) async {
    if (!_initialized) return;

    try {
      await FirebaseCrashlytics.instance.log(message);
      debugPrint('📊 Custom log: $message');
    } catch (e) {
      debugPrint('Failed to log message to Crashlytics: $e');
    }
  }

  /// Set user identifier (for future multi-user support)
  Future<void> setUserId(String userId) async {
    if (!_initialized) return;

    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
      debugPrint('👤 User ID set: $userId');
    } catch (e) {
      debugPrint('Failed to set user ID: $e');
    }
  }

  /// Set custom key-value pair
  Future<void> setCustomKey(String key, dynamic value) async {
    if (!_initialized) return;

    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, value);
    } catch (e) {
      debugPrint('Failed to set custom key: $e');
    }
  }

  /// Force a crash (for testing purposes only)
  void forceCrash() {
    if (kDebugMode) {
      debugPrint('⚠️ Force crash called in debug mode - ignoring');
      return;
    }
    FirebaseCrashlytics.instance.crash();
  }

  /// Test crash reporting
  Future<void> testCrashReporting() async {
    if (!_initialized) return;

    try {
      await FirebaseCrashlytics.instance.recordError(
        Exception('Test error for Crashlytics'),
        StackTrace.current,
        reason: 'Testing Crashlytics integration',
        fatal: false,
      );
      debugPrint('✅ Test error sent to Crashlytics');
    } catch (e) {
      debugPrint('Failed to send test error: $e');
    }
  }
}
