import 'package:flutter/material.dart';

/// Dark Electric Blue & Black color palette
class AppColors {
  AppColors._();

  // Premium Palette
  static const Color luxuryBlack = Color(0xFF0F0F0F);
  static const Color deepSurface = Color(0xFF1A1A1A);

  // Dark Electric Blue Palette
  static const Color electricBlue = Color(0xFF0D47A1); // Dark Electric Blue
  static const Color lightElectricBlue = Color(
    0xFF5C9CE6,
  ); // Light Electric Blue
  static const Color deepElectricBlue = Color(0xFF0A3474); // Deep Electric Blue

  // Accents
  static const Color ivory = Color(0xFFFFFFF0);
  static const Color platinum = Color(0xFFE5E4E2);

  // Semantic
  static const Color success = Color(0xFF4CB050);
  static const Color warning = Color(0xFFFBBC05);
  static const Color error = Color(0xFFEA4335);

  // Backgrounds
  static const Color bgBlack = Color(0xFF000000);

  // GNav Theme
  static const Color navUnselected = Colors.white54;
  static const Color navSelected = electricBlue;

  // Gradients
  static const List<Color> electricBlueGradient = [
    electricBlue,
    lightElectricBlue,
    deepElectricBlue,
  ];

  static const List<Color> darkGradient = [
    Color(0xFF1A1A1A),
    Color(0xFF0F0F0F),
  ];
}
