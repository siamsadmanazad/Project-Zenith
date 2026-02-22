import 'package:flutter/services.dart';

/// Semantic haptic feedback for different key categories.
class HapticService {
  static void digit() => HapticFeedback.lightImpact();
  static void operator_() => HapticFeedback.mediumImpact();
  static void tvm() => HapticFeedback.mediumImpact();
  static void function_() => HapticFeedback.mediumImpact();
  static void error() => HapticFeedback.heavyImpact();
  static void clear() => HapticFeedback.heavyImpact();
  static void mode() => HapticFeedback.selectionClick();
}
