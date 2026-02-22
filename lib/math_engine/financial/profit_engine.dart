/// Profit margin and markup calculations.
///
/// Margin relationship: margin = (selling - cost) / selling * 100
/// Given any 2 of cost / selling / margin, computes the 3rd.
class ProfitEngine {
  /// Solves for the [target] variable given the other two.
  ///
  /// [margin] is a percentage (e.g. 25 for 25%).
  /// Throws [ArgumentError] if required inputs are missing or on division by zero.
  static double solve(
    ProfitVariable target, {
    double? cost,
    double? selling,
    double? margin,
  }) {
    switch (target) {
      case ProfitVariable.cost:
        // cost = selling * (1 - margin/100)
        _require('selling', selling);
        _require('margin', margin);
        return selling! * (1 - margin! / 100);

      case ProfitVariable.selling:
        // selling = cost / (1 - margin/100)
        _require('cost', cost);
        _require('margin', margin);
        final denom = 1 - margin! / 100;
        if (denom == 0) throw ArgumentError('Margin of 100% implies zero cost; cannot solve for selling price');
        return cost! / denom;

      case ProfitVariable.margin:
        // margin = (selling - cost) / selling * 100
        _require('cost', cost);
        _require('selling', selling);
        if (selling! == 0) throw ArgumentError('Selling price is zero; cannot compute margin');
        return (selling - cost!) / selling * 100;
    }
  }

  /// Returns the markup percentage: (selling - cost) / cost * 100.
  ///
  /// Throws [ArgumentError] if [cost] is zero.
  static double markup(double cost, double selling) {
    if (cost == 0) throw ArgumentError('Cost is zero; cannot compute markup');
    return (selling - cost) / cost * 100;
  }

  static void _require(String name, double? value) {
    if (value == null) {
      throw ArgumentError('Missing required parameter: $name');
    }
  }
}

/// Variables in the profit margin relationship.
enum ProfitVariable {
  cost,
  selling,
  margin,
}
