import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../providers/calculator_state.dart';
import '../widgets/tvm_input_field.dart';
import '../widgets/glass_button.dart';

/// Main Calculator Screen - The heart of Zenith
class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF0F1419)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ============ HEADER ============
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingL),
                child: Column(
                  children: [
                    Text(
                      'ZENITH',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        letterSpacing: 6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time Value of Money',
                      style: theme.textTheme.bodySmall?.copyWith(
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ============ RESULT DISPLAY ============
              if (state.result != null) ...[
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingL,
                    vertical: AppDimensions.spacingM,
                  ),
                  padding: const EdgeInsets.all(AppDimensions.spacingXl),
                  decoration: BoxDecoration(
                    color: AppColors.glassOverlay,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: AppDimensions.glassBorderWidth,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        state.resultLabel ?? 'Result',
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      Text(
                        _formatResult(state.result!, state.missingVariable),
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 48,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ============ ERROR MESSAGE ============
              if (state.errorMessage != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingL,
                    vertical: AppDimensions.spacingM,
                  ),
                  padding: const EdgeInsets.all(AppDimensions.spacingM),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    state.errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),

              // ============ INPUT FIELDS ============
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.spacingL),
                  child: Column(
                    children: [
                      TVMInputField(
                        label: 'N (Number of Periods)',
                        hint: 'e.g., 360 for 30 years',
                        value: state.n,
                        onChanged: (value) => notifier.updateField('N', value),
                      ),
                      const SizedBox(height: AppDimensions.spacingM),

                      TVMInputField(
                        label: 'I/Y (Interest Rate %)',
                        hint: 'e.g., 6.5 for 6.5%',
                        value: state.iy,
                        onChanged: (value) => notifier.updateField('I/Y', value),
                      ),
                      const SizedBox(height: AppDimensions.spacingM),

                      TVMInputField(
                        label: 'PV (Present Value)',
                        hint: 'e.g., 500000',
                        value: state.pv,
                        onChanged: (value) => notifier.updateField('PV', value),
                        isCurrency: true,
                      ),
                      const SizedBox(height: AppDimensions.spacingM),

                      TVMInputField(
                        label: 'PMT (Payment)',
                        hint: 'e.g., -3160',
                        value: state.pmt,
                        onChanged: (value) => notifier.updateField('PMT', value),
                        isCurrency: true,
                      ),
                      const SizedBox(height: AppDimensions.spacingM),

                      TVMInputField(
                        label: 'FV (Future Value)',
                        hint: 'e.g., 0',
                        value: state.fv,
                        onChanged: (value) => notifier.updateField('FV', value),
                        isCurrency: true,
                      ),

                      const SizedBox(height: AppDimensions.spacingL),

                      // Helper text
                      Text(
                        'Fill in 4 values, leave 1 blank to solve',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textDisabled,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingXl),

                      // ============ BUTTONS ============
                      Row(
                        children: [
                          Expanded(
                            child: GlassButton(
                              onPressed: notifier.clear,
                              label: 'CLEAR',
                              isPrimary: false,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingM),
                          Expanded(
                            flex: 2,
                            child: GlassButton(
                              onPressed: state.canCalculate
                                  ? notifier.calculate
                                  : null,
                              label: state.canCalculate
                                  ? 'SOLVE ${state.missingVariable}'
                                  : 'ENTER 4 VALUES',
                              isPrimary: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Format the result based on the variable type
  String _formatResult(double value, String? variable) {
    switch (variable) {
      case 'N':
        return value.toStringAsFixed(0); // Whole number
      case 'I/Y':
        return '${value.toStringAsFixed(2)}%';
      case 'PV':
      case 'PMT':
      case 'FV':
        return '\$${value.abs().toStringAsFixed(2)}';
      default:
        return value.toStringAsFixed(2);
    }
  }
}
