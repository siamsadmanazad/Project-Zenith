import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calculator_mode_provider.dart';
import '../widgets/mode_toggle_button.dart';
import 'keypad_calculator_screen.dart';
import 'calculator_screen.dart';

/// Calculator Shell — hosts both keypad and form modes
/// with swipe + toggle transitions sharing a single state
class CalculatorShell extends ConsumerStatefulWidget {
  const CalculatorShell({super.key});

  @override
  ConsumerState<CalculatorShell> createState() => _CalculatorShellState();
}

class _CalculatorShellState extends ConsumerState<CalculatorShell> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0, // Keypad first
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    final currentMode = ref.read(calculatorModeProvider);
    final newMode = currentMode == CalculatorMode.keypad
        ? CalculatorMode.form
        : CalculatorMode.keypad;

    ref.read(calculatorModeProvider.notifier).state = newMode;

    _pageController.animateToPage(
      newMode == CalculatorMode.keypad ? 0 : 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(calculatorModeProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Page view with both modes
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              ref.read(calculatorModeProvider.notifier).state =
                  index == 0 ? CalculatorMode.keypad : CalculatorMode.form;
            },
            children: const [
              KeypadCalculatorScreen(),
              FormCalculatorScreen(),
            ],
          ),

          // Floating mode toggle button — top right
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: ModeToggleButton(
              currentMode: mode,
              onToggle: _toggleMode,
            ),
          ),
        ],
      ),
    );
  }
}
