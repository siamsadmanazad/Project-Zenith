import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../math_engine/financial/bond_engine.dart';

class BondWorksheetState {
  static const _unset = Object();

  final DateTime? sdt; // settlement date
  final double cpn; // annual coupon rate %
  final DateTime? rdt; // redemption date
  final double rv; // redemption value (par = 100)
  final int freq; // coupon frequency: 1=annual, 2=semi-annual
  final int dayCount; // 0=ACT, 1=360
  final double? yld; // yield to maturity %
  final double? pri; // price
  final double? ai; // accrued interest
  final String? errorMessage;

  const BondWorksheetState({
    this.sdt,
    this.cpn = 0,
    this.rdt,
    this.rv = 100,
    this.freq = 2,
    this.dayCount = 0,
    this.yld,
    this.pri,
    this.ai,
    this.errorMessage,
  });

  BondWorksheetState copyWith({
    Object? sdt = _unset,
    double? cpn,
    Object? rdt = _unset,
    double? rv,
    int? freq,
    int? dayCount,
    Object? yld = _unset,
    Object? pri = _unset,
    Object? ai = _unset,
    Object? errorMessage = _unset,
  }) {
    return BondWorksheetState(
      sdt: identical(sdt, _unset) ? this.sdt : sdt as DateTime?,
      cpn: cpn ?? this.cpn,
      rdt: identical(rdt, _unset) ? this.rdt : rdt as DateTime?,
      rv: rv ?? this.rv,
      freq: freq ?? this.freq,
      dayCount: dayCount ?? this.dayCount,
      yld: identical(yld, _unset) ? this.yld : yld as double?,
      pri: identical(pri, _unset) ? this.pri : pri as double?,
      ai: identical(ai, _unset) ? this.ai : ai as double?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class BondWorksheetNotifier extends StateNotifier<BondWorksheetState> {
  BondWorksheetNotifier() : super(const BondWorksheetState());

  void setSdt(DateTime? v) => state = state.copyWith(sdt: v);
  void setCpn(double v) => state = state.copyWith(cpn: v);
  void setRdt(DateTime? v) => state = state.copyWith(rdt: v);
  void setRv(double v) => state = state.copyWith(rv: v);
  void setFreq(int v) => state = state.copyWith(freq: v);
  void setDayCount(int v) => state = state.copyWith(dayCount: v);
  void setYld(double v) => state = state.copyWith(yld: v);
  void setPri(double v) => state = state.copyWith(pri: v);

  void computePrice() {
    if (state.yld == null) {
      state = state.copyWith(errorMessage: 'Enter yield first');
      return;
    }
    try {
      final periods = _estimatePeriods();
      final result = BondEngine.price(
        coupon: state.cpn,
        yield_: state.yld!,
        redemption: state.rv,
        frequency: state.freq,
        periodsRemaining: periods,
      );
      state = state.copyWith(pri: result, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Price Error: $e');
    }
  }

  void computeYield() {
    if (state.pri == null) {
      state = state.copyWith(errorMessage: 'Enter price first');
      return;
    }
    try {
      final periods = _estimatePeriods();
      final result = BondEngine.yield_(
        coupon: state.cpn,
        price: state.pri!,
        redemption: state.rv,
        frequency: state.freq,
        periodsRemaining: periods,
      );
      state = state.copyWith(yld: result, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Yield Error: $e');
    }
  }

  int _estimatePeriods() {
    if (state.sdt != null && state.rdt != null) {
      final days = state.rdt!.difference(state.sdt!).inDays;
      final years = days / 365.25;
      return (years * state.freq).round().clamp(1, 999);
    }
    return 20; // default
  }

  void clear() {
    state = const BondWorksheetState();
  }
}

final bondWorksheetProvider =
    StateNotifierProvider<BondWorksheetNotifier, BondWorksheetState>((ref) {
  return BondWorksheetNotifier();
});
