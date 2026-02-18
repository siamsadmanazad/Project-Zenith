import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../providers/calculator_state.dart';
import 'glass_button.dart';

/// Bottom row with CLR button and P/Y C/Y quick access
class BottomActionRow extends ConsumerWidget {
  const BottomActionRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
      child: Row(
        children: [
          // CLR button
          Expanded(
            child: GlassButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                notifier.clear();
              },
              label: 'CLR',
              isPrimary: false,
              height: 44,
            ),
          ),
          const SizedBox(width: 6),

          // P/Y button
          Expanded(
            child: GlassButton(
              onPressed: () => _showFrequencyEditor(context, ref, 'P/Y'),
              label: 'P/Y',
              isPrimary: false,
              height: 44,
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 6),

          // C/Y button
          Expanded(
            child: GlassButton(
              onPressed: () => _showFrequencyEditor(context, ref, 'C/Y'),
              label: 'C/Y',
              isPrimary: false,
              height: 44,
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFrequencyEditor(BuildContext context, WidgetRef ref, String type) {
    final state = ref.read(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final currentValue = type == 'P/Y' ? state.ppy : state.cpy;

    final options = [1, 2, 4, 12, 24, 52, 365];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusL),
          ),
          border: Border.all(
            color: AppColors.glassBorder,
            width: AppDimensions.glassBorderWidth,
          ),
        ),
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type == 'P/Y' ? 'Payments Per Year' : 'Compounding Per Year',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((value) {
                final isSelected = value == currentValue;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (type == 'P/Y') {
                      notifier.updatePpy(value);
                    } else {
                      notifier.updateCpy(value);
                    }
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent.withOpacity(0.15)
                          : AppColors.glassOverlay,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.glassBorder,
                      ),
                    ),
                    child: Text(
                      _getFrequencyLabel(value),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.spacingL),
          ],
        ),
      ),
    );
  }

  String _getFrequencyLabel(int value) {
    switch (value) {
      case 1:
        return '1 (Annual)';
      case 2:
        return '2 (Semi)';
      case 4:
        return '4 (Quarterly)';
      case 12:
        return '12 (Monthly)';
      case 24:
        return '24 (Bi-monthly)';
      case 52:
        return '52 (Weekly)';
      case 365:
        return '365 (Daily)';
      default:
        return '$value';
    }
  }
}
