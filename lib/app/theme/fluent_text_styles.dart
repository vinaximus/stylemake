import 'package:flutter/material.dart';
import 'package:stylemake/app/theme/fluent_colors.dart';

/// Fluent Design System typography scale
class FluentTextStyles {
  FluentTextStyles._();

  // Display styles (largest)
  static const TextStyle display = TextStyle(
    fontSize: 68,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
    height: 1.2,
    color: FluentColors.textPrimary,
  );

  // Large title
  static const TextStyle largeTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.3,
    color: FluentColors.textPrimary,
  );

  // Title styles
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: FluentColors.textPrimary,
  );

  static const TextStyle titleSecondary = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: FluentColors.textPrimary,
  );

  // Subtitle
  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
    color: FluentColors.textPrimary,
  );

  // Body styles
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
    color: FluentColors.textPrimary,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: FluentColors.textPrimary,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.3,
    color: FluentColors.textSecondary,
  );

  static const TextStyle captionStrong = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: FluentColors.textSecondary,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
    color: FluentColors.neutralWhite,
  );

  // Navigation
  static const TextStyle navigation = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.3,
    color: FluentColors.textPrimary,
  );

  static const TextStyle navigationSelected = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: FluentColors.accent,
  );

  // Helper methods for creating themed text styles
  static TextStyle displayWithColor(Color color) =>
      display.copyWith(color: color);
  static TextStyle largeTitleWithColor(Color color) =>
      largeTitle.copyWith(color: color);
  static TextStyle titleWithColor(Color color) => title.copyWith(color: color);
  static TextStyle subtitleWithColor(Color color) =>
      subtitle.copyWith(color: color);
  static TextStyle bodyWithColor(Color color) => body.copyWith(color: color);
  static TextStyle captionWithColor(Color color) =>
      caption.copyWith(color: color);
}
