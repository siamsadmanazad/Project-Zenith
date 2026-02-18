/// TVM Input Model
///
/// Represents the 5 variables in Time Value of Money calculations.
/// Users provide 4 values, and we solve for the 5th.
class TVMInput {
  final double? n;    // Number of periods
  final double? iy;   // Interest rate per year (as percentage, e.g. 6.5 for 6.5%)
  final double? pv;   // Present value (loan amount, investment)
  final double? pmt;  // Payment per period
  final double? fv;   // Future value

  // Payment timing: 0 = end of period (default), 1 = beginning
  final int pmtMode;

  // Payments per year (12 = monthly, 1 = annual)
  final int ppy;

  // Compounding periods per year (12 = monthly, 1 = annual)
  final int cpy;

  const TVMInput({
    this.n,
    this.iy,
    this.pv,
    this.pmt,
    this.fv,
    this.pmtMode = 0,  // Default: payments at end of period
    this.ppy = 12,     // Default: monthly payments
    this.cpy = 12,     // Default: monthly compounding
  });

  /// Checks if exactly 4 out of 5 TVM variables are provided
  bool isValid() {
    int providedCount = 0;
    if (n != null) providedCount++;
    if (iy != null) providedCount++;
    if (pv != null) providedCount++;
    if (pmt != null) providedCount++;
    if (fv != null) providedCount++;

    return providedCount == 4;
  }

  /// Returns which variable is missing (to be solved)
  String? getMissingVariable() {
    if (n == null) return 'N';
    if (iy == null) return 'I/Y';
    if (pv == null) return 'PV';
    if (pmt == null) return 'PMT';
    if (fv == null) return 'FV';
    return null;
  }

  /// Create a copy with updated values
  TVMInput copyWith({
    double? n,
    double? iy,
    double? pv,
    double? pmt,
    double? fv,
    int? pmtMode,
    int? ppy,
    int? cpy,
  }) {
    return TVMInput(
      n: n ?? this.n,
      iy: iy ?? this.iy,
      pv: pv ?? this.pv,
      pmt: pmt ?? this.pmt,
      fv: fv ?? this.fv,
      pmtMode: pmtMode ?? this.pmtMode,
      ppy: ppy ?? this.ppy,
      cpy: cpy ?? this.cpy,
    );
  }

  @override
  String toString() {
    return 'TVMInput(N: $n, I/Y: $iy%, PV: $pv, PMT: $pmt, FV: $fv, P/Y: $ppy, C/Y: $cpy)';
  }
}
