import 'dart:math' as math;

/// Statistics engine with regression models.
///
/// Supports linear, logarithmic, exponential, and power regression.
class StatisticsEngine {
  /// Computes regression statistics for the given [data] points using
  /// the specified [model].
  ///
  /// Returns a [StatResult] containing n, means, standard deviations,
  /// regression coefficients (a, b), and correlation coefficient (r).
  ///
  /// Throws [ArgumentError] if fewer than 2 data points are provided.
  static StatResult compute(
    List<(double, double)> data,
    RegressionModel model,
  ) {
    if (data.length < 2) {
      throw ArgumentError('At least 2 data points are required');
    }

    final n = data.length.toDouble();

    // Transform data according to model.
    final tx = <double>[];
    final ty = <double>[];

    for (final (x, y) in data) {
      switch (model) {
        case RegressionModel.lin:
          tx.add(x);
          ty.add(y);
        case RegressionModel.ln:
          if (x <= 0) throw ArgumentError('LN model requires positive x values');
          tx.add(math.log(x));
          ty.add(y);
        case RegressionModel.exp:
          if (y <= 0) throw ArgumentError('EXP model requires positive y values');
          tx.add(x);
          ty.add(math.log(y));
        case RegressionModel.pwr:
          if (x <= 0 || y <= 0) throw ArgumentError('PWR model requires positive x and y values');
          tx.add(math.log(x));
          ty.add(math.log(y));
      }
    }

    // Standard linear regression on transformed data.
    final sumX = tx.reduce((a, b) => a + b);
    final sumY = ty.reduce((a, b) => a + b);
    final meanTX = sumX / n;
    final meanTY = sumY / n;

    var sumXX = 0.0;
    var sumYY = 0.0;
    var sumXY = 0.0;
    for (var i = 0; i < data.length; i++) {
      final dx = tx[i] - meanTX;
      final dy = ty[i] - meanTY;
      sumXX += dx * dx;
      sumYY += dy * dy;
      sumXY += dx * dy;
    }

    if (sumXX == 0) throw ArgumentError('All x values are identical; regression undefined');

    final b = sumXY / sumXX;
    final a = meanTY - b * meanTX;

    // Correlation coefficient.
    final r = (sumXX == 0 || sumYY == 0) ? 0.0 : sumXY / math.sqrt(sumXX * sumYY);

    // Compute means and sample std devs on the ORIGINAL data.
    final rawXs = data.map((d) => d.$1).toList();
    final rawYs = data.map((d) => d.$2).toList();
    final meanX = rawXs.reduce((a, b) => a + b) / n;
    final meanY = rawYs.reduce((a, b) => a + b) / n;

    final sX = _sampleStdDev(rawXs, meanX);
    final sY = _sampleStdDev(rawYs, meanY);

    // Convert intercept back for EXP and PWR models.
    final double reportedA;
    switch (model) {
      case RegressionModel.lin:
      case RegressionModel.ln:
        reportedA = a;
      case RegressionModel.exp:
      case RegressionModel.pwr:
        reportedA = math.exp(a);
    }

    return StatResult(
      n: n,
      meanX: meanX,
      meanY: meanY,
      sX: sX,
      sY: sY,
      a: reportedA,
      b: b,
      r: r,
    );
  }

  /// Predicts y for a given [x] using the regression [result] and [model].
  static double predict(double x, StatResult result, RegressionModel model) {
    switch (model) {
      case RegressionModel.lin:
        return result.a + result.b * x;
      case RegressionModel.ln:
        return result.a + result.b * math.log(x);
      case RegressionModel.exp:
        return result.a * math.exp(result.b * x);
      case RegressionModel.pwr:
        return result.a * math.pow(x, result.b);
    }
  }

  /// Predicts x for a given [y] (inverse prediction) using the regression
  /// [result] and [model].
  static double predictX(double y, StatResult result, RegressionModel model) {
    switch (model) {
      case RegressionModel.lin:
        if (result.b == 0) throw ArgumentError('Slope is zero; cannot solve for x');
        return (y - result.a) / result.b;
      case RegressionModel.ln:
        if (result.b == 0) throw ArgumentError('Slope is zero; cannot solve for x');
        return math.exp((y - result.a) / result.b);
      case RegressionModel.exp:
        if (result.a == 0) throw ArgumentError('Coefficient a is zero; cannot solve for x');
        if (y / result.a <= 0) throw ArgumentError('Cannot take log of non-positive value');
        if (result.b == 0) throw ArgumentError('Coefficient b is zero; cannot solve for x');
        return math.log(y / result.a) / result.b;
      case RegressionModel.pwr:
        if (result.a == 0) throw ArgumentError('Coefficient a is zero; cannot solve for x');
        if (y / result.a <= 0) throw ArgumentError('Cannot take log of non-positive value');
        if (result.b == 0) throw ArgumentError('Coefficient b is zero; cannot solve for x');
        return math.exp(math.log(y / result.a) / result.b);
    }
  }

  /// Sample standard deviation (n-1 denominator).
  static double _sampleStdDev(List<double> values, double mean) {
    if (values.length < 2) return 0.0;
    final sumSq = values.fold(0.0, (sum, v) => sum + (v - mean) * (v - mean));
    return math.sqrt(sumSq / (values.length - 1));
  }
}

/// Regression model types.
enum RegressionModel {
  /// Linear: y = a + bx
  lin,

  /// Logarithmic: y = a + b*ln(x)
  ln,

  /// Exponential: y = a*e^(bx)
  exp,

  /// Power: y = a*x^b
  pwr,
}

/// Result of a statistical regression computation.
class StatResult {
  /// Number of data points.
  final double n;

  /// Mean of x values.
  final double meanX;

  /// Mean of y values.
  final double meanY;

  /// Sample standard deviation of x values.
  final double sX;

  /// Sample standard deviation of y values.
  final double sY;

  /// Regression intercept (or coefficient for EXP/PWR models).
  final double a;

  /// Regression slope (or exponent for PWR model).
  final double b;

  /// Correlation coefficient.
  final double r;

  const StatResult({
    required this.n,
    required this.meanX,
    required this.meanY,
    required this.sX,
    required this.sY,
    required this.a,
    required this.b,
    required this.r,
  });

  @override
  String toString() =>
      'StatResult(n=$n, meanX=$meanX, meanY=$meanY, sX=$sX, sY=$sY, a=$a, b=$b, r=$r)';
}
