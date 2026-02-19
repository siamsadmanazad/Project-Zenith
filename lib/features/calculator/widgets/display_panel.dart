import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/number_formatter.dart';
import '../providers/calculator_state.dart';

/// Glassmorphic display panel — the BA II Plus screen reimagined
class DisplayPanel extends ConsumerWidget {
  const DisplayPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final displayText = _getDisplayText(state);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              color: AppColors.glassOverlay,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              border: Border.all(
                color: AppColors.glassBorder,
                width: AppDimensions.glassBorderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.glassShadow,
                  blurRadius: AppDimensions.glassShadowBlur,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Top row: settings indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Variable chip
                    if (state.activeVariable != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: state.cptMode
                              ? AppColors.accentSecondary.withOpacity(0.2)
                              : AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                          border: Border.all(
                            color: state.cptMode
                                ? AppColors.accentSecondary.withOpacity(0.5)
                                : AppColors.accent.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          state.activeVariable!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: state.cptMode
                                ? AppColors.accentSecondary
                                : AppColors.accent,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    // 2ND, P/Y, C/Y, END/BGN indicators
                    Row(
                      children: [
                        if (state.twoNdActive) ...[
                          _IndicatorChip(
                            label: '2ND',
                            isActive: true,
                          ),
                          const SizedBox(width: 6),
                        ],
                        _IndicatorChip(
                          label: 'P/Y=${state.ppy}',
                        ),
                        const SizedBox(width: 6),
                        _IndicatorChip(
                          label: 'C/Y=${state.cpy}',
                        ),
                        const SizedBox(width: 6),
                        _IndicatorChip(
                          label: state.pmtMode == 1 ? 'BGN' : 'END',
                          isActive: state.pmtMode == 1,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingM),

                // Main number display
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                      color: state.result != null
                          ? AppColors.accent
                          : AppColors.textPrimary,
                      letterSpacing: -1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    maxLines: 1,
                  ),
                )
                    .animate(key: ValueKey(state.result ?? state.displayBuffer))
                    .fadeIn(duration: 200.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.0, 1.0),
                      duration: 250.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: AppDimensions.spacingS),

                // Status line
                SizedBox(
                  height: 16,
                  child: state.statusMessage != null
                      ? Text(
                          state.statusMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            color: state.cptMode
                                ? AppColors.accentSecondary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        )
                      : state.errorMessage != null
                          ? Text(
                              state.errorMessage!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDisplayText(CalculatorState state) {
    // If there's a result being shown on display
    if (state.result != null && state.displayBuffer.isNotEmpty) {
      return NumberFormatter.formatBuffer(state.displayBuffer);
    }
    // If user is typing
    if (state.displayBuffer.isNotEmpty) {
      return NumberFormatter.formatBuffer(state.displayBuffer);
    }
    // Default
    return '0';
  }
}

/// Small indicator chip for settings display
class _IndicatorChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _IndicatorChip({
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.accentSecondary.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: isActive
              ? AppColors.accentSecondary
              : AppColors.textDisabled,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
