import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_dimensions.dart';

/// Nordic Dark Theme - Zenith's Signature Look
///
/// A premium dark theme inspired by Nordic minimalism:
/// - Deep, calming backgrounds
/// - Soft, non-harsh whites
/// - Warm gold accents
/// - Generous whitespace
class NordicTheme {
  /// Get the complete Nordic dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      // ============ BASE SETTINGS ============
      useMaterial3: true,
      brightness: Brightness.dark,

      // ============ COLOR SCHEME ============
      colorScheme: ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentSecondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),

      // ============ SCAFFOLD BACKGROUND ============
      scaffoldBackgroundColor: AppColors.background,

      // ============ APP BAR THEME ============
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.headlineMedium,
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: AppDimensions.iconM,
        ),
      ),

      // ============ CARD THEME ============
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),

      // ============ INPUT DECORATION THEME ============
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,

        // Border styling
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: BorderSide(
            color: AppColors.glassBorder,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: BorderSide(
            color: AppColors.glassBorder,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: BorderSide(
            color: AppColors.accent,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppDimensions.inputBorderWidth,
          ),
        ),

        // Text styling
        labelStyle: AppTypography.labelLarge,
        hintStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.textDisabled,
        ),

        // Padding
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingL,
          vertical: AppDimensions.spacingM,
        ),
      ),

      // ============ ELEVATED BUTTON THEME ============
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXl,
            vertical: AppDimensions.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),

      // ============ TEXT BUTTON THEME ============
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: AppTypography.buttonMedium,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingL,
            vertical: AppDimensions.spacingS,
          ),
        ),
      ),

      // ============ ICON THEME ============
      iconTheme: IconThemeData(
        color: AppColors.textSecondary,
        size: AppDimensions.iconM,
      ),

      // ============ DIVIDER THEME ============
      dividerTheme: DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
        space: AppDimensions.spacingL,
      ),

      // ============ TYPOGRAPHY THEME ============
      textTheme: TextTheme(
        // Display styles (large numbers)
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,

        // Headlines (titles)
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,

        // Body text
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,

        // Labels
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),

      // ============ FONT FAMILY (Fallback) ============
      fontFamily: GoogleFonts.inter().fontFamily,
    );
  }

  /// Configure system UI overlay (status bar, navigation bar)
  static void setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
}
