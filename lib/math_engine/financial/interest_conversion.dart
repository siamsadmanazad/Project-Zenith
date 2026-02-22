import 'dart:math' as math;

/// Interest rate conversion: nominal ↔ effective.
class InterestConversion {
  /// Convert nominal annual rate to effective annual rate.
  /// [nominal] is the nominal rate as a percentage (e.g. 12 for 12%).
  /// [cpy] is compounding periods per year.
  static double nominalToEffective(double nominal, int cpy) {
    if (cpy <= 0) throw ArgumentError('C/Y must be positive');
    final r = nominal / 100.0;
    final eff = (math.pow(1 + r / cpy, cpy) - 1) * 100.0;
    return eff;
  }

  /// Convert effective annual rate to nominal annual rate.
  /// [effective] is the effective rate as a percentage.
  /// [cpy] is compounding periods per year.
  static double effectiveToNominal(double effective, int cpy) {
    if (cpy <= 0) throw ArgumentError('C/Y must be positive');
    final eff = effective / 100.0;
    final nom = (math.pow(1 + eff, 1.0 / cpy) - 1) * cpy * 100.0;
    return nom;
  }
}
