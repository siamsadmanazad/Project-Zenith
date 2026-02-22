import 'package:flutter/material.dart';

/// Zenith Color Palette - Nordic Minimalism
///
/// Philosophy: Deep, calming darks with premium gold accents.
/// No harsh whites - everything is soft and elegant.
class AppColors {
  // ============ NORDIC DARK PALETTE ============

  /// Main background - Deep charcoal with blue undertones
  /// Think: Scandinavian winter night sky
  static const Color background = Color(0xFF1A1A2E);

  /// Surface layer - Slightly lighter for cards and panels
  static const Color surface = Color(0xFF16213E);

  /// Card/container background - Even more elevated
  static const Color card = Color(0xFF0F3460);

  /// Primary accent - Warm gold for highlights and CTAs
  /// Used for: Calculate button, active states, success
  static const Color accent = Color(0xFFE94560);

  /// Secondary accent - Softer gold for less prominent elements
  static const Color accentSecondary = Color(0xFFFFBD39);

  // ============ TEXT COLORS ============

  /// Primary text - Soft white, never harsh #FFFFFF
  static const Color textPrimary = Color(0xFFF5F5F5);

  /// Secondary text - Muted for labels and hints
  static const Color textSecondary = Color(0xFFA0A0B0);

  /// Disabled text - Very subtle
  static const Color textDisabled = Color(0xFF6B6B7B);

  // ============ SEMANTIC COLORS ============

  /// Success state - Soft green
  static const Color success = Color(0xFF4ECCA3);

  /// Error state - Muted red (not aggressive)
  static const Color error = Color(0xFFE94560);

  /// Warning state - Amber
  static const Color warning = Color(0xFFFFBD39);

  /// Info state - Blue
  static const Color info = Color(0xFF4A90E2);

  // ============ GLASS EFFECT COLORS ============

  /// Glassmorphism overlay - 10% white
  static const Color glassOverlay = Color(0x1AFFFFFF);

  /// Glass border - 20% white
  static const Color glassBorder = Color(0x33FFFFFF);

  /// Glass shadow - 10% black
  static const Color glassShadow = Color(0x1A000000);

  // ============ KEY CATEGORY TINTS ============
  // Resting-state tints per key category. 5–8% opacity — only visible by contrast.
  // ALL active-state overrides (2ND, CPT, TVM focused) supersede these.

  static const Color keyDigitBg       = Color(0x14FFFFFF);
  static const Color keyDigitBorder   = Color(0x29FFFFFF);

  static const Color keyTvmBg         = Color(0x12FFBD39);
  static const Color keyTvmBorder     = Color(0x22FFBD39);

  static const Color keyOperatorBg     = Color(0x0D4A90E2);
  static const Color keyOperatorBorder = Color(0x1A4A90E2);
  static const Color keyOperatorText   = Color(0xFFD0D0DC);

  static const Color keyFunctionBg     = Color(0x0FFFFFFF);
  static const Color keyFunctionBorder = Color(0x20FFFFFF);
  static const Color keyFunctionText   = Color(0xFFB8B8C8);

  static const Color keyControlBg     = Color(0x0DFFBD39);
  static const Color keyControlBorder = Color(0x1AFFBD39);

  static const Color keyClearBg       = Color(0x0DE94560);
  static const Color keyClearBorder   = Color(0x1AE94560);
  static const Color keyClearText     = Color(0xFFE8C0C8);

  static const Color key2NdBg         = Color(0x11FFBD39);
  static const Color key2NdBorder     = Color(0x22FFBD39);

  // ============ GRADIENTS ============

  /// Accent gradient - For premium buttons
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE94560), Color(0xFFFF6B7A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Background gradient - Subtle depth
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF0F1419)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============ OPACITY HELPERS ============

  /// Returns a color with specified opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
