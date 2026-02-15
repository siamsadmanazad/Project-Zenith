import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Zenith Typography System
///
/// Uses Inter for UI text and SF Pro Display for numbers.
/// SF Pro gives that premium "Apple Finance App" feel to numbers.
class AppTypography {
  // ============ DISPLAY STYLES (Large numbers) ============

  /// Huge display - For the main result
  /// Example: "$3,421.32"
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 64,
    fontWeight: FontWeight.w300, // Light weight for elegance
    letterSpacing: -1.5,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  /// Medium display - For secondary results
  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// Small display - For labels above numbers
  static TextStyle displaySmall = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // ============ HEADLINE STYLES (Titles) ============

  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ============ BODY STYLES (Regular text) ============

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ============ LABEL STYLES (Field labels, hints) ============

  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textDisabled,
    letterSpacing: 0.5,
  );

  // ============ BUTTON STYLES ============

  static TextStyle buttonLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 1.0,
  );

  static TextStyle buttonMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static TextStyle buttonSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  // ============ SPECIAL STYLES ============

  /// For currency amounts - uses tabular numbers for alignment
  static TextStyle currency = GoogleFonts.inter(
    fontSize: 64,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.5,
    color: AppColors.textPrimary,
    fontFeatures: [
      FontFeature.tabularFigures(), // Numbers align vertically
    ],
  );

  /// For input fields - mono spaced numbers
  static TextStyle input = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    fontFeatures: [
      FontFeature.tabularFigures(),
    ],
  );

  /// For verification/formula display - monospace
  static TextStyle code = GoogleFonts.robotoMono(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );
}
