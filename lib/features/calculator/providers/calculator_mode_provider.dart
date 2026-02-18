import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Calculator display mode
enum CalculatorMode { keypad, form }

/// Separate provider for mode — switching modes doesn't trigger recalculation
final calculatorModeProvider = StateProvider<CalculatorMode>((ref) {
  return CalculatorMode.keypad;
});
