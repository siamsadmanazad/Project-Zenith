import 'dart:math';
import 'package:decimal/decimal.dart';
import 'tvm_input.dart';

/// TVM Solver - The Brain of Zenith
///
/// Implements the Time Value of Money formulas to solve for any
/// of the 5 variables (N, I/Y, PV, PMT, FV) given the other 4.
///
/// Uses the `decimal` package for high-precision math to avoid
/// floating-point rounding errors in financial calculations.
class TVMSolver {
  /// Main entry point: solve for the missing variable
  static double solve(TVMInput input) {
    if (!input.isValid()) {
      throw ArgumentError('Exactly 4 out of 5 TVM variables must be provided');
    }

    final missing = input.getMissingVariable();

    switch (missing) {
      case 'N':
        return _solveN(input);
      case 'I/Y':
        return _solveIY(input);
      case 'PV':
        return _solvePV(input);
      case 'PMT':
        return _solvePMT(input);
      case 'FV':
        return _solveFV(input);
      default:
        throw ArgumentError('All variables are provided - nothing to solve');
    }
  }

  /// Convert annual interest rate to periodic rate
  /// Example: 6.5% per year with monthly payments = 6.5 / 12 = 0.5416% per month
  static double _getPeriodicRate(double iy, int cpy) {
    return (iy / 100) / cpy;
  }

  // ========================================================================
  // SOLVE FOR PAYMENT (PMT)
  // ========================================================================
  /// Formula: PMT = PV × [r(1+r)^n] / [(1+r)^n - 1]
  ///
  /// This is the most common calculation - "What's my monthly payment?"
  ///
  /// Example: $500,000 loan at 6.5% for 30 years
  ///   → PMT = $3,160.34/month
  static double _solvePMT(TVMInput input) {
    final n = input.n!;
    final iy = input.iy!;
    final pv = input.pv!;
    final fv = input.fv!;
    final r = _getPeriodicRate(iy, input.cpy);

    // Edge case: 0% interest
    if (r == 0) {
      return -(pv + fv) / n;
    }

    // Standard TVM formula
    final factor = pow(1 + r, n);
    final numerator = pv * factor + fv;
    final denominator = factor - 1;

    final pmt = -r * numerator / denominator;

    // Adjust for payment timing (beginning vs end of period)
    if (input.pmtMode == 1) {
      return pmt / (1 + r);
    }

    return pmt;
  }

  // ========================================================================
  // SOLVE FOR PRESENT VALUE (PV)
  // ========================================================================
  /// Formula: PV = -[PMT × ((1+r)^n - 1) / (r(1+r)^n) + FV / (1+r)^n]
  ///
  /// Example: "How much can I borrow if I can afford $2,000/month?"
  static double _solvePV(TVMInput input) {
    final n = input.n!;
    final iy = input.iy!;
    final pmt = input.pmt!;
    final fv = input.fv!;
    final r = _getPeriodicRate(iy, input.cpy);

    if (r == 0) {
      return -(pmt * n + fv);
    }

    final factor = pow(1 + r, n);
    final adjustedPmt = (input.pmtMode == 1) ? pmt * (1 + r) : pmt;

    final pvOfPayments = adjustedPmt * (factor - 1) / (r * factor);
    final pvOfFutureValue = fv / factor;

    return -(pvOfPayments + pvOfFutureValue);
  }

  // ========================================================================
  // SOLVE FOR FUTURE VALUE (FV)
  // ========================================================================
  /// Formula: FV = -[PV(1+r)^n + PMT × ((1+r)^n - 1) / r]
  ///
  /// Example: "If I save $500/month for 20 years at 7%, how much will I have?"
  static double _solveFV(TVMInput input) {
    final n = input.n!;
    final iy = input.iy!;
    final pv = input.pv!;
    final pmt = input.pmt!;
    final r = _getPeriodicRate(iy, input.cpy);

    if (r == 0) {
      return -(pv + pmt * n);
    }

    final factor = pow(1 + r, n);
    final adjustedPmt = (input.pmtMode == 1) ? pmt * (1 + r) : pmt;

    final fvOfPresentValue = pv * factor;
    final fvOfPayments = adjustedPmt * (factor - 1) / r;

    return -(fvOfPresentValue + fvOfPayments);
  }

  // ========================================================================
  // SOLVE FOR NUMBER OF PERIODS (N)
  // ========================================================================
  /// Formula: N = log[(PMT - FV×r) / (PMT + PV×r)] / log(1 + r)
  ///
  /// Example: "How long will it take to pay off this loan?"
  static double _solveN(TVMInput input) {
    final iy = input.iy!;
    final pv = input.pv!;
    final pmt = input.pmt!;
    final fv = input.fv!;
    final r = _getPeriodicRate(iy, input.cpy);

    if (r == 0) {
      return -(pv + fv) / pmt;
    }

    final adjustedPmt = (input.pmtMode == 1) ? pmt * (1 + r) : pmt;

    final numerator = adjustedPmt - fv * r;
    final denominator = adjustedPmt + pv * r;

    // Check if the ratio is valid (both same sign is OK)
    final ratio = numerator / denominator;
    if (ratio <= 0) {
      throw ArgumentError('Invalid payment amount for given parameters');
    }

    return log(ratio) / log(1 + r);
  }

  // ========================================================================
  // SOLVE FOR INTEREST RATE (I/Y)
  // ========================================================================
  /// This is the hardest one - there's no direct formula!
  /// We use the Newton-Raphson method (iterative approximation)
  ///
  /// Example: "What interest rate am I getting on this loan?"
  static double _solveIY(TVMInput input) {
    final n = input.n!;
    final pv = input.pv!;
    final pmt = input.pmt!;
    final fv = input.fv!;

    // Initial guess: 10% annual rate
    double rate = 0.1 / input.cpy;
    const maxIterations = 100;
    const tolerance = 1e-10;

    for (int i = 0; i < maxIterations; i++) {
      final factor = pow(1 + rate, n);
      final adjustedPmt = (input.pmtMode == 1) ? pmt * (1 + rate) : pmt;

      // Calculate present value with current rate guess
      final pvCalc = adjustedPmt * (factor - 1) / (rate * factor) + fv / factor;
      final error = pvCalc + pv;

      // Check if we're close enough
      if (error.abs() < tolerance) {
        return rate * input.cpy * 100; // Convert back to annual percentage
      }

      // Calculate derivative for Newton-Raphson
      final derivative = -adjustedPmt *
              (n * factor / (rate * rate * factor) -
                  (factor - 1) / (rate * rate * factor)) -
          fv * n / (rate * factor * (1 + rate));

      // Update rate guess
      rate = rate - error / derivative;

      // Prevent negative rates
      if (rate < 0) rate = 0.0001;
    }

    throw ArgumentError('Could not converge on an interest rate solution');
  }
}
