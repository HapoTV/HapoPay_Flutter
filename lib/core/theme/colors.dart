import 'package:flutter/material.dart';

class AppColors {
  // Prevent instantiation
  AppColors._();

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFFB2BE),
    onPrimary: Color(0xFF660025),
    primaryContainer: Color(0xFFFF4E7C),
    onPrimaryContainer: Color(0xFF5A0020),
    secondary: Color(0xFF44DDC2),
    onSecondary: Color(0xFF00382F),
    secondaryContainer: Color(0xFF00BEA5),
    onSecondaryContainer: Color(0xFF00463C),
    tertiary: Color(0xFFFFBA4B),
    onTertiary: Color(0xFF442B00),
    tertiaryContainer: Color(0xFFC48400),
    onTertiaryContainer: Color(0xFF3B2500),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF051424),
    onSurface: Color(0xFFD4E4FA),
    surfaceContainerHighest: Color(0xFF273647),
    onSurfaceVariant: Color(0xFFE4BDC2),
    outline: Color(0xFFAB888C),
    outlineVariant: Color(0xFF5B3F43),
    inverseSurface: Color(0xFFD4E4FA),
    onInverseSurface: Color(0xFF233143),
    inversePrimary: Color(0xFFBC004B),
    // Custom non-standard additions needed for components
    surfaceTint: Color(0xFFFFB2BE),
  );

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFB0004A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD81B60), // Uses Lumina Magenta from brand docs
    onPrimaryContainer: Color(0xFFFFF2F3),
    secondary: Color(0xFF565E74),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFDAE2FD),
    onSecondaryContainer: Color(0xFF5C647A),
    tertiary: Color(0xFF49596E),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFF617188),
    onTertiaryContainer: Color(0xFFF1F5FF),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: Color(0xFFF8FAFC), // Adjusted to match 'Base Surface' doc rule
    onSurface: Color(0xFF191C1E),
    surfaceContainerHighest: Color(0xFFE0E3E5),
    onSurfaceVariant: Color(0xFF5A4044),
    outline: Color(0xFF8E6F74),
    outlineVariant: Color(0xFFE3BDC3),
    inverseSurface: Color(0xFF2D3133),
    onInverseSurface: Color(0xFFEFF1F3),
    inversePrimary: Color(0xFFFFB2BF),
    surfaceTint: Color(0xFFBC004F),
  );
  
  // Specific UI component colors from docs
  static const Color darkInputFill = Color(0xFF070B14);
  static const Color lightInputBorder = Color(0xFFE2E8F0);
  static const Color lightCardSurface = Color(0xFFFFFFFF);
}