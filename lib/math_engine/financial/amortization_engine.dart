/// Amortization schedule computation for periods P1 to P2.
class AmortResult {
  final double bal; // remaining balance after P2
  final double prn; // total principal paid over P1..P2
  final double int_; // total interest paid over P1..P2
  const AmortResult(this.bal, this.prn, this.int_);
}

class AmortizationEngine {
  /// Compute amortization results for periods [p1] to [p2].
  ///
  /// [pv] — present value (loan amount, positive).
  /// [pmt] — payment per period (negative for outflows).
  /// [annualRate] — annual interest rate as a percentage (e.g. 6 for 6%).
  /// [ppy] — payments per year.
  /// [p1], [p2] — period range (1-based, inclusive).
  /// [pmtMode] — 0 = END, 1 = BGN.
  static AmortResult amortize({
    required double pv,
    required double pmt,
    required double annualRate,
    required int ppy,
    required int p1,
    required int p2,
    required int pmtMode,
  }) {
    final rate = annualRate / 100.0 / ppy;
    double balance = pv;
    double totalPrn = 0;
    double totalInt = 0;

    for (int period = 1; period <= p2; period++) {
      double interestPortion;
      double principalPortion;

      if (pmtMode == 1) {
        // BGN: payment is made at the beginning of the period,
        // so principal is applied first, then interest accrues on the rest.
        principalPortion = pmt + balance * rate / (1 + rate);
        interestPortion = pmt - principalPortion;
      } else {
        // END: interest accrues first, then payment is applied.
        interestPortion = balance * rate;
        principalPortion = pmt - interestPortion;
      }

      balance += principalPortion;

      if (period >= p1) {
        totalPrn += principalPortion;
        totalInt += interestPortion;
      }
    }

    return AmortResult(balance, totalPrn, totalInt);
  }
}
