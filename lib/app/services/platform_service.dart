import 'dart:io';
import 'package:flutter/foundation.dart';

/// Service for platform detection and design system selection
class PlatformService {
  PlatformService._();

  /// Check if running on desktop platforms
  static bool get isDesktop => 
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  /// Check if running on mobile platforms
  static bool get isMobile => 
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Check if running on web
  static bool get isWeb => kIsWeb;

  /// Check if running on Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Check if running on macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Check if running on Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Determine if Fluent Design should be used
  static bool get shouldUseFluent => isDesktop && !isWeb;

  /// Determine if Material Design should be used
  static bool get shouldUseMaterial => isMobile || isWeb;

  /// Get platform name for debugging
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'Unknown';
  }

  /// Get design system name based on platform
  static String get designSystemName {
    if (shouldUseFluent) return 'Fluent Design';
    if (shouldUseMaterial) return 'Material 3';
    return 'Unknown';
  }
}
