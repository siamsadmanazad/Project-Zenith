/// Depreciation methods: Straight-Line, Sum-of-Years-Digits, Declining Balance.
enum DepreciationMethod { sl, syd, db }

/// Result for a single year of depreciation.
class DepreciationResult {
  final double dep; // depreciation expense for the year
  final double rbv; // remaining book value
  final double rdv; // remaining depreciable value
  const DepreciationResult(this.dep, this.rbv, this.rdv);
}

class DepreciationEngine {
  /// Compute depreciation for a given [year] (1-based).
  ///
  /// [cost] — original cost of the asset.
  /// [salvage] — salvage value at end of life.
  /// [life] — useful life in years.
  /// [year] — the year to compute (1-based).
  /// [method] — depreciation method (sl, syd, db).
  /// [startMonth] — month the asset was placed in service (1–12).
  ///   When startMonth > 1, the first and last years are prorated.
  static DepreciationResult compute({
    required double cost,
    required double salvage,
    required double life,
    required int year,
    required DepreciationMethod method,
    int startMonth = 1,
  }) {
    switch (method) {
      case DepreciationMethod.sl:
        return _straightLine(cost, salvage, life, year, startMonth);
      case DepreciationMethod.syd:
        return _sumOfYearsDigits(cost, salvage, life, year, startMonth);
      case DepreciationMethod.db:
        return _decliningBalance(cost, salvage, life, year, startMonth);
    }
  }

  static DepreciationResult _straightLine(
    double cost,
    double salvage,
    double life,
    int year,
    int startMonth,
  ) {
    final depreciable = cost - salvage;
    final annualDep = depreciable / life;
    final fraction = (12 - startMonth + 1) / 12.0;

    // Total years including partial last year
    final totalYears = (startMonth == 1) ? life.toInt() : life.toInt() + 1;

    double dep;
    if (year < 1 || year > totalYears) {
      dep = 0;
    } else if (year == 1) {
      dep = annualDep * fraction;
    } else if (year == totalYears && startMonth > 1) {
      dep = annualDep * (1 - fraction);
    } else {
      dep = annualDep;
    }

    // Accumulate depreciation up to this year
    double accumulated = 0;
    for (int y = 1; y <= year && y <= totalYears; y++) {
      if (y == 1) {
        accumulated += annualDep * fraction;
      } else if (y == totalYears && startMonth > 1) {
        accumulated += annualDep * (1 - fraction);
      } else {
        accumulated += annualDep;
      }
    }

    final rbv = cost - accumulated;
    final rdv = rbv - salvage;
    return DepreciationResult(dep, rbv, rdv < 0 ? 0 : rdv);
  }

  static DepreciationResult _sumOfYearsDigits(
    double cost,
    double salvage,
    double life,
    int year,
    int startMonth,
  ) {
    final n = life.toInt();
    final depreciable = cost - salvage;
    final sumOfYears = n * (n + 1) / 2.0;
    final fraction = (12 - startMonth + 1) / 12.0;
    final totalYears = (startMonth == 1) ? n : n + 1;

    double dep;
    if (year < 1 || year > totalYears) {
      dep = 0;
    } else if (startMonth == 1) {
      // No proration: year k gets (n - k + 1) / sum
      final remaining = n - year + 1;
      dep = depreciable * remaining / sumOfYears;
    } else {
      // With proration: blend two SYD years
      if (year == 1) {
        final sydYear1 = depreciable * n / sumOfYears;
        dep = sydYear1 * fraction;
      } else if (year <= n) {
        final sydPrev = depreciable * (n - year + 2) / sumOfYears;
        final sydCurr = depreciable * (n - year + 1) / sumOfYears;
        dep = sydPrev * (1 - fraction) + sydCurr * fraction;
      } else {
        // Last partial year
        final sydLast = depreciable * 1 / sumOfYears;
        dep = sydLast * (1 - fraction);
      }
    }

    // Accumulate to find book value
    double accumulated = 0;
    for (int y = 1; y <= year && y <= totalYears; y++) {
      if (startMonth == 1) {
        final remaining = n - y + 1;
        accumulated += depreciable * remaining / sumOfYears;
      } else {
        if (y == 1) {
          accumulated += depreciable * n / sumOfYears * fraction;
        } else if (y <= n) {
          final sydPrev = depreciable * (n - y + 2) / sumOfYears;
          final sydCurr = depreciable * (n - y + 1) / sumOfYears;
          accumulated += sydPrev * (1 - fraction) + sydCurr * fraction;
        } else {
          accumulated += depreciable * 1 / sumOfYears * (1 - fraction);
        }
      }
    }

    final rbv = cost - accumulated;
    final rdv = rbv - salvage;
    return DepreciationResult(dep, rbv, rdv < 0 ? 0 : rdv);
  }

  static DepreciationResult _decliningBalance(
    double cost,
    double salvage,
    double life,
    int year,
    int startMonth,
  ) {
    // 200% declining balance with switch to straight-line
    final dbRate = 2.0 / life;
    final fraction = (12 - startMonth + 1) / 12.0;
    final n = life.toInt();
    final totalYears = (startMonth == 1) ? n : n + 1;

    double bookValue = cost;
    double dep = 0;

    for (int y = 1; y <= year && y <= totalYears; y++) {
      // Remaining depreciable value (cannot go below salvage)
      final remainingDep = bookValue - salvage;
      if (remainingDep <= 0) {
        dep = 0;
        break;
      }

      // DB depreciation for this year
      double dbDep = bookValue * dbRate;

      // Prorate first/last year
      if (y == 1 && startMonth > 1) {
        dbDep *= fraction;
      } else if (y == totalYears && startMonth > 1) {
        dbDep *= (1 - fraction);
      }

      // SL depreciation from this point forward
      final remainingYears = (startMonth == 1)
          ? (n - y + 1).toDouble()
          : (y == 1)
              ? life - fraction
              : (y == totalYears)
                  ? (1 - fraction)
                  : (totalYears - y + 1).toDouble() - (1 - fraction);
      final slDep = (remainingYears > 0) ? remainingDep / remainingYears : remainingDep;

      // Switch to SL when it gives a larger depreciation
      dep = (slDep > dbDep) ? slDep : dbDep;

      // Cannot depreciate below salvage
      if (dep > remainingDep) dep = remainingDep;

      bookValue -= dep;
    }

    final rbv = bookValue;
    final rdv = rbv - salvage;
    return DepreciationResult(dep, rbv, rdv < 0 ? 0 : rdv);
  }
}
