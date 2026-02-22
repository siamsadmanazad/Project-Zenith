import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../math_engine/financial/profit_engine.dart';

class ProfitWorksheetState {
  static const _unset = Object();

  final double? cost;
  final double? selling;
  final double? margin; // as percentage
  final double? markupResult; // computed markup %
  final String? errorMessage;

  const ProfitWorksheetState({
    this.cost,
    this.selling,
    this.margin,
    this.markupResult,
    this.errorMessage,
  });

  ProfitWorksheetState copyWith({
    Object? cost = _unset,
    Object? selling = _unset,
    Object? margin = _unset,
    Object? markupResult = _unset,
    Object? errorMessage = _unset,
  }) {
    return ProfitWorksheetState(
      cost: identical(cost, _unset) ? this.cost : cost as double?,
      selling: identical(selling, _unset) ? this.selling : selling as double?,
      margin: identical(margin, _unset) ? this.margin : margin as double?,
      markupResult: identical(markupResult, _unset)
          ? this.markupResult
          : markupResult as double?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class ProfitWorksheetNotifier extends StateNotifier<ProfitWorksheetState> {
  ProfitWorksheetNotifier() : super(const ProfitWorksheetState());

  void setCost(double? v) => state = state.copyWith(cost: v);
  void setSelling(double? v) => state = state.copyWith(selling: v);
  void setMargin(double? v) => state = state.copyWith(margin: v);

  void solve(ProfitVariable target) {
    try {
      final result = ProfitEngine.solve(
        target,
        cost: state.cost,
        selling: state.selling,
        margin: state.margin,
      );
      double? markup;
      switch (target) {
        case ProfitVariable.cost:
          final c = result;
          final s = state.selling;
          if (s != null && c != 0) markup = ProfitEngine.markup(c, s);
          state = state.copyWith(cost: result, markupResult: markup, errorMessage: null);
        case ProfitVariable.selling:
          final c = state.cost;
          final s = result;
          if (c != null && c != 0) markup = ProfitEngine.markup(c, s);
          state = state.copyWith(selling: result, markupResult: markup, errorMessage: null);
        case ProfitVariable.margin:
          final c = state.cost;
          final s = state.selling;
          if (c != null && s != null && c != 0) markup = ProfitEngine.markup(c, s);
          state = state.copyWith(margin: result, markupResult: markup, errorMessage: null);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'PROFIT Error: $e');
    }
  }

  void clear() {
    state = const ProfitWorksheetState();
  }
}

final profitWorksheetProvider =
    StateNotifierProvider<ProfitWorksheetNotifier, ProfitWorksheetState>((ref) {
  return ProfitWorksheetNotifier();
});
