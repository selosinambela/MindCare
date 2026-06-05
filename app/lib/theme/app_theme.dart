import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema modern & menenangkan MindCare — Light Mode Sage Green.
class AppTheme {
  // ── Color Palette ────────────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF7A9E84); // Slightly darker elegant Sage Green
  static const Color softGreen = Color(0xFFE0EAE3); // More contrasted mint tint
  static const Color background = Color(0xFFF4F7F5); // Slightly cooler off-white
  static const Color darkText = Color(0xFF14201A); // Deepest Charcoal Green for high contrast text
  static const Color cardDark = Color(0xFFFFFFFF); // Clean White Cards
  static const Color cardDarkAlt = Color(0xFFFAFCFA);
  static const Color surfaceDark = Color(0xFFFFFFFF);
  static const Color accentPurple = Color(0xFF9E8EC4); // Soft Lavender
  static const Color accentBlue = Color(0xFF7BAED9); // Soft Blue
  static const Color accentOrange = Color(0xFFE8A864); // Soft Peach/Orange
  static const Color accentPink = Color(0xFFE88A9A); // Soft Blush Pink
  
  // ── Pastel Variations ────────────────────────────────────────────────
  static const Color pastelYellow = Color(0xFFFFF3CA); // Cream / Pastel Yellow (Thicker)
  static const Color pastelBlue = Color(0xFFF3F8FC);
  static const Color pastelPink = Color(0xFFFCF3F5);
  static const Color pastelPurple = Color(0xFFF8F3FC);

  static const Color textSecondary = Color(0xFF6B8074); // Slate Green Grey
  static const Color dividerColor = Color(0xFFDDE5E0);

  // ── Gradients ────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9CBCA8), Color(0xFF83A78D)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFCFA)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE4EDE7), Color(0xFFF4F7F5)],
  );

  // ── Glassmorphism Decoration ─────────────────────────────────────────
  static BoxDecoration glassDecoration({
    double borderRadius = 24,
    Color? color,
    double opacity = 0.5,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.6),
        width: 1,
      ),
    );
  }

  // ── Card Decoration ──────────────────────────────────────────────────
  static BoxDecoration cardDecoration({double borderRadius = 24, Color? color}) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: const Color(0xFFE4EDE7),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF23352A).withValues(alpha: 0.08),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // ── Theme Data ───────────────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    primaryColor: primaryGreen,

    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: darkText,
      displayColor: darkText,
    ),

    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: accentPurple,
      surface: cardDark,
      onPrimary: Colors.white,
      onSurface: darkText,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: darkText),
      titleTextStyle: GoogleFonts.poppins(
        color: darkText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryGreen,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE4EDE7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE4EDE7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      hintStyle: const TextStyle(color: textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 0,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        side: const BorderSide(color: Color(0xFFC4D5CB)),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}