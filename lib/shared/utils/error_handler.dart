import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stylemake/app/services/crashlytics_service.dart';

/// Utility class for handling and formatting Supabase errors
class ErrorHandler {
  ErrorHandler._();

  /// Extract user-friendly error message from exception
  static String getUserMessage(Object error, [StackTrace? stackTrace]) {
    debugPrint('Error occurred: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }

    // Handle PostgrestException (Supabase API errors)
    if (error is PostgrestException) {
      return _handlePostgrestException(error);
    }

    // Handle general exceptions
    if (error is Exception) {
      final message = error.toString();

      // Extract message after "Exception: " prefix
      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }

      return message;
    }

    // Default error message
    return 'An unexpected error occurred. Please try again.';
  }

  /// Handle Supabase PostgrestException
  static String _handlePostgrestException(PostgrestException error) {
    final code = error.code;
    final message = error.message;
    final details = error.details;

    debugPrint(
      'Postgrest Error - Code: $code, Message: $message, Details: $details',
    );

    // Handle specific error codes
    switch (code) {
      case '23505': // unique_violation
        return 'This record already exists. Please use a different value.';

      case '23503': // foreign_key_violation
        return 'Cannot perform this operation. Related records may be missing or in use.';

      case '23502': // not_null_violation
        return 'Required field is missing. Please fill in all required fields.';

      case '42P01': // undefined_table
        return 'Database configuration error. Please contact support.';

      case '42501': // insufficient_privilege
        return 'You do not have permission to perform this action.';

      case 'PGRST116': // Row not found
        return 'Record not found. It may have been deleted.';

      case '22P02': // invalid_text_representation
        return 'Invalid data format. Please check your input.';

      default:
        // Return the message from Supabase if it's user-friendly
        if (message.isNotEmpty &&
            !message.contains('SQL') &&
            !message.contains('relation')) {
          return message;
        }

        return 'Database operation failed. Please try again.';
    }
  }

  /// Check if error is a network error
  static bool isNetworkError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('failed host lookup');
  }

  /// Get network error message
  static String getNetworkErrorMessage() {
    return 'Network connection failed. Please check your internet connection and try again.';
  }

  /// Handle error and return user-friendly message
  static String handle(Object error, [StackTrace? stackTrace]) {
    if (isNetworkError(error)) {
      return getNetworkErrorMessage();
    }

    return getUserMessage(error, stackTrace);
  }

  /// Log error for debugging and send to Crashlytics
  static void logError(String context, Object error, [StackTrace? stackTrace]) {
    debugPrint('=== ERROR IN $context ===');
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
    debugPrint('========================');

    // Send to Crashlytics for monitoring
    CrashlyticsService.instance.logError(
      context,
      error,
      stackTrace,
      additionalInfo: {
        'error_type': error.runtimeType.toString(),
        'is_network_error': isNetworkError(error),
      },
    );
  }

  /// Handle error with context and return user message
  static String handleWithContext(
    String context,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    logError(context, error, stackTrace);
    return handle(error, stackTrace);
  }
}

/// Extension on repositories to simplify error handling
extension RepositoryErrorHandler on Object {
  /// Handle repository error and throw with user-friendly message
  Never throwRepositoryError(String operation) {
    final message = ErrorHandler.handle(this);
    throw Exception('$operation: $message');
  }
}
