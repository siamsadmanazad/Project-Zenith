import 'dart:math' as math;

/// Trigonometric function dispatch for TI BA II Plus.
///
/// Supports sin/cos/tan with degree input, inverse variants returning degrees,
/// hyperbolic variants, and inverse hyperbolic.
class TrigFunctions {
  static const _degToRad = math.pi / 180.0;
  static const _radToDeg = 180.0 / math.pi;

  /// Dispatch a trig function based on base function and modifier flags.
  ///
  /// [base] is 'sin', 'cos', or 'tan'.
  /// [inv] applies arc/inverse variant.
  /// [hyp] applies hyperbolic variant.
  static double evaluate(String base, double x,
      {bool inv = false, bool hyp = false}) {
    if (hyp && inv) {
      return _inverseHyperbolic(base, x);
    } else if (hyp) {
      return _hyperbolic(base, x);
    } else if (inv) {
      return _inverse(base, x);
    } else {
      return _standard(base, x);
    }
  }

  // Standard trig: input in degrees
  static double _standard(String base, double degrees) {
    final rad = degrees * _degToRad;
    switch (base) {
      case 'sin':
        return math.sin(rad);
      case 'cos':
        return math.cos(rad);
      case 'tan':
        return math.tan(rad);
      default:
        throw ArgumentError('Unknown trig: $base');
    }
  }

  // Inverse trig: returns degrees
  static double _inverse(String base, double x) {
    switch (base) {
      case 'sin':
        if (x < -1 || x > 1) throw ArgumentError('Domain error: asin($x)');
        return math.asin(x) * _radToDeg;
      case 'cos':
        if (x < -1 || x > 1) throw ArgumentError('Domain error: acos($x)');
        return math.acos(x) * _radToDeg;
      case 'tan':
        return math.atan(x) * _radToDeg;
      default:
        throw ArgumentError('Unknown trig: $base');
    }
  }

  // Hyperbolic: input is unitless
  static double _hyperbolic(String base, double x) {
    switch (base) {
      case 'sin':
        return (math.exp(x) - math.exp(-x)) / 2; // sinh
      case 'cos':
        return (math.exp(x) + math.exp(-x)) / 2; // cosh
      case 'tan':
        final s = (math.exp(x) - math.exp(-x)) / 2;
        final c = (math.exp(x) + math.exp(-x)) / 2;
        return s / c; // tanh
      default:
        throw ArgumentError('Unknown trig: $base');
    }
  }

  // Inverse hyperbolic
  static double _inverseHyperbolic(String base, double x) {
    switch (base) {
      case 'sin': // asinh
        return math.log(x + math.sqrt(x * x + 1));
      case 'cos': // acosh
        if (x < 1) throw ArgumentError('Domain error: acosh($x)');
        return math.log(x + math.sqrt(x * x - 1));
      case 'tan': // atanh
        if (x <= -1 || x >= 1) throw ArgumentError('Domain error: atanh($x)');
        return 0.5 * math.log((1 + x) / (1 - x));
      default:
        throw ArgumentError('Unknown trig: $base');
    }
  }
}
