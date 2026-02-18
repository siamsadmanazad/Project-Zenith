import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../math_engine/tvm/tvm_input.dart';
import '../../../math_engine/tvm/tvm_solver.dart';

/// Calculator State - Tracks user inputs, keypad buffer, and results
class CalculatorState {
  static const _unset = Object();

  final double? n;
  final double? iy;
  final double? pv;
  final double? pmt;
  final double? fv;
  final int pmtMode; // 0 = end of period (ordinary), 1 = beginning (annuity-due)
  final int ppy; // Payments per year
  final int cpy; // Compounding periods per year
  final double? result;
  final String? resultLabel; // e.g., "Monthly Payment"
  final String? errorMessage;

  // Keypad-specific state
  final String displayBuffer; // Current digit entry, e.g. "50000"
  final String? activeVariable; // Last stored: "PV", "N", etc.
  final bool cptMode; // true after CPT pressed, awaiting target
  final String? statusMessage; // Flash feedback, e.g. "PV = 500,000.00"

  const CalculatorState({
    this.n,
    this.iy,
    this.pv,
    this.pmt,
    this.fv,
    this.pmtMode = 0,
    this.ppy = 12,
    this.cpy = 12,
    this.result,
    this.resultLabel,
    this.errorMessage,
    this.displayBuffer = '',
    this.activeVariable,
    this.cptMode = false,
    this.statusMessage,
  });

  /// Create a copy with updated values
  /// Uses sentinel pattern so passing null explicitly clears a field.
  CalculatorState copyWith({
    Object? n = _unset,
    Object? iy = _unset,
    Object? pv = _unset,
    Object? pmt = _unset,
    Object? fv = _unset,
    int? pmtMode,
    int? ppy,
    int? cpy,
    Object? result = _unset,
    Object? resultLabel = _unset,
    Object? errorMessage = _unset,
    bool clearResult = false,
    bool clearError = false,
    String? displayBuffer,
    Object? activeVariable = _unset,
    bool? cptMode,
    Object? statusMessage = _unset,
  }) {
    return CalculatorState(
      n: identical(n, _unset) ? this.n : n as double?,
      iy: identical(iy, _unset) ? this.iy : iy as double?,
      pv: identical(pv, _unset) ? this.pv : pv as double?,
      pmt: identical(pmt, _unset) ? this.pmt : pmt as double?,
      fv: identical(fv, _unset) ? this.fv : fv as double?,
      pmtMode: pmtMode ?? this.pmtMode,
      ppy: ppy ?? this.ppy,
      cpy: cpy ?? this.cpy,
      result: clearResult ? null : (identical(result, _unset) ? this.result : result as double?),
      resultLabel: clearResult ? null : (identical(resultLabel, _unset) ? this.resultLabel : resultLabel as String?),
      errorMessage: clearError ? null : (identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?),
      displayBuffer: displayBuffer ?? this.displayBuffer,
      activeVariable: identical(activeVariable, _unset) ? this.activeVariable : activeVariable as String?,
      cptMode: cptMode ?? this.cptMode,
      statusMessage: identical(statusMessage, _unset) ? this.statusMessage : statusMessage as String?,
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

  /// Get the value of a variable by name
  double? getVariable(String variable) {
    switch (variable) {
      case 'N': return n;
      case 'I/Y': return iy;
      case 'PV': return pv;
      case 'PMT': return pmt;
      case 'FV': return fv;
      default: return null;
    }
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

  /// Update payment timing mode
  void updatePmtMode(int mode) {
    state = state.copyWith(pmtMode: mode, clearResult: true, clearError: true);
  }

  /// Update payments per year
  void updatePpy(int ppy) {
    state = state.copyWith(ppy: ppy, clearResult: true, clearError: true);
  }

  /// Update compounding periods per year
  void updateCpy(int cpy) {
    state = state.copyWith(cpy: cpy, clearResult: true, clearError: true);
  }

  // ========== KEYPAD METHODS ==========

  /// Append a digit to the display buffer
  void appendDigit(String digit) {
    // Limit buffer length to prevent overflow
    if (state.displayBuffer.replaceAll('-', '').replaceAll('.', '').length >= 12) return;
    state = state.copyWith(
      displayBuffer: state.displayBuffer + digit,
      clearError: true,
      statusMessage: null,
    );
  }

  /// Append decimal point
  void appendDecimal() {
    if (state.displayBuffer.contains('.')) return;
    final buffer = state.displayBuffer.isEmpty ? '0.' : '${state.displayBuffer}.';
    state = state.copyWith(
      displayBuffer: buffer,
      clearError: true,
      statusMessage: null,
    );
  }

  /// Toggle sign (+/-)
  void toggleSign() {
    if (state.displayBuffer.isEmpty) return;
    if (state.displayBuffer.startsWith('-')) {
      state = state.copyWith(displayBuffer: state.displayBuffer.substring(1));
    } else {
      state = state.copyWith(displayBuffer: '-${state.displayBuffer}');
    }
  }

  /// Backspace — remove last character
  void backspace() {
    if (state.displayBuffer.isEmpty) return;
    state = state.copyWith(
      displayBuffer: state.displayBuffer.substring(0, state.displayBuffer.length - 1),
    );
  }

  /// Store the current buffer value into a TVM variable
  void storeTVMVariable(String variable) {
    final buffer = state.displayBuffer;
    if (buffer.isEmpty) {
      // If buffer is empty, just show the current value
      final currentValue = state.getVariable(variable);
      if (currentValue != null) {
        state = state.copyWith(
          activeVariable: variable,
          statusMessage: '$variable = ${currentValue.toStringAsFixed(2)}',
          cptMode: false,
        );
      } else {
        state = state.copyWith(
          activeVariable: variable,
          statusMessage: '$variable = 0.00',
          cptMode: false,
        );
      }
      return;
    }

    final value = double.tryParse(buffer);
    if (value == null) {
      state = state.copyWith(
        errorMessage: 'Invalid number',
        clearResult: true,
      );
      return;
    }

    // Store the value
    switch (variable) {
      case 'N':
        state = state.copyWith(
          n: value,
          displayBuffer: '',
          activeVariable: variable,
          statusMessage: 'N = ${value.toStringAsFixed(2)}',
          cptMode: false,
          clearResult: true,
          clearError: true,
        );
        break;
      case 'I/Y':
        state = state.copyWith(
          iy: value,
          displayBuffer: '',
          activeVariable: variable,
          statusMessage: 'I/Y = ${value.toStringAsFixed(2)}',
          cptMode: false,
          clearResult: true,
          clearError: true,
        );
        break;
      case 'PV':
        state = state.copyWith(
          pv: value,
          displayBuffer: '',
          activeVariable: variable,
          statusMessage: 'PV = ${value.toStringAsFixed(2)}',
          cptMode: false,
          clearResult: true,
          clearError: true,
        );
        break;
      case 'PMT':
        state = state.copyWith(
          pmt: value,
          displayBuffer: '',
          activeVariable: variable,
          statusMessage: 'PMT = ${value.toStringAsFixed(2)}',
          cptMode: false,
          clearResult: true,
          clearError: true,
        );
        break;
      case 'FV':
        state = state.copyWith(
          fv: value,
          displayBuffer: '',
          activeVariable: variable,
          statusMessage: 'FV = ${value.toStringAsFixed(2)}',
          cptMode: false,
          clearResult: true,
          clearError: true,
        );
        break;
    }
  }

  /// Enter CPT mode — next TVM key press will compute that variable
  void enterCptMode() {
    state = state.copyWith(
      cptMode: true,
      statusMessage: 'CPT',
    );
  }

  /// Compute a specific variable (called when CPT is active and a TVM key is pressed)
  void computeVariable(String target) {
    // Null out the target variable so it becomes the "missing" one
    switch (target) {
      case 'N':
        state = state.copyWith(n: null);
        break;
      case 'I/Y':
        state = state.copyWith(iy: null);
        break;
      case 'PV':
        state = state.copyWith(pv: null);
        break;
      case 'PMT':
        state = state.copyWith(pmt: null);
        break;
      case 'FV':
        state = state.copyWith(fv: null);
        break;
    }

    if (state.filledCount != 4) {
      state = state.copyWith(
        errorMessage: 'Need 4 values to compute $target',
        cptMode: false,
        statusMessage: null,
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
        pmtMode: state.pmtMode,
        ppy: state.ppy,
        cpy: state.cpy,
      );

      final result = TVMSolver.solve(input);
      final label = _getResultLabel(target);

      // Store result back into the target variable and show on display
      switch (target) {
        case 'N':
          state = state.copyWith(
            n: result,
            result: result,
            resultLabel: label,
            displayBuffer: result.toStringAsFixed(2),
            activeVariable: target,
            cptMode: false,
            statusMessage: '$target = ${result.toStringAsFixed(2)}',
            clearError: true,
          );
          break;
        case 'I/Y':
          state = state.copyWith(
            iy: result,
            result: result,
            resultLabel: label,
            displayBuffer: result.toStringAsFixed(2),
            activeVariable: target,
            cptMode: false,
            statusMessage: '$target = ${result.toStringAsFixed(2)}',
            clearError: true,
          );
          break;
        case 'PV':
          state = state.copyWith(
            pv: result,
            result: result,
            resultLabel: label,
            displayBuffer: result.toStringAsFixed(2),
            activeVariable: target,
            cptMode: false,
            statusMessage: '$target = ${result.toStringAsFixed(2)}',
            clearError: true,
          );
          break;
        case 'PMT':
          state = state.copyWith(
            pmt: result,
            result: result,
            resultLabel: label,
            displayBuffer: result.toStringAsFixed(2),
            activeVariable: target,
            cptMode: false,
            statusMessage: '$target = ${result.toStringAsFixed(2)}',
            clearError: true,
          );
          break;
        case 'FV':
          state = state.copyWith(
            fv: result,
            result: result,
            resultLabel: label,
            displayBuffer: result.toStringAsFixed(2),
            activeVariable: target,
            cptMode: false,
            statusMessage: '$target = ${result.toStringAsFixed(2)}',
            clearError: true,
          );
          break;
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error: ${e.toString()}',
        cptMode: false,
        statusMessage: null,
        clearResult: true,
      );
    }
  }

  /// Calculate the missing variable (used by form mode)
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
        pmtMode: state.pmtMode,
        ppy: state.ppy,
        cpy: state.cpy,
      );

      final result = TVMSolver.solve(input);
      final missing = state.missingVariable;

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

  /// Clear just the display buffer (like CE on BA II Plus)
  void clearEntry() {
    state = state.copyWith(
      displayBuffer: '',
      statusMessage: null,
      cptMode: false,
    );
  }
}

/// Provider instance - This is what we'll use in the UI
final calculatorProvider =
    StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  return CalculatorNotifier();
});
