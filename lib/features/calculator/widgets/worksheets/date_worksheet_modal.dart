import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../providers/worksheets/date_worksheet_provider.dart';
import '../../../../math_engine/financial/date_engine.dart';

/// Shows the Date worksheet modal.
void showDateWorksheetModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusL),
      ),
    ),
    builder: (_) => const _DateWorksheetModal(),
  );
}

class _DateWorksheetModal extends ConsumerStatefulWidget {
  const _DateWorksheetModal();

  @override
  ConsumerState<_DateWorksheetModal> createState() =>
      _DateWorksheetModalState();
}

class _DateWorksheetModalState extends ConsumerState<_DateWorksheetModal> {
  final TextEditingController _daysController = TextEditingController();
  static final DateFormat _dateFmt = DateFormat('MM/dd/yyyy');

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    BuildContext context, {
    required DateTime? current,
    required ValueChanged<DateTime?> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
      filled: true,
      fillColor: AppColors.glassOverlay,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingS,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: const BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dateWorksheetProvider);

    // Sync days controller when state changes externally.
    if (_daysController.text != state.addDaysValue.toString() &&
        !_daysController.text.endsWith('-') &&
        _daysController.text != '-') {
      final stateText = state.addDaysValue.toString();
      if (_daysController.text.isEmpty && state.addDaysValue == 0) {
        // Leave empty if user hasn't typed yet.
      } else if (_daysController.text != stateText) {
        // Only sync on external changes, not while user is typing.
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.screenPaddingH,
        right: AppDimensions.screenPaddingH,
        top: AppDimensions.spacingM,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + AppDimensions.spacingM,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle ──
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Title ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Date Worksheet',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ref.read(dateWorksheetProvider.notifier).clear();
                    _daysController.clear();
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // ── DT1 ──
            const Text(
              'DT1',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            _DatePickerButton(
              label: state.date1 != null
                  ? _dateFmt.format(state.date1!)
                  : 'Select Date',
              onTap: () => _pickDate(
                context,
                current: state.date1,
                onPicked: (d) =>
                    ref.read(dateWorksheetProvider.notifier).setDate1(d),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),

            // ── DT2 ──
            const Text(
              'DT2',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            _DatePickerButton(
              label: state.date2 != null
                  ? _dateFmt.format(state.date2!)
                  : 'Select Date',
              onTap: () => _pickDate(
                context,
                current: state.date2,
                onPicked: (d) =>
                    ref.read(dateWorksheetProvider.notifier).setDate2(d),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),

            // ── Day Count Toggle ──
            const Text(
              'Day Count Method',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              children: [
                _ChipButton(
                  label: 'ACT',
                  selected: state.dayCount == DayCountMethod.actual,
                  onTap: () => ref
                      .read(dateWorksheetProvider.notifier)
                      .setDayCount(DayCountMethod.actual),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                _ChipButton(
                  label: '360',
                  selected: state.dayCount == DayCountMethod.days360,
                  onTap: () => ref
                      .read(dateWorksheetProvider.notifier)
                      .setDayCount(DayCountMethod.days360),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),

            // ── Compute DBD ──
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                label: 'Compute DBD',
                onTap: () {
                  ref.read(dateWorksheetProvider.notifier).computeDaysBetween();
                },
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),

            // ── Days Between Result ──
            if (state.daysBetween != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Days Between',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      state.daysBetween.toString(),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            const Divider(color: AppColors.glassBorder, height: 32),

            // ── Date +/- Days Section ──
            const Text(
              'Date \u00B1 Days',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              'DT1: ${state.date1 != null ? _dateFmt.format(state.date1!) : "Not set"}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),

            // ── Days Input ──
            const Text(
              'Days',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            TextField(
              controller: _daysController,
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: _fieldDecoration('Enter days'),
              onChanged: (val) {
                final days = int.tryParse(val);
                if (days != null) {
                  ref
                      .read(dateWorksheetProvider.notifier)
                      .setAddDaysValue(days);
                }
              },
            ),
            const SizedBox(height: AppDimensions.spacingM),

            // ── Compute Date ──
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                label: 'Compute Date',
                onTap: () {
                  ref.read(dateWorksheetProvider.notifier).computeAddDays();
                },
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),

            // ── Result Date ──
            if (state.resultDate != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Result Date',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _dateFmt.format(state.resultDate!),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Error ──
            if (state.errorMessage != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
              ),

            const SizedBox(height: AppDimensions.spacingM),
          ],
        ),
      ),
    );
  }
}

// ── Reusable private widgets ──────────────────────────────────────────────────

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.glassOverlay,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withOpacity(0.15)
              : AppColors.glassOverlay,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(
            color: selected
                ? AppColors.accent.withOpacity(0.3)
                : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.accent : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
