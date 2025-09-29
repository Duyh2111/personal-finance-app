import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Professional Finance Blue
  static const Color primary = Color(0xFF1E40AF);        // Deep trustworthy blue
  static const Color primaryDark = Color(0xFF1E3A8A);    // Darker blue
  static const Color primaryLight = Color(0xFF3B82F6);   // Lighter blue

  // Secondary Colors - Professional Gray
  static const Color secondary = Color(0xFF6B7280);      // Professional gray
  static const Color secondaryDark = Color(0xFF4B5563);  // Darker gray
  static const Color secondaryLight = Color(0xFF9CA3AF); // Lighter gray

  // Neutral Colors
  static const Color black = Color(0xFF0F172A);          // Rich black
  static const Color darkGray = Color(0xFF1E293B);       // Dark slate
  static const Color gray = Color(0xFF475569);           // Medium slate
  static const Color lightGray = Color(0xFFCBD5E1);      // Light slate
  static const Color background = Color(0xFFF8FAFC);     // Very light blue-gray
  static const Color surface = Color(0xFFFFFFFF);        // Pure white

  // Status Colors
  static const Color success = Color(0xFF059669);        // Forest green
  static const Color warning = Color(0xFFD97706);        // Amber
  static const Color error = Color(0xFFDC2626);          // Red
  static const Color info = Color(0xFF0284C7);           // Sky blue

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);    // Near black
  static const Color textSecondary = Color(0xFF475569);  // Dark gray
  static const Color textDisabled = Color(0xFF94A3B8);   // Light gray

  // Financial Colors
  static const Color income = Color(0xFF059669);         // Forest green (positive)
  static const Color expense = Color(0xFFDC2626);        // Red (negative)
  static const Color savings = Color(0xFF7C3AED);        // Purple (savings)

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );
}