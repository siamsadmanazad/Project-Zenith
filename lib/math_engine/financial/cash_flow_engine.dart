import 'dart:math' as math;

/// Cash flow analysis: NPV and IRR.
class CashFlowEntry {
  final double amount;
  final int frequency; // how many times this cash flow repeats
  const CashFlowEntry(this.amount, [this.frequency = 1]);
}

class CashFlowEngine {
  /// Compute Net Present Value.
  /// [rate] is the discount rate as a percentage (e.g., 10 for 10%).
  /// cashFlows[0] is CF0 (initial investment, usually negative).
  static double npv(List<CashFlowEntry> cashFlows, double rate) {
    final r = rate / 100.0;
    double result = 0;
    int period = 0;
    for (final cf in cashFlows) {
      for (int i = 0; i < cf.frequency; i++) {
        result += cf.amount / math.pow(1 + r, period);
        period++;
      }
    }
    return result;
  }

  /// Compute Internal Rate of Return using Newton-Raphson.
  /// Returns rate as a percentage.
  static double irr(
    List<CashFlowEntry> cashFlows, {
    double guess = 10.0,
    int maxIter = 1000,
    double tolerance = 1e-10,
  }) {
    // Expand cash flows into flat list
    final flat = <double>[];
    for (final cf in cashFlows) {
      for (int i = 0; i < cf.frequency; i++) {
        flat.add(cf.amount);
      }
    }

    double rate = guess / 100.0;
    for (int i = 0; i < maxIter; i++) {
      double f = 0, df = 0;
      for (int t = 0; t < flat.length; t++) {
        final denom = math.pow(1 + rate, t);
        f += flat[t] / denom;
        if (t > 0) {
          df -= t * flat[t] / math.pow(1 + rate, t + 1);
        }
      }
      if (df.abs() < 1e-20) throw Exception('IRR: derivative too small');
      final newRate = rate - f / df;
      if ((newRate - rate).abs() < tolerance) return newRate * 100.0;
      rate = newRate;
    }
    throw Exception('IRR did not converge');
  }
}
