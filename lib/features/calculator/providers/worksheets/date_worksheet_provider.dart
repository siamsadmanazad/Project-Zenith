import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../math_engine/financial/date_engine.dart';

class DateWorksheetState {
  static const _unset = Object();

  final DateTime? date1;
  final DateTime? date2;
  final int? daysBetween;
  final DayCountMethod dayCount;
  final DateTime? resultDate; // for date ± days
  final int addDaysValue; // days to add/subtract
  final String? errorMessage;

  const DateWorksheetState({
    this.date1,
    this.date2,
    this.daysBetween,
    this.dayCount = DayCountMethod.actual,
    this.resultDate,
    this.addDaysValue = 0,
    this.errorMessage,
  });

  DateWorksheetState copyWith({
    Object? date1 = _unset,
    Object? date2 = _unset,
    Object? daysBetween = _unset,
    DayCountMethod? dayCount,
    Object? resultDate = _unset,
    int? addDaysValue,
    Object? errorMessage = _unset,
  }) {
    return DateWorksheetState(
      date1: identical(date1, _unset) ? this.date1 : date1 as DateTime?,
      date2: identical(date2, _unset) ? this.date2 : date2 as DateTime?,
      daysBetween: identical(daysBetween, _unset)
          ? this.daysBetween
          : daysBetween as int?,
      dayCount: dayCount ?? this.dayCount,
      resultDate: identical(resultDate, _unset)
          ? this.resultDate
          : resultDate as DateTime?,
      addDaysValue: addDaysValue ?? this.addDaysValue,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class DateWorksheetNotifier extends StateNotifier<DateWorksheetState> {
  DateWorksheetNotifier() : super(const DateWorksheetState());

  void setDate1(DateTime? v) => state = state.copyWith(date1: v, daysBetween: null);
  void setDate2(DateTime? v) => state = state.copyWith(date2: v, daysBetween: null);
  void setDayCount(DayCountMethod v) => state = state.copyWith(dayCount: v, daysBetween: null);
  void setAddDaysValue(int v) => state = state.copyWith(addDaysValue: v);

  void computeDaysBetween() {
    if (state.date1 == null || state.date2 == null) {
      state = state.copyWith(errorMessage: 'Enter both dates');
      return;
    }
    try {
      final days = DateEngine.daysBetween(state.date1!, state.date2!, state.dayCount);
      state = state.copyWith(daysBetween: days, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Date Error: $e');
    }
  }

  void computeAddDays() {
    if (state.date1 == null) {
      state = state.copyWith(errorMessage: 'Enter DT1 first');
      return;
    }
    final result = DateEngine.addDays(state.date1!, state.addDaysValue);
    state = state.copyWith(resultDate: result, errorMessage: null);
  }

  void clear() {
    state = const DateWorksheetState();
  }
}

final dateWorksheetProvider =
    StateNotifierProvider<DateWorksheetNotifier, DateWorksheetState>((ref) {
  return DateWorksheetNotifier();
});
