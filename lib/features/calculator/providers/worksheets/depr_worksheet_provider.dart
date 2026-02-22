import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../math_engine/financial/depreciation_engine.dart';

class DeprWorksheetState {
  static const _unset = Object();

  final double cost;
  final double salvage;
  final double life;
  final int startMonth; // 1-12
  final int year;
  final DepreciationMethod method;
  final double? dep;
  final double? rbv; // remaining book value
  final double? rdv; // remaining depreciable value
  final String? errorMessage;

  const DeprWorksheetState({
    this.cost = 0,
    this.salvage = 0,
    this.life = 0,
    this.startMonth = 1,
    this.year = 1,
    this.method = DepreciationMethod.sl,
    this.dep,
    this.rbv,
    this.rdv,
    this.errorMessage,
  });

  DeprWorksheetState copyWith({
    double? cost,
    double? salvage,
    double? life,
    int? startMonth,
    int? year,
    DepreciationMethod? method,
    Object? dep = _unset,
    Object? rbv = _unset,
    Object? rdv = _unset,
    Object? errorMessage = _unset,
  }) {
    return DeprWorksheetState(
      cost: cost ?? this.cost,
      salvage: salvage ?? this.salvage,
      life: life ?? this.life,
      startMonth: startMonth ?? this.startMonth,
      year: year ?? this.year,
      method: method ?? this.method,
      dep: identical(dep, _unset) ? this.dep : dep as double?,
      rbv: identical(rbv, _unset) ? this.rbv : rbv as double?,
      rdv: identical(rdv, _unset) ? this.rdv : rdv as double?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class DeprWorksheetNotifier extends StateNotifier<DeprWorksheetState> {
  DeprWorksheetNotifier() : super(const DeprWorksheetState());

  void setCost(double v) => state = state.copyWith(cost: v, dep: null, rbv: null, rdv: null);
  void setSalvage(double v) => state = state.copyWith(salvage: v, dep: null, rbv: null, rdv: null);
  void setLife(double v) => state = state.copyWith(life: v, dep: null, rbv: null, rdv: null);
  void setStartMonth(int v) => state = state.copyWith(startMonth: v, dep: null, rbv: null, rdv: null);
  void setYear(int v) => state = state.copyWith(year: v, dep: null, rbv: null, rdv: null);
  void setMethod(DepreciationMethod v) => state = state.copyWith(method: v, dep: null, rbv: null, rdv: null);

  void compute() {
    try {
      final result = DepreciationEngine.compute(
        cost: state.cost,
        salvage: state.salvage,
        life: state.life,
        year: state.year,
        method: state.method,
        startMonth: state.startMonth,
      );
      state = state.copyWith(
        dep: result.dep,
        rbv: result.rbv,
        rdv: result.rdv,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'DEPR Error: $e');
    }
  }

  void clear() {
    state = const DeprWorksheetState();
  }
}

final deprWorksheetProvider =
    StateNotifierProvider<DeprWorksheetNotifier, DeprWorksheetState>((ref) {
  return DeprWorksheetNotifier();
});
