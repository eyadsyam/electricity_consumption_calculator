import 'package:flutter/material.dart';

/// Luxury Gold & Black color palette
class AppColors {
  AppColors._();

  // Premium Palette
  static const Color luxuryBlack = Color(0xFF0F0F0F);
  static const Color deepSurface = Color(0xFF1A1A1A);
  static const Color royalGold = Color(0xFFD4AF37); // Classic Gold
  static const Color lightGold = Color(0xFFF9E498);
  static const Color dullGold = Color(0xFFA68931);

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
  static const Color navSelected = royalGold;

  // Gradients
  static const List<Color> goldGradient = [royalGold, lightGold, dullGold];

  static const List<Color> darkGradient = [
    Color(0xFF1A1A1A),
    Color(0xFF0F0F0F),
  ];
}
