import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../math_engine/financial/cash_flow_engine.dart';

class CfWorksheetState {
  static const _unset = Object();

  final List<CashFlowEntry> cashFlows; // CF0, CF1, CF2, ...
  final int currentIndex;
  final double iRate; // discount rate for NPV
  final double? npvResult;
  final double? irrResult;
  final String? errorMessage;

  const CfWorksheetState({
    this.cashFlows = const [],
    this.currentIndex = 0,
    this.iRate = 0,
    this.npvResult,
    this.irrResult,
    this.errorMessage,
  });

  CfWorksheetState copyWith({
    List<CashFlowEntry>? cashFlows,
    int? currentIndex,
    double? iRate,
    Object? npvResult = _unset,
    Object? irrResult = _unset,
    Object? errorMessage = _unset,
  }) {
    return CfWorksheetState(
      cashFlows: cashFlows ?? this.cashFlows,
      currentIndex: currentIndex ?? this.currentIndex,
      iRate: iRate ?? this.iRate,
      npvResult: identical(npvResult, _unset)
          ? this.npvResult
          : npvResult as double?,
      irrResult: identical(irrResult, _unset)
          ? this.irrResult
          : irrResult as double?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class CfWorksheetNotifier extends StateNotifier<CfWorksheetState> {
  CfWorksheetNotifier() : super(const CfWorksheetState());

  void setCashFlows(List<CashFlowEntry> flows) {
    state = state.copyWith(cashFlows: flows, npvResult: null, irrResult: null);
  }

  void addCashFlow(double amount, [int frequency = 1]) {
    final flows = List<CashFlowEntry>.from(state.cashFlows)
      ..add(CashFlowEntry(amount, frequency));
    state = state.copyWith(cashFlows: flows, npvResult: null, irrResult: null);
  }

  void updateCashFlow(int index, double amount, int frequency) {
    if (index < 0 || index >= state.cashFlows.length) return;
    final flows = List<CashFlowEntry>.from(state.cashFlows);
    flows[index] = CashFlowEntry(amount, frequency);
    state = state.copyWith(cashFlows: flows, npvResult: null, irrResult: null);
  }

  void deleteCashFlow(int index) {
    if (index < 0 || index >= state.cashFlows.length) return;
    final flows = List<CashFlowEntry>.from(state.cashFlows)..removeAt(index);
    state = state.copyWith(
      cashFlows: flows,
      currentIndex: state.currentIndex.clamp(0, flows.length - 1),
      npvResult: null,
      irrResult: null,
    );
  }

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void setIRate(double rate) {
    state = state.copyWith(iRate: rate, npvResult: null);
  }

  void computeNpv() {
    if (state.cashFlows.isEmpty) {
      state = state.copyWith(errorMessage: 'Enter cash flows first');
      return;
    }
    try {
      final result = CashFlowEngine.npv(state.cashFlows, state.iRate);
      state = state.copyWith(npvResult: result, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: 'NPV Error: $e');
    }
  }

  void computeIrr() {
    if (state.cashFlows.isEmpty) {
      state = state.copyWith(errorMessage: 'Enter cash flows first');
      return;
    }
    try {
      final result = CashFlowEngine.irr(state.cashFlows);
      state = state.copyWith(irrResult: result, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: 'IRR Error: $e');
    }
  }

  void clear() {
    state = const CfWorksheetState();
  }
}

final cfWorksheetProvider =
    StateNotifierProvider<CfWorksheetNotifier, CfWorksheetState>((ref) {
  return CfWorksheetNotifier();
});
