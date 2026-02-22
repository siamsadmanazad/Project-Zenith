import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../math_engine/arithmetic/aos_engine.dart';
import '../../../math_engine/arithmetic/trig_functions.dart';
import '../../../math_engine/arithmetic/combinatorics.dart';
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

  // 2ND key state
  final bool twoNdActive;

  // Phase A — Arithmetic
  final String? pendingOperator; // display feedback: "+", "−", etc.
  final bool resultDisplayed; // true when display shows computed result
  final double? lastAnswer; // ANS — last '=' result
  final int openParenCount; // unclosed parens

  // Phase B — Math
  final bool invActive; // INV modifier for trig
  final bool hypActive; // HYP modifier for trig

  // Phase C — Memory & Utility
  final List<double> memoryRegisters; // 10 registers, default all 0.0
  final bool stoMode; // awaiting digit 0-9 after STO
  final bool rclMode; // awaiting digit 0-9 after RCL
  final int decimalPlaces; // 0-9 or 10=floating, default 2
  final bool formatMode; // awaiting digit for FORMAT

  // Phase D — Financial
  final double? deltaPercentOld;
  final bool deltaPercentMode;

  // Worksheets
  final String? activeWorksheet;

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
    this.twoNdActive = false,
    this.pendingOperator,
    this.resultDisplayed = false,
    this.lastAnswer,
    this.openParenCount = 0,
    this.invActive = false,
    this.hypActive = false,
    this.memoryRegisters = const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    this.stoMode = false,
    this.rclMode = false,
    this.decimalPlaces = 2,
    this.formatMode = false,
    this.deltaPercentOld,
    this.deltaPercentMode = false,
    this.activeWorksheet,
  });

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
    bool? twoNdActive,
    Object? pendingOperator = _unset,
    bool? resultDisplayed,
    Object? lastAnswer = _unset,
    int? openParenCount,
    bool? invActive,
    bool? hypActive,
    List<double>? memoryRegisters,
    bool? stoMode,
    bool? rclMode,
    int? decimalPlaces,
    bool? formatMode,
    Object? deltaPercentOld = _unset,
    bool? deltaPercentMode,
    Object? activeWorksheet = _unset,
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
      result: clearResult
          ? null
          : (identical(result, _unset) ? this.result : result as double?),
      resultLabel: clearResult
          ? null
          : (identical(resultLabel, _unset)
              ? this.resultLabel
              : resultLabel as String?),
      errorMessage: clearError
          ? null
          : (identical(errorMessage, _unset)
              ? this.errorMessage
              : errorMessage as String?),
      displayBuffer: displayBuffer ?? this.displayBuffer,
      activeVariable: identical(activeVariable, _unset)
          ? this.activeVariable
          : activeVariable as String?,
      cptMode: cptMode ?? this.cptMode,
      statusMessage: identical(statusMessage, _unset)
          ? this.statusMessage
          : statusMessage as String?,
      twoNdActive: twoNdActive ?? this.twoNdActive,
      pendingOperator: identical(pendingOperator, _unset)
          ? this.pendingOperator
          : pendingOperator as String?,
      resultDisplayed: resultDisplayed ?? this.resultDisplayed,
      lastAnswer: identical(lastAnswer, _unset)
          ? this.lastAnswer
          : lastAnswer as double?,
      openParenCount: openParenCount ?? this.openParenCount,
      invActive: invActive ?? this.invActive,
      hypActive: hypActive ?? this.hypActive,
      memoryRegisters: memoryRegisters ?? this.memoryRegisters,
      stoMode: stoMode ?? this.stoMode,
      rclMode: rclMode ?? this.rclMode,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      formatMode: formatMode ?? this.formatMode,
      deltaPercentOld: identical(deltaPercentOld, _unset)
          ? this.deltaPercentOld
          : deltaPercentOld as double?,
      deltaPercentMode: deltaPercentMode ?? this.deltaPercentMode,
      activeWorksheet: identical(activeWorksheet, _unset)
          ? this.activeWorksheet
          : activeWorksheet as String?,
    );
  }

  int get filledCount {
    int count = 0;
    if (n != null) count++;
    if (iy != null) count++;
    if (pv != null) count++;
    if (pmt != null) count++;
    if (fv != null) count++;
    return count;
  }

  bool get canCalculate => filledCount == 4;

  String? get missingVariable {
    if (n == null) return 'N';
    if (iy == null) return 'I/Y';
    if (pv == null) return 'PV';
    if (pmt == null) return 'PMT';
    if (fv == null) return 'FV';
    return null;
  }

  double? getVariable(String variable) {
    switch (variable) {
      case 'N':
        return n;
      case 'I/Y':
        return iy;
      case 'PV':
        return pv;
      case 'PMT':
        return pmt;
      case 'FV':
        return fv;
      default:
        return null;
    }
  }
}

/// Calculator Provider - Manages calculator state
class CalculatorNotifier extends StateNotifier<CalculatorState> {
  CalculatorNotifier() : super(const CalculatorState());

  final AOSEngine _aos = AOSEngine();

  // ========== FIELD UPDATES ==========

  void updateField(String field, double? value) {
    switch (field) {
      case 'N':
        state = state.copyWith(n: value, clearResult: true, clearError: true);
      case 'I/Y':
        state = state.copyWith(iy: value, clearResult: true, clearError: true);
      case 'PV':
        state = state.copyWith(pv: value, clearResult: true, clearError: true);
      case 'PMT':
        state = state.copyWith(pmt: value, clearResult: true, clearError: true);
      case 'FV':
        state = state.copyWith(fv: value, clearResult: true, clearError: true);
    }
  }

  void updatePmtMode(int mode) {
    state = state.copyWith(pmtMode: mode, clearResult: true, clearError: true);
  }

  void updatePpy(int ppy) {
    state = state.copyWith(ppy: ppy, clearResult: true, clearError: true);
  }

  void updateCpy(int cpy) {
    state = state.copyWith(cpy: cpy, clearResult: true, clearError: true);
  }

  // ========== KEYPAD — DIGIT ENTRY ==========

  void appendDigit(String digit) {
    // STO/RCL intercept: digit selects memory register
    if (state.stoMode || state.rclMode) {
      _memoryDigit(int.parse(digit));
      return;
    }

    // FORMAT intercept: digit sets decimal places
    if (state.formatMode) {
      _setDecimalPlaces(int.parse(digit));
      return;
    }

    // If result is displayed, start fresh
    if (state.resultDisplayed) {
      if (state.pendingOperator == null) {
        // No pending op — new calculation entirely
        _aos.clear();
      }
      state = state.copyWith(
        displayBuffer: '',
        resultDisplayed: false,
        clearResult: true,
      );
    }

    if (state.displayBuffer.replaceAll('-', '').replaceAll('.', '').length >=
        12) return;
    state = state.copyWith(
      displayBuffer: state.displayBuffer + digit,
      clearError: true,
      statusMessage: null,
    );
  }

  void appendDecimal() {
    if (state.stoMode || state.rclMode || state.formatMode) return;

    if (state.resultDisplayed) {
      if (state.pendingOperator == null) {
        _aos.clear();
      }
      state = state.copyWith(
        displayBuffer: '',
        resultDisplayed: false,
        clearResult: true,
      );
    }

    if (state.displayBuffer.contains('.')) return;
    final buffer =
        state.displayBuffer.isEmpty ? '0.' : '${state.displayBuffer}.';
    state = state.copyWith(
      displayBuffer: buffer,
      clearError: true,
      statusMessage: null,
    );
  }

  void toggleSign() {
    if (state.displayBuffer.isEmpty) return;
    if (state.displayBuffer.startsWith('-')) {
      state = state.copyWith(displayBuffer: state.displayBuffer.substring(1));
    } else {
      state = state.copyWith(displayBuffer: '-${state.displayBuffer}');
    }
  }

  void backspace() {
    if (state.displayBuffer.isEmpty) return;
    state = state.copyWith(
      displayBuffer:
          state.displayBuffer.substring(0, state.displayBuffer.length - 1),
    );
  }

  // ========== ARITHMETIC (Phase A) ==========

  /// Press an arithmetic operator: +, -, *, /
  void pressOperator(String op) {
    final value = _parseBuffer();

    if (state.resultDisplayed && value != null) {
      // Chain from previous result — operand already on stack from evaluate
      // Just push the new operator
    } else if (value != null) {
      _aos.pushOperand(value);
    }

    final intermediate = _aos.pushOperator(op);

    final displayOp = _operatorSymbol(op);
    state = state.copyWith(
      displayBuffer:
          intermediate != null ? _formatResult(intermediate) : state.displayBuffer,
      pendingOperator: displayOp,
      resultDisplayed: false,
      statusMessage: null,
      clearError: true,
    );
  }

  /// Press = to evaluate the full expression.
  void pressEquals() {
    final value = _parseBuffer();
    if (value != null) {
      _aos.pushOperand(value);
    }

    try {
      final result = _aos.evaluate();
      state = state.copyWith(
        displayBuffer: _formatResult(result),
        lastAnswer: result,
        pendingOperator: null,
        resultDisplayed: true,
        openParenCount: 0,
        statusMessage: null,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error: $e',
        pendingOperator: null,
        statusMessage: null,
      );
    }
  }

  void openParen() {
    if (state.resultDisplayed) {
      _aos.clear();
      state = state.copyWith(
        displayBuffer: '',
        resultDisplayed: false,
        clearResult: true,
      );
    }
    _aos.openParen();
    state = state.copyWith(
      openParenCount: _aos.openParenCount,
      displayBuffer: '',
      statusMessage: null,
    );
  }

  void closeParen() {
    final value = _parseBuffer();
    if (value != null) {
      _aos.pushOperand(value);
    }

    final result = _aos.closeParen();
    if (result != null) {
      state = state.copyWith(
        displayBuffer: _formatResult(result),
        openParenCount: _aos.openParenCount,
        statusMessage: null,
      );
    }
  }

  // ========== UNARY FUNCTIONS (Phase B) ==========

  /// Apply a unary function to the current display value.
  void applyUnary(double Function(double) fn, {String? label}) {
    final value = _parseBuffer() ?? 0;
    try {
      final result = fn(value);
      _aos.replaceTopOperand(result);
      state = state.copyWith(
        displayBuffer: _formatResult(result),
        resultDisplayed: true,
        statusMessage: label != null ? '$label($value)' : null,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error: $e',
        statusMessage: null,
      );
    }
  }

  /// Square root
  void sqrtX() {
    final value = _parseBuffer() ?? 0;
    if (value < 0) {
      state = state.copyWith(errorMessage: 'Error: √ of negative');
      return;
    }
    _pushCurrentIfNeeded(value);
    applyUnary((x) => math.sqrt(x), label: '√');
  }

  /// x squared
  void xSquared() {
    final value = _parseBuffer() ?? 0;
    _pushCurrentIfNeeded(value);
    applyUnary((x) => x * x, label: 'x²');
  }

  /// Reciprocal 1/x
  void reciprocal() {
    final value = _parseBuffer() ?? 0;
    if (value == 0) {
      state = state.copyWith(errorMessage: 'Error: Division by zero');
      return;
    }
    _pushCurrentIfNeeded(value);
    applyUnary((x) => 1 / x, label: '1/x');
  }

  /// Natural log
  void naturalLog() {
    final value = _parseBuffer() ?? 0;
    if (value <= 0) {
      state = state.copyWith(errorMessage: 'Error: LN of non-positive');
      return;
    }
    _pushCurrentIfNeeded(value);
    applyUnary((x) => math.log(x), label: 'LN');
  }

  /// e^x (2ND + LN)
  void expX() {
    final value = _parseBuffer() ?? 0;
    _pushCurrentIfNeeded(value);
    applyUnary((x) => math.exp(x), label: 'eˣ');
  }

  /// y^x — pushes ^ as binary operator in AOS
  void yPowerX() {
    pressOperator('^');
  }

  /// Percent — context-dependent
  void percent() {
    final value = _parseBuffer() ?? 0;
    final pendingOp = _aos.pendingOperator;
    final base = _aos.baseOperand;

    if ((pendingOp == '+' || pendingOp == '-') && base != null) {
      // Relative: 100 + 10% → 100 + (100 * 0.10)
      final pctValue = base * (value / 100);
      _aos.replaceTopOperand(pctValue);
      state = state.copyWith(
        displayBuffer: _formatResult(pctValue),
        resultDisplayed: true,
        statusMessage: null,
        clearError: true,
      );
    } else {
      // Simple: just divide by 100
      final pctValue = value / 100;
      if (_aos.hasOperands) {
        _aos.replaceTopOperand(pctValue);
      }
      state = state.copyWith(
        displayBuffer: _formatResult(pctValue),
        resultDisplayed: true,
        statusMessage: null,
        clearError: true,
      );
    }
  }

  /// Trig dispatch: 2ND+√x=SIN, 2ND+x²=COS, 2ND+1/x=TAN
  void trigFunction(String base) {
    final value = _parseBuffer() ?? 0;
    _pushCurrentIfNeeded(value);
    try {
      final result = TrigFunctions.evaluate(
        base,
        value,
        inv: state.invActive,
        hyp: state.hypActive,
      );
      _aos.replaceTopOperand(result);
      final prefix =
          '${state.invActive ? 'a' : ''}${state.hypActive ? '' : ''}$base${state.hypActive ? 'h' : ''}';
      state = state.copyWith(
        displayBuffer: _formatResult(result),
        resultDisplayed: true,
        invActive: false,
        hypActive: false,
        statusMessage: '$prefix($value)',
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error: $e',
        invActive: false,
        hypActive: false,
      );
    }
  }

  /// Toggle INV modifier
  void toggleInv() {
    state = state.copyWith(
      invActive: !state.invActive,
      statusMessage: !state.invActive ? 'INV' : null,
    );
  }

  /// Toggle HYP modifier (2ND + %)
  void toggleHyp() {
    state = state.copyWith(
      hypActive: !state.hypActive,
      statusMessage: !state.hypActive ? 'HYP' : null,
    );
  }

  /// Factorial (2ND + ÷)
  void factorial() {
    final value = _parseBuffer() ?? 0;
    _pushCurrentIfNeeded(value);
    try {
      final result = Combinatorics.factorial(value);
      _aos.replaceTopOperand(result);
      state = state.copyWith(
        displayBuffer: _formatResult(result),
        resultDisplayed: true,
        statusMessage: '${value.round()}!',
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error: $e');
    }
  }

  /// nPr — binary operator (2ND + ×)
  void nPrOperator() {
    pressOperator('P');
  }

  /// nCr — binary operator (2ND + -)
  void nCrOperator() {
    pressOperator('C');
  }

  // ========== MEMORY (Phase C) ==========

  /// Enter STO mode — next digit stores display value
  void enterStoMode() {
    state = state.copyWith(
      stoMode: true,
      rclMode: false,
      statusMessage: 'STO _',
    );
  }

  /// Enter RCL mode — next digit recalls stored value
  void enterRclMode() {
    state = state.copyWith(
      rclMode: true,
      stoMode: false,
      statusMessage: 'RCL _',
    );
  }

  void _memoryDigit(int index) {
    if (index < 0 || index > 9) return;

    if (state.stoMode) {
      final value = _parseBuffer() ?? 0;
      final regs = List<double>.from(state.memoryRegisters);
      regs[index] = value;
      state = state.copyWith(
        memoryRegisters: regs,
        stoMode: false,
        statusMessage: 'STO $index = ${_formatResult(value)}',
      );
    } else if (state.rclMode) {
      final value = state.memoryRegisters[index];
      state = state.copyWith(
        displayBuffer: _formatResult(value),
        rclMode: false,
        resultDisplayed: true,
        statusMessage: 'RCL $index = ${_formatResult(value)}',
      );
    }
  }

  /// Cancel STO/RCL mode on non-digit press
  void cancelMemoryMode() {
    state = state.copyWith(
      stoMode: false,
      rclMode: false,
      statusMessage: null,
    );
  }

  /// ANS — recall last equals result (2ND + '+')
  void recallAns() {
    final ans = state.lastAnswer ?? 0;
    state = state.copyWith(
      displayBuffer: _formatResult(ans),
      resultDisplayed: true,
      statusMessage: 'ANS = ${_formatResult(ans)}',
    );
  }

  /// Enter FORMAT mode (2ND + '.')
  void enterFormatMode() {
    state = state.copyWith(
      formatMode: true,
      statusMessage: 'DEC = ${state.decimalPlaces == 10 ? "F" : state.decimalPlaces}  Enter 0-9',
    );
  }

  void _setDecimalPlaces(int dp) {
    // dp 0-9 sets fixed places. We don't support 10 (float) from digit input.
    state = state.copyWith(
      decimalPlaces: dp,
      formatMode: false,
      statusMessage: 'DEC = $dp',
    );
  }

  /// ROUND — round display value to current decimalPlaces
  void roundDisplay() {
    final value = _parseBuffer() ?? 0;
    final dp = state.decimalPlaces;
    final factor = math.pow(10, dp);
    final rounded = (value * factor).roundToDouble() / factor;
    state = state.copyWith(
      displayBuffer: _formatResult(rounded),
      statusMessage: 'ROUNDED to $dp dp',
    );
  }

  /// RESET — full factory reset (2ND + '3')
  void reset() {
    _aos.clear();
    state = const CalculatorState();
    state = state.copyWith(statusMessage: 'RESET');
  }

  /// MEM — show memory usage (2ND + '0')
  void showMemStatus() {
    int used = 0;
    for (final v in state.memoryRegisters) {
      if (v != 0) used++;
    }
    state = state.copyWith(statusMessage: 'MEM: $used/10 used');
  }

  // ========== DELTA PERCENT (Phase D) ==========

  /// Enter Δ% mode (2ND + '8')
  void enterDeltaPercent() {
    final value = _parseBuffer();
    if (value != null) {
      state = state.copyWith(
        deltaPercentOld: value,
        deltaPercentMode: true,
        displayBuffer: '',
        statusMessage: 'OLD = ${_formatResult(value)}',
      );
    } else if (state.deltaPercentOld != null) {
      // Already have old value — compute
      _computeDeltaPercent();
    } else {
      state = state.copyWith(statusMessage: 'Enter OLD value first');
    }
  }

  void _computeDeltaPercent() {
    final old = state.deltaPercentOld;
    final newVal = _parseBuffer();
    if (old == null || newVal == null) {
      state = state.copyWith(errorMessage: 'Need OLD and NEW values');
      return;
    }
    if (old == 0) {
      state = state.copyWith(errorMessage: 'Error: OLD = 0');
      return;
    }
    final pctChange = (newVal - old) / old * 100;
    state = state.copyWith(
      displayBuffer: _formatResult(pctChange),
      deltaPercentMode: false,
      deltaPercentOld: null,
      resultDisplayed: true,
      statusMessage: 'Δ% = ${_formatResult(pctChange)}%',
    );
  }

  // ========== TVM METHODS ==========

  void storeTVMVariable(String variable) {
    final buffer = state.displayBuffer;
    if (buffer.isEmpty) {
      final currentValue = state.getVariable(variable);
      state = state.copyWith(
        activeVariable: variable,
        statusMessage:
            '$variable = ${currentValue != null ? currentValue.toStringAsFixed(2) : "0.00"}',
        cptMode: false,
      );
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

    switch (variable) {
      case 'N':
        state = state.copyWith(
            n: value,
            displayBuffer: '',
            activeVariable: variable,
            statusMessage: 'N = ${value.toStringAsFixed(2)}',
            cptMode: false,
            clearResult: true,
            clearError: true);
      case 'I/Y':
        state = state.copyWith(
            iy: value,
            displayBuffer: '',
            activeVariable: variable,
            statusMessage: 'I/Y = ${value.toStringAsFixed(2)}',
            cptMode: false,
            clearResult: true,
            clearError: true);
      case 'PV':
        state = state.copyWith(
            pv: value,
            displayBuffer: '',
            activeVariable: variable,
            statusMessage: 'PV = ${value.toStringAsFixed(2)}',
            cptMode: false,
            clearResult: true,
            clearError: true);
      case 'PMT':
        state = state.copyWith(
            pmt: value,
            displayBuffer: '',
            activeVariable: variable,
            statusMessage: 'PMT = ${value.toStringAsFixed(2)}',
            cptMode: false,
            clearResult: true,
            clearError: true);
      case 'FV':
        state = state.copyWith(
            fv: value,
            displayBuffer: '',
            activeVariable: variable,
            statusMessage: 'FV = ${value.toStringAsFixed(2)}',
            cptMode: false,
            clearResult: true,
            clearError: true);
    }
  }

  void enterCptMode() {
    state = state.copyWith(
      cptMode: true,
      statusMessage: 'CPT',
    );
  }

  void computeVariable(String target) {
    switch (target) {
      case 'N':
        state = state.copyWith(n: null);
      case 'I/Y':
        state = state.copyWith(iy: null);
      case 'PV':
        state = state.copyWith(pv: null);
      case 'PMT':
        state = state.copyWith(pmt: null);
      case 'FV':
        state = state.copyWith(fv: null);
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
              clearError: true);
        case 'I/Y':
          state = state.copyWith(
              iy: result,
              result: result,
              resultLabel: label,
              displayBuffer: result.toStringAsFixed(2),
              activeVariable: target,
              cptMode: false,
              statusMessage: '$target = ${result.toStringAsFixed(2)}',
              clearError: true);
        case 'PV':
          state = state.copyWith(
              pv: result,
              result: result,
              resultLabel: label,
              displayBuffer: result.toStringAsFixed(2),
              activeVariable: target,
              cptMode: false,
              statusMessage: '$target = ${result.toStringAsFixed(2)}',
              clearError: true);
        case 'PMT':
          state = state.copyWith(
              pmt: result,
              result: result,
              resultLabel: label,
              displayBuffer: result.toStringAsFixed(2),
              activeVariable: target,
              cptMode: false,
              statusMessage: '$target = ${result.toStringAsFixed(2)}',
              clearError: true);
        case 'FV':
          state = state.copyWith(
              fv: result,
              result: result,
              resultLabel: label,
              displayBuffer: result.toStringAsFixed(2),
              activeVariable: target,
              cptMode: false,
              statusMessage: '$target = ${result.toStringAsFixed(2)}',
              clearError: true);
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

      state = state.copyWith(
        result: result,
        resultLabel: _getResultLabel(missing),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Calculation error: ${e.toString()}',
        clearResult: true,
      );
    }
  }

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

  // ========== CLEAR ==========

  void clear() {
    _aos.clear();
    state = const CalculatorState();
  }

  void clearEntry() {
    state = state.copyWith(
      displayBuffer: '',
      statusMessage: null,
      cptMode: false,
      stoMode: false,
      rclMode: false,
      formatMode: false,
      pendingOperator: null,
    );
  }

  // ========== 2ND KEY ==========

  void toggle2nd() {
    final next = !state.twoNdActive;
    state = state.copyWith(
      twoNdActive: next,
      statusMessage: next ? '2ND' : null,
    );
  }

  void clearTVM() {
    state = state.copyWith(
      n: null,
      iy: null,
      pv: null,
      pmt: null,
      fv: null,
      displayBuffer: '',
      activeVariable: null,
      cptMode: false,
      twoNdActive: false,
      clearResult: true,
      clearError: true,
      statusMessage: 'TVM CLEARED',
    );
  }

  void setStatusMessage(String message) {
    state = state.copyWith(statusMessage: message);
  }

  void setActiveWorksheet(String? worksheet) {
    state = state.copyWith(activeWorksheet: worksheet);
  }

  // ========== HELPERS ==========

  double? _parseBuffer() {
    if (state.displayBuffer.isEmpty) return null;
    return double.tryParse(state.displayBuffer.replaceAll(',', ''));
  }

  /// Push current value as operand if it hasn't been pushed yet
  /// (for unary functions that need the value on the AOS stack).
  void _pushCurrentIfNeeded(double value) {
    if (!_aos.hasOperands || _aos.resultDisplayed) {
      _aos.pushOperand(value);
      _aos.resultDisplayed = false;
    }
  }

  String _formatResult(double value) {
    // Check for integer values
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      final intVal = value.toInt();
      return intVal.toString();
    }
    // Use decimalPlaces setting
    final dp = state.decimalPlaces;
    if (dp >= 10) {
      // Floating mode — remove trailing zeros
      String s = value.toStringAsFixed(10);
      // Remove trailing zeros after decimal
      if (s.contains('.')) {
        s = s.replaceAll(RegExp(r'0+$'), '');
        s = s.replaceAll(RegExp(r'\.$'), '');
      }
      return s;
    }
    return value.toStringAsFixed(dp);
  }

  static String _operatorSymbol(String op) {
    switch (op) {
      case '+':
        return '+';
      case '-':
        return '−';
      case '*':
        return '×';
      case '/':
        return '÷';
      case '^':
        return 'yˣ';
      case 'P':
        return 'nPr';
      case 'C':
        return 'nCr';
      default:
        return op;
    }
  }
}

/// Provider instance
final calculatorProvider =
    StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  return CalculatorNotifier();
});
