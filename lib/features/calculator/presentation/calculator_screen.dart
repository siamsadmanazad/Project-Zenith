import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../providers/calculator_state.dart';
import '../widgets/tvm_input_field.dart';
import '../widgets/glass_button.dart';

/// Form-based Calculator Screen — Quick entry mode with text fields
/// (Renamed from CalculatorScreen to FormCalculatorScreen)
class FormCalculatorScreen extends ConsumerWidget {
  const FormCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final theme = Theme.of(context);

    return Container(
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

                    // ============ PAYMENT TIMING + P/Y + C/Y ============
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingM,
                        vertical: AppDimensions.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.glassOverlay,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        border: Border.all(
                          color: AppColors.glassBorder,
                          width: AppDimensions.glassBorderWidth,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Payment timing row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment Timing',
                                style: theme.textTheme.bodyMedium,
                              ),
                              SegmentedButton<int>(
                                segments: const [
                                  ButtonSegment<int>(
                                    value: 0,
                                    label: Text('END'),
                                  ),
                                  ButtonSegment<int>(
                                    value: 1,
                                    label: Text('BGN'),
                                  ),
                                ],
                                selected: {state.pmtMode},
                                onSelectionChanged: (Set<int> selected) {
                                  notifier.updatePmtMode(selected.first);
                                },
                                style: const ButtonStyle(
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ],
                          ),

                          const Divider(
                            color: AppColors.glassBorder,
                            height: AppDimensions.spacingL,
                          ),

                          // P/Y and C/Y row
                          Row(
                            children: [
                              Expanded(
                                child: _FrequencyDropdown(
                                  label: 'P/Y',
                                  value: state.ppy,
                                  onChanged: (v) => notifier.updatePpy(v),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacingM),
                              Expanded(
                                child: _FrequencyDropdown(
                                  label: 'C/Y',
                                  value: state.cpy,
                                  onChanged: (v) => notifier.updateCpy(v),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingM),

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
    );
  }

  /// Format the result based on the variable type
  String _formatResult(double value, String? variable) {
    switch (variable) {
      case 'N':
        return value.toStringAsFixed(2);
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

/// Dropdown for P/Y and C/Y frequency selection
class _FrequencyDropdown extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _FrequencyDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  static const _options = [1, 2, 4, 12, 24, 52, 365];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.glassOverlay,
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              items: _options.map((v) {
                return DropdownMenuItem(
                  value: v,
                  child: Text('$v'),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
