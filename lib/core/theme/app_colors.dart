import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  AppColors._(); // Private constructor

  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Secondary Colors
  static const Color secondary = Color(0xFF009688);
  static const Color secondaryDark = Color(0xFF00796B);
  static const Color secondaryLight = Color(0xFF4DB6AC);

  // Accent Colors
  static const Color accent = Color(0xFFFF9800);
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors - Light Theme
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Neutral Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2C2C2C);

  // Text Colors - Light Theme
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textDisabledLight = Color(0xFFBDBDBD);

  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF616161);

  // Special Colors
  static const Color electricity = Color(0xFFFFC107); // Amber for electricity
  static const Color consumption = Color(0xFF2196F3); // Blue for consumption
  static const Color budget = Color(0xFF4CAF50); // Green for budget
  static const Color overBudget = Color(0xFFF44336); // Red for over budget

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF42A5F5),
    Color(0xFF1976D2),
  ];

  static const List<Color> successGradient = [
    Color(0xFF66BB6A),
    Color(0xFF388E3C),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFEF5350),
    Color(0xFFC62828),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFFCA28),
    Color(0xFFF57F17),
  ];

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFFC107),
    Color(0xFFFF5722),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
  ];

  // Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.05);
  static Color shadowDark = Colors.black.withOpacity(0.3);
}
