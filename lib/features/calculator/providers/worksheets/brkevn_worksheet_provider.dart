import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../math_engine/financial/breakeven_engine.dart';

class BrkevnWorksheetState {
  static const _unset = Object();

  final double? fc; // fixed cost
  final double? vc; // variable cost per unit
  final double? price;
  final double? profit;
  final double? quantity;
  final String? errorMessage;

  const BrkevnWorksheetState({
    this.fc,
    this.vc,
    this.price,
    this.profit,
    this.quantity,
    this.errorMessage,
  });

  BrkevnWorksheetState copyWith({
    Object? fc = _unset,
    Object? vc = _unset,
    Object? price = _unset,
    Object? profit = _unset,
    Object? quantity = _unset,
    Object? errorMessage = _unset,
  }) {
    return BrkevnWorksheetState(
      fc: identical(fc, _unset) ? this.fc : fc as double?,
      vc: identical(vc, _unset) ? this.vc : vc as double?,
      price: identical(price, _unset) ? this.price : price as double?,
      profit: identical(profit, _unset) ? this.profit : profit as double?,
      quantity: identical(quantity, _unset) ? this.quantity : quantity as double?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class BrkevnWorksheetNotifier extends StateNotifier<BrkevnWorksheetState> {
  BrkevnWorksheetNotifier() : super(const BrkevnWorksheetState());

  void setFc(double? v) => state = state.copyWith(fc: v);
  void setVc(double? v) => state = state.copyWith(vc: v);
  void setPrice(double? v) => state = state.copyWith(price: v);
  void setProfit(double? v) => state = state.copyWith(profit: v);
  void setQuantity(double? v) => state = state.copyWith(quantity: v);

  void solve(BreakevenVariable target) {
    try {
      final result = BreakevenEngine.solve(
        target,
        q: state.quantity,
        p: state.price,
        fc: state.fc,
        vc: state.vc,
        pft: state.profit,
      );
      switch (target) {
        case BreakevenVariable.quantity:
          state = state.copyWith(quantity: result, errorMessage: null);
        case BreakevenVariable.price:
          state = state.copyWith(price: result, errorMessage: null);
        case BreakevenVariable.fixedCost:
          state = state.copyWith(fc: result, errorMessage: null);
        case BreakevenVariable.variableCost:
          state = state.copyWith(vc: result, errorMessage: null);
        case BreakevenVariable.profit:
          state = state.copyWith(profit: result, errorMessage: null);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'BRKEVN Error: $e');
    }
  }

  void clear() {
    state = const BrkevnWorksheetState();
  }
}

final brkevnWorksheetProvider =
    StateNotifierProvider<BrkevnWorksheetNotifier, BrkevnWorksheetState>((ref) {
  return BrkevnWorksheetNotifier();
});
