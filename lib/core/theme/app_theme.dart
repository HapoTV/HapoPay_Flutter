import 'package:flutter/material.dart';
import 'package:hapo_pay/core/theme/colors.dart';
import 'package:hapo_pay/core/theme/text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColors.darkColorScheme,
      scaffoldBackgroundColor: AppColors.darkColorScheme.surface,
      textTheme: AppTextStyles.darkTextTheme.apply(
        bodyColor: AppColors.darkColorScheme.onSurface,
        displayColor: AppColors.darkColorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkColorScheme.surface.withOpacity(
          0.6,
        ), // Glassmorphism base
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // rounded-lg
          side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkColorScheme.primaryContainer,
          foregroundColor: AppColors.darkColorScheme.onPrimaryContainer,
          shape: const StadiumBorder(), // Pill shape
          elevation: 4,
          shadowColor: const Color(0xFFE91E63).withOpacity(0.4), // Magenta glow
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.darkColorScheme.outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.darkColorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.darkColorScheme.secondary,
          ), // Illuminates Teal
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkColorScheme.surface.withOpacity(0.8),
        selectedItemColor: AppColors.darkColorScheme.primary,
        unselectedItemColor: AppColors.darkColorScheme.onSurfaceVariant,
        elevation: 0,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColors.lightColorScheme,
      scaffoldBackgroundColor: AppColors.lightColorScheme.surface,
      textTheme: AppTextStyles.lightTextTheme.apply(
        bodyColor: AppColors.lightColorScheme.onSurface,
        displayColor: const Color(0xFF0F172A), // Slate Navy for headings
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCardSurface,
        elevation: 4, // Level 1 shadow approximation
        shadowColor: const Color(0xFF0F172A).withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Round Eight
          side: BorderSide.none, // No borders allowed on cards
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.lightColorScheme.primaryContainer, // Solid Magenta
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 0,
          minimumSize: const Size.fromHeight(48), // Large button height
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0F172A), // Slate Navy
          side: const BorderSide(color: AppColors.lightInputBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCardSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.lightInputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.lightInputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: AppColors.lightColorScheme.primaryContainer,
            width: 2,
          ), // Shifts to Magenta
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.lightColorScheme.primaryContainer;
          }
          return null;
        }),
        side: const BorderSide(
          color: Color(0xFF0F172A),
          width: 1.5,
        ), // Slate Navy for high contrast
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      ),
    );
  }
}
