import 'dart:math' as math;

/// AOS (Algebraic Operating System) engine — TI BA II Plus style.
///
/// Implements shunting-yard-style immediate evaluation with operator
/// precedence: +/− = 1, ×/÷ = 2, ^ / nPr / nCr = 3.
/// Parentheses are supported via sentinel markers on the operator stack.
class AOSEngine {
  final List<double> _operands = [];
  final List<String> _operators = [];

  double? lastResult;
  bool resultDisplayed = false;
  int openParenCount = 0;

  static const _precedence = <String, int>{
    '+': 1,
    '-': 1,
    '*': 2,
    '/': 2,
    '^': 3,
    'P': 3, // nPr
    'C': 3, // nCr
  };

  /// Push a number onto the operand stack.
  void pushOperand(double value) {
    _operands.add(value);
  }

  /// Push an operator, flushing higher-or-equal precedence ops first.
  /// Returns the intermediate result if a flush produced one, else null.
  double? pushOperator(String op) {
    double? intermediate;
    final prec = _precedence[op] ?? 1;

    while (_operators.isNotEmpty &&
        _operators.last != '(' &&
        (_precedence[_operators.last] ?? 0) >= prec &&
        _operands.length >= 2) {
      intermediate = _applyTop();
    }

    _operators.add(op);
    return intermediate;
  }

  /// Open a parenthesis group.
  void openParen() {
    _operators.add('(');
    openParenCount++;
  }

  /// Close a parenthesis group — evaluate back to matching '('.
  /// Returns the result inside the parens.
  double? closeParen() {
    if (openParenCount <= 0) return null;

    double? result;
    while (_operators.isNotEmpty && _operators.last != '(') {
      if (_operands.length >= 2) {
        result = _applyTop();
      } else {
        break;
      }
    }
    // Remove the '(' sentinel
    if (_operators.isNotEmpty && _operators.last == '(') {
      _operators.removeLast();
    }
    openParenCount--;
    result ??= _operands.isNotEmpty ? _operands.last : null;
    return result;
  }

  /// Evaluate everything remaining — triggered by '='.
  double evaluate() {
    while (_operators.isNotEmpty && _operands.length >= 2) {
      if (_operators.last == '(') {
        _operators.removeLast();
        continue;
      }
      _applyTop();
    }
    final result = _operands.isNotEmpty ? _operands.last : 0.0;
    lastResult = result;
    resultDisplayed = true;
    openParenCount = 0;
    return result;
  }

  /// Clear everything.
  void clear() {
    _operands.clear();
    _operators.clear();
    lastResult = null;
    resultDisplayed = false;
    openParenCount = 0;
  }

  /// Replace the top operand (used after unary functions like √x).
  void replaceTopOperand(double value) {
    if (_operands.isNotEmpty) {
      _operands[_operands.length - 1] = value;
    } else {
      _operands.add(value);
    }
  }

  /// Check if there's a pending operator (for percent context).
  String? get pendingOperator =>
      _operators.isNotEmpty && _operators.last != '(' ? _operators.last : null;

  /// Whether the operand stack has values.
  bool get hasOperands => _operands.isNotEmpty;

  /// Peek at the operand before the current one (for percent base).
  double? get baseOperand =>
      _operands.length >= 2 ? _operands[_operands.length - 2] : null;

  // ── Private ──────────────────────────────────────────────────────────────

  double _applyTop() {
    final op = _operators.removeLast();
    final b = _operands.removeLast();
    final a = _operands.removeLast();
    final result = _compute(a, b, op);
    _operands.add(result);
    return result;
  }

  static double _compute(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        if (b == 0) throw ArgumentError('Division by zero');
        return a / b;
      case '^':
        if (a == 0 && b < 0) throw ArgumentError('Division by zero');
        if (a < 0 && b != b.roundToDouble()) {
          throw ArgumentError('Complex result');
        }
        return math.pow(a, b).toDouble();
      case 'P':
        return _permutation(a.round(), b.round()).toDouble();
      case 'C':
        return _combination(a.round(), b.round()).toDouble();
      default:
        return b;
    }
  }

  static int _factorial(int n) {
    if (n < 0) throw ArgumentError('Negative factorial');
    if (n <= 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  static int _permutation(int n, int r) {
    if (r < 0 || r > n) throw ArgumentError('Invalid nPr');
    return _factorial(n) ~/ _factorial(n - r);
  }

  static int _combination(int n, int r) {
    if (r < 0 || r > n) throw ArgumentError('Invalid nCr');
    return _factorial(n) ~/ (_factorial(r) * _factorial(n - r));
  }
}
