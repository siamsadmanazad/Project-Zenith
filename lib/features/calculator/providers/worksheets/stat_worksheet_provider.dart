import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../math_engine/statistics/statistics_engine.dart';

class StatWorksheetState {
  static const _unset = Object();

  final List<(double, double)> dataPoints;
  final RegressionModel model;
  final StatResult? result;
  final String? errorMessage;

  const StatWorksheetState({
    this.dataPoints = const [],
    this.model = RegressionModel.lin,
    this.result,
    this.errorMessage,
  });

  StatWorksheetState copyWith({
    List<(double, double)>? dataPoints,
    RegressionModel? model,
    Object? result = _unset,
    Object? errorMessage = _unset,
  }) {
    return StatWorksheetState(
      dataPoints: dataPoints ?? this.dataPoints,
      model: model ?? this.model,
      result: identical(result, _unset)
          ? this.result
          : result as StatResult?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class StatWorksheetNotifier extends StateNotifier<StatWorksheetState> {
  StatWorksheetNotifier() : super(const StatWorksheetState());

  void addDataPoint(double x, double y) {
    final pts = List<(double, double)>.from(state.dataPoints)..add((x, y));
    state = state.copyWith(dataPoints: pts, result: null);
  }

  void updateDataPoint(int index, double x, double y) {
    if (index < 0 || index >= state.dataPoints.length) return;
    final pts = List<(double, double)>.from(state.dataPoints);
    pts[index] = (x, y);
    state = state.copyWith(dataPoints: pts, result: null);
  }

  void deleteDataPoint(int index) {
    if (index < 0 || index >= state.dataPoints.length) return;
    final pts = List<(double, double)>.from(state.dataPoints)..removeAt(index);
    state = state.copyWith(dataPoints: pts, result: null);
  }

  void setModel(RegressionModel model) {
    state = state.copyWith(model: model, result: null);
  }

  void compute() {
    if (state.dataPoints.length < 2) {
      state = state.copyWith(errorMessage: 'Need at least 2 data points');
      return;
    }
    try {
      final result = StatisticsEngine.compute(state.dataPoints, state.model);
      state = state.copyWith(result: result, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: 'STAT Error: $e');
    }
  }

  void clear() {
    state = const StatWorksheetState();
  }
}

final statWorksheetProvider =
    StateNotifierProvider<StatWorksheetNotifier, StatWorksheetState>((ref) {
  return StatWorksheetNotifier();
});
