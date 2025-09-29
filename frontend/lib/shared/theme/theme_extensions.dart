import 'package:flutter/material.dart';

extension FinanceTheme on ColorScheme {
  // Financial colors that are not part of Material 3 ColorScheme
  Color get income => const Color(0xFF10B981);
  Color get expense => const Color(0xFFEF4444);
  Color get savings => const Color(0xFF3B82F6);
  Color get warning => const Color(0xFFF59E0B);
  Color get success => const Color(0xFF10B981);
  Color get info => const Color(0xFF3B82F6);

  // Text colors mapped to theme
  Color get textPrimary => onSurface;
  Color get textSecondary => onSurfaceVariant;
  Color get textDisabled => onSurfaceVariant.withOpacity(0.38);

  // Background variations
  Color get backgroundVariant => surfaceVariant;

  // Custom gradients
  LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );

  LinearGradient get successGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, success.withOpacity(0.8)],
  );
}