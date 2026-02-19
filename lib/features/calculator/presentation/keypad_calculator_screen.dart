import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../widgets/display_panel.dart';
import '../widgets/full_keypad.dart';

/// Keypad Calculator Screen — TI BA II Plus full layout
/// Display (flex 2) + Full 10-row keypad (flex 5)
class KeypadCalculatorScreen extends StatelessWidget {
  const KeypadCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingS,
            vertical: AppDimensions.spacingXs,
          ),
          child: Column(
            children: [
              // ── Display (flex 2) ─────────────────────────────────────
              const Expanded(
                flex: 2,
                child: Center(child: DisplayPanel()),
              ),

              const SizedBox(height: AppDimensions.spacingS),

              // ── Full 10-row keypad (flex 5) ──────────────────────────
              const Expanded(
                flex: 5,
                child: FullKeypad(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
