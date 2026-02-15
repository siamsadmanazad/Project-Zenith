/// Zenith Dimension System
///
/// Consistent spacing, padding, and sizing throughout the app.
/// Based on an 8px grid system (4, 8, 12, 16, 24, 32, 48, 64...)
class AppDimensions {
  // ============ SPACING (Padding & Margins) ============

  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;
  static const double spacingXxxl = 64.0;

  // ============ BORDER RADIUS ============

  /// Small radius - For subtle rounding
  static const double radiusS = 8.0;

  /// Medium radius - Default for cards and buttons
  static const double radiusM = 16.0;

  /// Large radius - For prominent elements
  static const double radiusL = 24.0;

  /// Extra large radius - For pill shapes
  static const double radiusXl = 32.0;

  // ============ BUTTON SIZES ============

  /// Button height - Standard
  static const double buttonHeight = 56.0;

  /// Button height - Large (Calculate, Submit)
  static const double buttonHeightLarge = 64.0;

  /// Button height - Small (Secondary actions)
  static const double buttonHeightSmall = 48.0;

  // ============ INPUT FIELD SIZES ============

  /// Input field height
  static const double inputHeight = 56.0;

  /// Input field border width
  static const double inputBorderWidth = 1.0;

  // ============ ICON SIZES ============

  static const double iconXs = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXl = 48.0;

  // ============ GLASS EFFECT VALUES ============

  /// Blur amount for glassmorphism
  static const double glassBlur = 20.0;

  /// Border width for glass cards
  static const double glassBorderWidth = 1.0;

  /// Shadow blur radius
  static const double glassShadowBlur = 30.0;

  // ============ SCREEN PADDING ============

  /// Safe padding from screen edges
  static const double screenPaddingH = 20.0; // Horizontal
  static const double screenPaddingV = 24.0; // Vertical

  // ============ CARD DIMENSIONS ============

  /// Standard card padding
  static const double cardPadding = 20.0;

  /// Card elevation (shadow depth)
  static const double cardElevation = 4.0;

  // ============ ANIMATION DURATIONS (in milliseconds) ============

  static const int animationFast = 150;
  static const int animationMedium = 300;
  static const int animationSlow = 500;
}
