import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class AppTheme {
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryLight,
      tertiary: AppColors.income,
      error: AppColors.error,
      errorContainer: Color(0xFFFFDAD6),
      outline: AppColors.lightGray,
      outlineVariant: Color(0xFFE5E7EB),
      surface: AppColors.surface,
      surfaceVariant: AppColors.background,
      inverseSurface: AppColors.black,
      onPrimary: Colors.white,
      onPrimaryContainer: AppColors.primaryDark,
      onSecondary: Colors.white,
      onSecondaryContainer: AppColors.secondaryDark,
      onTertiary: Colors.white,
      onError: Colors.white,
      onErrorContainer: AppColors.error,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      onInverseSurface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        toolbarHeight: AppSizes.toolbarHeight,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, AppSizes.buttonMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
          borderSide: BorderSide(color: colorScheme.outline, width: AppSizes.textFieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
          borderSide: BorderSide(color: colorScheme.outline, width: AppSizes.textFieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
          borderSide: BorderSide(color: colorScheme.primary, width: AppSizes.textFieldBorder),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
          borderSide: BorderSide(color: colorScheme.error, width: AppSizes.textFieldBorder),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
          borderSide: BorderSide(color: colorScheme.error, width: AppSizes.textFieldBorder),
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          fontSize: 16,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: AppSizes.cardElevation,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusLg)),
        ),
        color: colorScheme.surface,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primaryLight,
      primaryContainer: AppColors.primary,
      secondary: AppColors.secondaryLight,
      secondaryContainer: AppColors.secondary,
      tertiary: AppColors.income,
      error: AppColors.error,
      errorContainer: Color(0xFF93000A),
      outline: Color(0xFF938F99),
      outlineVariant: Color(0xFF49454F),
      surface: Color(0xFF1E1E1E),
      surfaceVariant: Color(0xFF121212),
      inverseSurface: Color(0xFFE6E1E5),
      onPrimary: Colors.black,
      onPrimaryContainer: AppColors.primaryLight,
      onSecondary: Colors.black,
      onSecondaryContainer: AppColors.secondaryLight,
      onTertiary: Colors.white,
      onError: Colors.white,
      onErrorContainer: Color(0xFFFFDAD6),
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFFCAC4D0),
      onInverseSurface: Color(0xFF313033),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        toolbarHeight: AppSizes.toolbarHeight,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, AppSizes.buttonMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
          borderSide: BorderSide(color: colorScheme.outline, width: AppSizes.textFieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
          borderSide: BorderSide(color: colorScheme.outline, width: AppSizes.textFieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
          borderSide: BorderSide(color: colorScheme.primary, width: AppSizes.textFieldBorder),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
          borderSide: BorderSide(color: colorScheme.error, width: AppSizes.textFieldBorder),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
          borderSide: BorderSide(color: colorScheme.error, width: AppSizes.textFieldBorder),
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          fontSize: 16,
        ),
      ),

      cardTheme: CardTheme(
        elevation: AppSizes.cardElevation,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusLg)),
        ),
        color: colorScheme.surface,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}