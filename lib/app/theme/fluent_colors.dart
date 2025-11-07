import 'package:flutter/material.dart';

/// Fluent Design System color palette
class FluentColors {
  FluentColors._();

  // Primary accent colors
  static const Color accent = Color(0xFF0078D4);
  static const Color accentLight = Color(0xFF106EBE);
  static const Color accentDark = Color(0xFF005A9E);
  static const Color accentLighter = Color(0xFF3A96DD);
  static const Color accentDarker = Color(0xFF004578);

  // Neutral colors (Fluent Design System)
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralGray10 = Color(0xFFFAFAFA);
  static const Color neutralGray20 = Color(0xFFF5F5F5);
  static const Color neutralGray30 = Color(0xFFEDEBE9);
  static const Color neutralGray40 = Color(0xFFE1DFDD);
  static const Color neutralGray50 = Color(0xFFD2D0CE);
  static const Color neutralGray60 = Color(0xFFC7C6C4);
  static const Color neutralGray70 = Color(0xFFA19F9D);
  static const Color neutralGray80 = Color(0xFF8A8886);
  static const Color neutralGray90 = Color(0xFF605E5C);
  static const Color neutralGray100 = Color(0xFF484644);
  static const Color neutralGray110 = Color(0xFF323130);
  static const Color neutralGray120 = Color(0xFF201F1E);
  static const Color neutralGray130 = Color(0xFF11100F);
  static const Color neutralGray140 = Color(0xFF0B0A0A);
  static const Color neutralGray150 = Color(0xFF000000);

  // Semantic colors
  static const Color success = Color(0xFF107C10);
  static const Color successLight = Color(0xFF13A10E);
  static const Color successDark = Color(0xFF0D5D0A);
  
  static const Color warning = Color(0xFFFF8C00);
  static const Color warningLight = Color(0xFFFFB900);
  static const Color warningDark = Color(0xFFD2691E);
  
  static const Color error = Color(0xFFD13438);
  static const Color errorLight = Color(0xFFE74C3C);
  static const Color errorDark = Color(0xFFA52A2A);
  
  static const Color info = Color(0xFF0078D4);
  static const Color infoLight = Color(0xFF106EBE);
  static const Color infoDark = Color(0xFF005A9E);

  // Surface colors
  static const Color surface = neutralWhite;
  static const Color surfaceVariant = neutralGray10;
  static const Color surfaceSecondary = neutralGray20;
  static const Color surfaceTertiary = neutralGray30;
  
  // Background colors
  static const Color background = neutralGray10;
  static const Color backgroundSecondary = neutralGray20;
  
  // Border colors
  static const Color border = neutralGray30;
  static const Color borderStrong = neutralGray60;
  static const Color borderFocus = accent;
  
  // Text colors
  static const Color textPrimary = neutralGray130;
  static const Color textSecondary = neutralGray100;
  static const Color textTertiary = neutralGray80;
  static const Color textDisabled = neutralGray70;
  
  // Interactive colors
  static const Color interactive = accent;
  static const Color interactiveHover = accentLight;
  static const Color interactivePressed = accentDark;
  static const Color interactiveDisabled = neutralGray60;
  
  // Focus colors
  static const Color focus = accent;
  static const Color focusInner = neutralWhite;
  
  // Shadow colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowDark = Color(0x33000000);
}
