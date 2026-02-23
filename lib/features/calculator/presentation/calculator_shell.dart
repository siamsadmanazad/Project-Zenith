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
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _setMode(CalculatorMode mode) {
    ref.read(calculatorModeProvider.notifier).state = mode;
    _pageController.animateToPage(
      mode == CalculatorMode.keypad ? 0 : 1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(calculatorModeProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Column(
        children: [
          // Segmented control pill between status bar and content
          SizedBox(height: topPadding + 8),
          Center(
            child: ModeSegmentedControl(
              currentMode: mode,
              onModeChanged: _setMode,
            ),
          ),
          const SizedBox(height: 4),

          // Page view with both modes
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (index) {
                ref.read(calculatorModeProvider.notifier).state =
                    index == 0 ? CalculatorMode.keypad : CalculatorMode.form;
              },
              children: const [
                KeypadCalculatorScreen(),
                FormCalculatorScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
