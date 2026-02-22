import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../providers/worksheets/amort_worksheet_provider.dart';
import '../../providers/calculator_state.dart';

/// Shows the Amortization worksheet as a modal bottom sheet.
void showAmortWorksheetModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AmortWorksheetModal(),
  );
}

class AmortWorksheetModal extends ConsumerStatefulWidget {
  const AmortWorksheetModal({super.key});

  @override
  ConsumerState<AmortWorksheetModal> createState() => _AmortWorksheetModalState();
}

class _AmortWorksheetModalState extends ConsumerState<AmortWorksheetModal> {
  final _p1Controller = TextEditingController();
  final _p2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(amortWorksheetProvider);
    _p1Controller.text = state.p1.toString();
    _p2Controller.text = state.p2.toString();
  }

  @override
  void dispose() {
    _p1Controller.dispose();
    _p2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amortState = ref.watch(amortWorksheetProvider);
    final amortNotifier = ref.read(amortWorksheetProvider.notifier);
    final calcState = ref.watch(calculatorProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(amortNotifier),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTvmSummary(calcState),
                  const SizedBox(height: AppDimensions.spacingL),
                  _buildPeriodFields(amortNotifier),
                  const SizedBox(height: AppDimensions.spacingL),
                  _buildComputeButton(amortNotifier, calcState),
                  const SizedBox(height: AppDimensions.spacingL),
                  _buildResults(amortState),
                  if (amortState.errorMessage != null) ...[
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      amortState.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.spacingXl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: AppDimensions.spacingS),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.glassBorder,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(AmortWorksheetNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.spacingM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Amortization',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () {
              notifier.clear();
              _p1Controller.text = '1';
              _p2Controller.text = '12';
            },
            child: const Text(
              'CLR',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTvmSummary(CalculatorState calcState) {
    final hasPv = calcState.pv != null;
    final hasPmt = calcState.pmt != null;
    final hasIy = calcState.iy != null;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: AppColors.glassOverlay,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Using TVM values:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          _tvmValueRow('PV', calcState.pv, hasPv),
          _tvmValueRow('PMT', calcState.pmt, hasPmt),
          _tvmValueRow('I/Y', calcState.iy, hasIy),
          _tvmValueRow('P/Y', calcState.ppy.toDouble(), true),
          _tvmValueRow(
            'Mode',
            null,
            true,
            override: calcState.pmtMode == 0 ? 'END' : 'BGN',
          ),
          if (!hasPv || !hasPmt || !hasIy)
            const Padding(
              padding: EdgeInsets.only(top: AppDimensions.spacingS),
              child: Text(
                'Some TVM values are missing. Store PV, PMT, and I/Y first.',
                style: TextStyle(color: AppColors.warning, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tvmValueRow(String label, double? value, bool present, {String? override}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          Text(
            override ?? (present && value != null ? value.toStringAsFixed(2) : '--'),
            style: TextStyle(
              color: present ? AppColors.textPrimary : AppColors.textDisabled,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFields(AmortWorksheetNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: _buildLabeledField(
            label: 'P1 (start)',
            controller: _p1Controller,
            onChanged: (v) {
              final p = int.tryParse(v);
              if (p != null && p > 0) notifier.setP1(p);
            },
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: _buildLabeledField(
            label: 'P2 (end)',
            controller: _p2Controller,
            onChanged: (v) {
              final p = int.tryParse(v);
              if (p != null && p > 0) notifier.setP2(p);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.glassOverlay,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: AppDimensions.spacingS,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              borderSide: const BorderSide(color: AppColors.glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              borderSide: const BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComputeButton(AmortWorksheetNotifier notifier, CalculatorState calcState) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          if (calcState.pv == null || calcState.pmt == null || calcState.iy == null) {
            ref.read(amortWorksheetProvider.notifier).clear();
            // Show error via state
            notifier.compute(
              pv: 0,
              pmt: 0,
              annualRate: 0,
              ppy: calcState.ppy,
              pmtMode: calcState.pmtMode,
            );
            return;
          }
          notifier.compute(
            pv: calcState.pv!,
            pmt: calcState.pmt!,
            annualRate: calcState.iy!,
            ppy: calcState.ppy,
            pmtMode: calcState.pmtMode,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS + 4),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.15),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Compute',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(AmortWorksheetState state) {
    if (state.balResult == null && state.prnResult == null && state.intResult == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.balResult != null) _buildResultRow('BAL', state.balResult!.toStringAsFixed(2)),
        if (state.prnResult != null) _buildResultRow('PRN', state.prnResult!.toStringAsFixed(2)),
        if (state.intResult != null) _buildResultRow('INT', state.intResult!.toStringAsFixed(2)),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
