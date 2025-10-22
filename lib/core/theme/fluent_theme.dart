import 'package:flutter/material.dart';
import 'package:stylemake/core/theme/fluent_colors.dart';
import 'package:stylemake/core/theme/fluent_text_styles.dart';

/// Fluent Design System theme configuration
class FluentTheme {
  FluentTheme._();

  /// Light theme using Fluent Design System
  static ThemeData lightTheme = ThemeData(
    useMaterial3: false, // Disable Material 3 for Fluent
    colorScheme: const ColorScheme.light(
      primary: FluentColors.accent,
      onPrimary: FluentColors.neutralWhite,
      secondary: FluentColors.accentLight,
      onSecondary: FluentColors.neutralWhite,
      surface: FluentColors.surface,
      onSurface: FluentColors.textPrimary,
      surfaceContainerHighest: FluentColors.surfaceVariant,
      onSurfaceVariant: FluentColors.textSecondary,
      error: FluentColors.error,
      onError: FluentColors.neutralWhite,
      outline: FluentColors.border,
      shadow: FluentColors.shadow,
    ),

    // Typography
    textTheme: const TextTheme(
      displayLarge: FluentTextStyles.display,
      displayMedium: FluentTextStyles.largeTitle,
      displaySmall: FluentTextStyles.title,
      headlineLarge: FluentTextStyles.title,
      headlineMedium: FluentTextStyles.titleSecondary,
      headlineSmall: FluentTextStyles.subtitle,
      titleLarge: FluentTextStyles.title,
      titleMedium: FluentTextStyles.titleSecondary,
      titleSmall: FluentTextStyles.subtitle,
      bodyLarge: FluentTextStyles.body,
      bodyMedium: FluentTextStyles.body,
      bodySmall: FluentTextStyles.caption,
      labelLarge: FluentTextStyles.button,
      labelMedium: FluentTextStyles.caption,
      labelSmall: FluentTextStyles.caption,
    ),

    // AppBar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: FluentColors.surface,
      foregroundColor: FluentColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: FluentTextStyles.title,
      surfaceTintColor: Colors.transparent,
    ),

    // Card theme
    cardTheme: CardThemeData(
      color: FluentColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: FluentColors.border, width: 1),
      ),
      shadowColor: FluentColors.shadow,
    ),

    // FAB theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: FluentColors.accent,
      foregroundColor: FluentColors.neutralWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: FluentColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: FluentColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: FluentColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: FluentColors.focus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: FluentColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: FluentColors.error, width: 2),
      ),
      labelStyle: FluentTextStyles.caption.copyWith(
        color: FluentColors.textSecondary,
      ),
      hintStyle: FluentTextStyles.body.copyWith(
        color: FluentColors.textTertiary,
      ),
    ),

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: FluentColors.accent,
        foregroundColor: FluentColors.neutralWhite,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: FluentTextStyles.button,
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: FluentColors.accent,
        foregroundColor: FluentColors.neutralWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: FluentTextStyles.button,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: FluentColors.accent,
        side: const BorderSide(color: FluentColors.border, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: FluentTextStyles.button,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: FluentColors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: FluentTextStyles.button,
      ),
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: FluentColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: FluentColors.border, width: 1),
      ),
      titleTextStyle: FluentTextStyles.title,
      contentTextStyle: FluentTextStyles.body,
    ),

    // Navigation bar theme
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: FluentColors.surface,
      indicatorColor: FluentColors.accent.withOpacity(0.1),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return FluentTextStyles.navigationSelected;
        }
        return FluentTextStyles.navigation;
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: FluentColors.accent, size: 24);
        }
        return const IconThemeData(color: FluentColors.textSecondary, size: 24);
      }),
    ),

    // Divider theme
    dividerTheme: const DividerThemeData(
      color: FluentColors.border,
      thickness: 1,
      space: 1,
    ),

    // List tile theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      titleTextStyle: FluentTextStyles.body,
      subtitleTextStyle: FluentTextStyles.caption,
      iconColor: FluentColors.textSecondary,
    ),
  );
}
