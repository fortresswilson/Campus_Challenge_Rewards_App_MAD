import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF3D35CC);
  static const Color secondary = Color(0xFF00E5A0);
  static const Color accent = Color(0xFFFF6B6B);

  // Backgrounds
  static const Color bgDark = Color(0xFF0F0E17);
  static const Color bgCard = Color(0xFF1A1929);
  static const Color bgCardLight = Color(0xFF252340);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFABABBF);
  static const Color textMuted = Color(0xFF6B6B85);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF3D35CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1929), Color(0xFF252340)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F0E17), Color(0xFF1A0533)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFF00E5A0), Color(0xFF00BF80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    final nunitoTextTheme = GoogleFonts.nunitoTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      primaryColor: AppColors.primary,
      textTheme: nunitoTextTheme,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgCard,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2E2C4A), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2E2C4A), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textMuted),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      cardTheme: CardThemeData(
      color: AppColors.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
  ),
),
    );
  }
}

// Text Styles
class AppTextStyles {
  static TextStyle get heading1 => GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: -1,
        height: 1.1,
      );

  static TextStyle get heading2 => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get heading3 => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get label => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      );

  static TextStyle get button => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.3,
      );
}