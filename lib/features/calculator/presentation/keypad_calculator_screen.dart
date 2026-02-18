import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../widgets/display_panel.dart';
import '../widgets/tvm_key_row.dart';
import '../widgets/number_pad.dart';
import '../widgets/bottom_action_row.dart';

/// Keypad Calculator Screen — BA II Plus reimagined with glassmorphic design
class KeypadCalculatorScreen extends ConsumerWidget {
  const KeypadCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.spacingS),

            // ============ DISPLAY (flex 3) ============
            const Expanded(
              flex: 3,
              child: Center(
                child: DisplayPanel(),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingM),

            // ============ KEYPAD AREA (flex 5) ============
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  // TVM Key Row: N, I/Y, PV, PMT, FV
                  const TVMKeyRow(),

                  const SizedBox(height: AppDimensions.spacingM),

                  // Number Pad
                  const Expanded(
                    child: NumberPad(),
                  ),

                  const SizedBox(height: 6),

                  // Bottom Action Row: CLR, P/Y, C/Y
                  const BottomActionRow(),

                  const SizedBox(height: AppDimensions.spacingS),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
