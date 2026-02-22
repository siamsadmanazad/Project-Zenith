import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../math_engine/financial/amortization_engine.dart';

class AmortWorksheetState {
  static const _unset = Object();

  final int p1;
  final int p2;
  final double? balResult;
  final double? prnResult;
  final double? intResult;
  final String? errorMessage;

  const AmortWorksheetState({
    this.p1 = 1,
    this.p2 = 12,
    this.balResult,
    this.prnResult,
    this.intResult,
    this.errorMessage,
  });

  AmortWorksheetState copyWith({
    int? p1,
    int? p2,
    Object? balResult = _unset,
    Object? prnResult = _unset,
    Object? intResult = _unset,
    Object? errorMessage = _unset,
  }) {
    return AmortWorksheetState(
      p1: p1 ?? this.p1,
      p2: p2 ?? this.p2,
      balResult: identical(balResult, _unset)
          ? this.balResult
          : balResult as double?,
      prnResult: identical(prnResult, _unset)
          ? this.prnResult
          : prnResult as double?,
      intResult: identical(intResult, _unset)
          ? this.intResult
          : intResult as double?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class AmortWorksheetNotifier extends StateNotifier<AmortWorksheetState> {
  AmortWorksheetNotifier() : super(const AmortWorksheetState());

  void setP1(int v) => state = state.copyWith(p1: v, balResult: null, prnResult: null, intResult: null);
  void setP2(int v) => state = state.copyWith(p2: v, balResult: null, prnResult: null, intResult: null);

  void compute({
    required double pv,
    required double pmt,
    required double annualRate,
    required int ppy,
    required int pmtMode,
  }) {
    try {
      final result = AmortizationEngine.amortize(
        pv: pv,
        pmt: pmt,
        annualRate: annualRate,
        ppy: ppy,
        p1: state.p1,
        p2: state.p2,
        pmtMode: pmtMode,
      );
      state = state.copyWith(
        balResult: result.bal,
        prnResult: result.prn,
        intResult: result.int_,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'AMORT Error: $e');
    }
  }

  void clear() {
    state = const AmortWorksheetState();
  }
}

final amortWorksheetProvider =
    StateNotifierProvider<AmortWorksheetNotifier, AmortWorksheetState>((ref) {
  return AmortWorksheetNotifier();
});
