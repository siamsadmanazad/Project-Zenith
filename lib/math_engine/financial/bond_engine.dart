import 'dart:math' as math;

/// Bond pricing and yield calculations.
class BondEngine {
  /// Compute bond price.
  ///
  /// [coupon] — annual coupon rate as a percentage (e.g. 6 for 6%).
  /// [yield_] — annual yield as a percentage.
  /// [redemption] — redemption value (par), typically 100.
  /// [frequency] — coupons per year (1 = annual, 2 = semi-annual).
  /// [periodsRemaining] — number of coupon periods remaining.
  /// [dayCount] — reserved for day-count convention (0 = default).
  static double price({
    required double coupon,
    required double yield_,
    required double redemption,
    required int frequency,
    required int periodsRemaining,
    int dayCount = 0,
  }) {
    final c = coupon / frequency / 100.0 * redemption; // coupon payment
    final y = yield_ / frequency / 100.0; // periodic yield

    if (y.abs() < 1e-14) {
      // Zero yield: price is just sum of cash flows
      return c * periodsRemaining + redemption;
    }

    double pvCoupons = 0;
    for (int t = 1; t <= periodsRemaining; t++) {
      pvCoupons += c / math.pow(1 + y, t);
    }
    final pvRedemption = redemption / math.pow(1 + y, periodsRemaining);

    return pvCoupons + pvRedemption;
  }

  /// Compute bond yield via Newton-Raphson.
  ///
  /// Returns yield as an annual percentage.
  /// [coupon] — annual coupon rate as a percentage.
  /// [price_] — bond price (dirty price).
  /// [redemption] — redemption value, typically 100.
  /// [frequency] — coupons per year (1 or 2).
  /// [periodsRemaining] — number of coupon periods remaining.
  /// [guess] — initial yield guess as a percentage.
  static double yield_({
    required double coupon,
    required double price,
    required double redemption,
    required int frequency,
    required int periodsRemaining,
    double guess = 5.0,
    int maxIter = 1000,
    double tolerance = 1e-10,
  }) {
    final c = coupon / frequency / 100.0 * redemption; // coupon payment
    double y = guess / frequency / 100.0; // periodic yield guess

    for (int i = 0; i < maxIter; i++) {
      // f(y) = price(y) - target price
      double f = -price;
      double df = 0;

      for (int t = 1; t <= periodsRemaining; t++) {
        final disc = math.pow(1 + y, t);
        f += c / disc;
        df -= t * c / math.pow(1 + y, t + 1);
      }
      final discN = math.pow(1 + y, periodsRemaining);
      f += redemption / discN;
      df -= periodsRemaining * redemption / math.pow(1 + y, periodsRemaining + 1);

      if (df.abs() < 1e-20) throw Exception('Yield: derivative too small');

      final newY = y - f / df;
      if ((newY - y).abs() < tolerance) return newY * frequency * 100.0;
      y = newY;
    }
    throw Exception('Yield did not converge');
  }
}
