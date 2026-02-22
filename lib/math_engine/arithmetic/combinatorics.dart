/// Combinatorics functions for TI BA II Plus.
class Combinatorics {
  /// Factorial: n!
  /// Throws for negative or non-integer input.
  static double factorial(double x) {
    final n = x.round();
    if (n < 0) throw ArgumentError('Negative factorial');
    if (n > 170) throw ArgumentError('Overflow: $n!');
    if ((x - n).abs() > 1e-9) throw ArgumentError('Non-integer factorial');
    if (n <= 1) return 1;
    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  /// Permutation: nPr = n! / (n-r)!
  static double permutation(double nVal, double rVal) {
    final n = nVal.round();
    final r = rVal.round();
    if (r < 0 || r > n || n < 0) throw ArgumentError('Invalid nPr($n,$r)');
    double result = 1;
    for (int i = n; i > n - r; i--) {
      result *= i;
    }
    return result;
  }

  /// Combination: nCr = n! / (r!(n-r)!)
  static double combination(double nVal, double rVal) {
    final n = nVal.round();
    final r = rVal.round();
    if (r < 0 || r > n || n < 0) throw ArgumentError('Invalid nCr($n,$r)');
    // Use smaller of r and n-r for efficiency
    final k = r < n - r ? r : n - r;
    double result = 1;
    for (int i = 0; i < k; i++) {
      result = result * (n - i) / (i + 1);
    }
    return result;
  }
}
