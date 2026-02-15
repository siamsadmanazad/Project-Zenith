import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../math_engine/tvm/tvm_input.dart';
import '../../../math_engine/tvm/tvm_solver.dart';

/// Calculator State - Tracks user inputs and results
class CalculatorState {
  final double? n;
  final double? iy;
  final double? pv;
  final double? pmt;
  final double? fv;
  final double? result;
  final String? resultLabel; // e.g., "Monthly Payment"
  final String? errorMessage;

  const CalculatorState({
    this.n,
    this.iy,
    this.pv,
    this.pmt,
    this.fv,
    this.result,
    this.resultLabel,
    this.errorMessage,
  });

  /// Create a copy with updated values
  CalculatorState copyWith({
    double? n,
    double? iy,
    double? pv,
    double? pmt,
    double? fv,
    double? result,
    String? resultLabel,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return CalculatorState(
      n: n ?? this.n,
      iy: iy ?? this.iy,
      pv: pv ?? this.pv,
      pmt: pmt ?? this.pmt,
      fv: fv ?? this.fv,
      result: clearResult ? null : (result ?? this.result),
      resultLabel: clearResult ? null : (resultLabel ?? this.resultLabel),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Check how many variables are filled
  int get filledCount {
    int count = 0;
    if (n != null) count++;
    if (iy != null) count++;
    if (pv != null) count++;
    if (pmt != null) count++;
    if (fv != null) count++;
    return count;
  }

  /// Check if ready to calculate (exactly 4 variables)
  bool get canCalculate => filledCount == 4;

  /// Get which variable is missing
  String? get missingVariable {
    if (n == null) return 'N';
    if (iy == null) return 'I/Y';
    if (pv == null) return 'PV';
    if (pmt == null) return 'PMT';
    if (fv == null) return 'FV';
    return null;
  }
}

/// Calculator Provider - Manages calculator state
class CalculatorNotifier extends StateNotifier<CalculatorState> {
  CalculatorNotifier() : super(const CalculatorState());

  /// Update a specific field
  void updateField(String field, double? value) {
    switch (field) {
      case 'N':
        state = state.copyWith(n: value, clearResult: true, clearError: true);
        break;
      case 'I/Y':
        state = state.copyWith(iy: value, clearResult: true, clearError: true);
        break;
      case 'PV':
        state = state.copyWith(pv: value, clearResult: true, clearError: true);
        break;
      case 'PMT':
        state = state.copyWith(pmt: value, clearResult: true, clearError: true);
        break;
      case 'FV':
        state = state.copyWith(fv: value, clearResult: true, clearError: true);
        break;
    }
  }

  /// Calculate the missing variable
  void calculate() {
    if (!state.canCalculate) {
      state = state.copyWith(
        errorMessage: 'Please fill in exactly 4 values',
        clearResult: true,
      );
      return;
    }

    try {
      final input = TVMInput(
        n: state.n,
        iy: state.iy,
        pv: state.pv,
        pmt: state.pmt,
        fv: state.fv,
      );

      final result = TVMSolver.solve(input);
      final missing = state.missingVariable;

      // Determine the result label
      String label = _getResultLabel(missing);

      state = state.copyWith(
        result: result,
        resultLabel: label,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Calculation error: ${e.toString()}',
        clearResult: true,
      );
    }
  }

  /// Get human-readable label for the result
  String _getResultLabel(String? variable) {
    switch (variable) {
      case 'N':
        return 'Number of Periods';
      case 'I/Y':
        return 'Interest Rate';
      case 'PV':
        return 'Present Value';
      case 'PMT':
        return 'Payment';
      case 'FV':
        return 'Future Value';
      default:
        return 'Result';
    }
  }

  /// Clear all fields
  void clear() {
    state = const CalculatorState();
  }
}

/// Provider instance - This is what we'll use in the UI
final calculatorProvider =
    StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  return CalculatorNotifier();
});
