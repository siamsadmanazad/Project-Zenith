/// Break-even analysis engine.
///
/// Relationship: PFT = Q * (P - VC) - FC
/// Given any 4 of the 5 variables, solves for the remaining one.
class BreakevenEngine {
  /// Solves for the [target] variable given the other four.
  ///
  /// Throws [ArgumentError] if required inputs are missing.
  /// Throws [ArgumentError] on division by zero.
  static double solve(
    BreakevenVariable target, {
    double? q,
    double? p,
    double? fc,
    double? vc,
    double? pft,
  }) {
    switch (target) {
      case BreakevenVariable.quantity:
        // Q = (PFT + FC) / (P - VC)
        _requireAll({'price': p, 'fixedCost': fc, 'variableCost': vc, 'profit': pft});
        final denom = p! - vc!;
        if (denom == 0) throw ArgumentError('Price equals variable cost; cannot solve for quantity');
        return (pft! + fc!) / denom;

      case BreakevenVariable.price:
        // P = (PFT + FC) / Q + VC
        _requireAll({'quantity': q, 'fixedCost': fc, 'variableCost': vc, 'profit': pft});
        if (q! == 0) throw ArgumentError('Quantity is zero; cannot solve for price');
        return (pft! + fc!) / q + vc!;

      case BreakevenVariable.fixedCost:
        // FC = Q * (P - VC) - PFT
        _requireAll({'quantity': q, 'price': p, 'variableCost': vc, 'profit': pft});
        return q! * (p! - vc!) - pft!;

      case BreakevenVariable.variableCost:
        // VC = P - (PFT + FC) / Q
        _requireAll({'quantity': q, 'price': p, 'fixedCost': fc, 'profit': pft});
        if (q! == 0) throw ArgumentError('Quantity is zero; cannot solve for variable cost');
        return p! - (pft! + fc!) / q;

      case BreakevenVariable.profit:
        // PFT = Q * (P - VC) - FC
        _requireAll({'quantity': q, 'price': p, 'fixedCost': fc, 'variableCost': vc});
        return q! * (p! - vc!) - fc!;
    }
  }

  /// Break-even quantity (profit = 0): Q_be = FC / (P - VC).
  static double breakevenQuantity({
    required double p,
    required double fc,
    required double vc,
  }) {
    final denom = p - vc;
    if (denom == 0) throw ArgumentError('Price equals variable cost; no break-even point');
    return fc / denom;
  }

  static void _requireAll(Map<String, double?> params) {
    for (final entry in params.entries) {
      if (entry.value == null) {
        throw ArgumentError('Missing required parameter: ${entry.key}');
      }
    }
  }
}

/// Variables in the break-even relationship.
enum BreakevenVariable {
  quantity,
  price,
  fixedCost,
  variableCost,
  profit,
}
