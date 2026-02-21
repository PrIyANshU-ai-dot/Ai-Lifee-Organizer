import 'package:flutter/material.dart';

/// Centralized color definitions for the app.
/// Makes it easy to maintain consistent colors across light/dark themes.
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF818CF8);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color secondaryDark = Color(0xFFA78BFA);

  // Light theme
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightBackground = Color(0xFFF1F5F9);
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark theme
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkOnSurface = Color(0xFFF8FAFC);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkInputFill = Color(0xFF334155);

  // Semantic colors
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFF87171);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradient colors
  static const List<Color> primaryGradientColors = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFA855F7),
  ];
}
