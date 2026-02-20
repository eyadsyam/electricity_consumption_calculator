import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Luxury Gradients
  static const LinearGradient luxuryBlueGradient = LinearGradient(
    colors: AppColors.electricBlueGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryDarkGradient = LinearGradient(
    colors: AppColors.darkGradient,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color primaryColor = AppColors.electricBlue;
    final Color scaffoldBg = isDark ? AppColors.bgBlack : Colors.white;
    final Color surfaceColor = isDark
        ? AppColors.deepSurface
        : Colors.grey[50]!;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: AppColors.deepElectricBlue,
        surface: surfaceColor,
        error: AppColors.error,
        onPrimary:
            Colors.white, // Ensure text on primary is white (dark blue bg)
      ),

      // Override default blue selection/focus colors
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionColor: primaryColor.withValues(alpha: 0.3),
        selectionHandleColor: primaryColor,
      ),

      focusColor: primaryColor.withValues(alpha: 0.1),
      highlightColor: primaryColor.withValues(alpha: 0.1),
      splashColor: primaryColor.withValues(alpha: 0.1),

      // TabBar Theme
      tabBarTheme: TabBarThemeData(
        indicatorColor: primaryColor,
        labelColor: primaryColor,
        unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
      ),

      // Typography
      fontFamily: GoogleFonts.cairo().fontFamily,
      textTheme: GoogleFonts.cairoTextTheme()
          .apply(
            bodyColor: isDark ? Colors.white : AppColors.luxuryBlack,
            displayColor: isDark
                ? AppColors.electricBlue
                : AppColors.deepElectricBlue,
          )
          .copyWith(
            displayLarge: TextStyle(
              fontSize: 24, // Reduced from 32
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: isDark ? AppColors.electricBlue : AppColors.luxuryBlack,
            ),
            titleLarge: TextStyle(
              fontSize: 18, // Reduced from 20
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.luxuryBlack,
            ),
          ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18, // Reduced from 20
          fontWeight: FontWeight.bold,
          color: primaryColor,
          letterSpacing: 1.2,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 10,
        shadowColor: isDark
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.deepSurface : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        floatingLabelStyle: TextStyle(color: primaryColor),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 5,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      useMaterial3: true,
    );
  }
}
