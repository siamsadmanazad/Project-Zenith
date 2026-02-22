import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../math_engine/financial/depreciation_engine.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../providers/worksheets/depr_worksheet_provider.dart';

/// Shows the Depreciation worksheet as a modal bottom sheet.
void showDeprWorksheetModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const DeprWorksheetModal(),
  );
}

class DeprWorksheetModal extends ConsumerStatefulWidget {
  const DeprWorksheetModal({super.key});

  @override
  ConsumerState<DeprWorksheetModal> createState() => _DeprWorksheetModalState();
}

class _DeprWorksheetModalState extends ConsumerState<DeprWorksheetModal> {
  final _costController = TextEditingController();
  final _salvageController = TextEditingController();
  final _lifeController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(deprWorksheetProvider);
    _costController.text = state.cost == 0 ? '' : state.cost.toString();
    _salvageController.text = state.salvage == 0 ? '' : state.salvage.toString();
    _lifeController.text = state.life == 0 ? '' : state.life.toString();
    _monthController.text = state.startMonth.toString();
    _yearController.text = state.year.toString();
  }

  @override
  void dispose() {
    _costController.dispose();
    _salvageController.dispose();
    _lifeController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deprWorksheetProvider);
    final notifier = ref.read(deprWorksheetProvider.notifier);

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
          _buildHeader(notifier),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputFields(notifier),
                  const SizedBox(height: AppDimensions.spacingL),
                  _buildMethodSelector(state, notifier),
                  const SizedBox(height: AppDimensions.spacingL),
                  _buildComputeButton(notifier),
                  const SizedBox(height: AppDimensions.spacingL),
                  _buildResults(state),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      state.errorMessage!,
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

  Widget _buildHeader(DeprWorksheetNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.spacingM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Depreciation',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () {
              notifier.clear();
              _costController.clear();
              _salvageController.clear();
              _lifeController.clear();
              _monthController.text = '1';
              _yearController.text = '1';
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

  Widget _buildInputFields(DeprWorksheetNotifier notifier) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildLabeledField(
                label: 'CST (Cost)',
                controller: _costController,
                onChanged: (v) {
                  final val = double.tryParse(v);
                  if (val != null) notifier.setCost(val);
                },
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: _buildLabeledField(
                label: 'SAL (Salvage)',
                controller: _salvageController,
                onChanged: (v) {
                  final val = double.tryParse(v);
                  if (val != null) notifier.setSalvage(val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildLabeledField(
                label: 'LIF (Life, years)',
                controller: _lifeController,
                onChanged: (v) {
                  final val = double.tryParse(v);
                  if (val != null) notifier.setLife(val);
                },
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: _buildLabeledField(
                label: 'MON (Start month)',
                controller: _monthController,
                onChanged: (v) {
                  final val = int.tryParse(v);
                  if (val != null && val >= 1 && val <= 12) {
                    notifier.setStartMonth(val);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildLabeledField(
                label: 'YR (Year to compute)',
                controller: _yearController,
                onChanged: (v) {
                  final val = int.tryParse(v);
                  if (val != null && val >= 1) notifier.setYear(val);
                },
              ),
            ),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodSelector(DeprWorksheetState state, DeprWorksheetNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Method',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Row(
          children: [
            _buildChip(
              label: 'SL',
              selected: state.method == DepreciationMethod.sl,
              onTap: () => notifier.setMethod(DepreciationMethod.sl),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            _buildChip(
              label: 'SYD',
              selected: state.method == DepreciationMethod.syd,
              onTap: () => notifier.setMethod(DepreciationMethod.syd),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            _buildChip(
              label: 'DB',
              selected: state.method == DepreciationMethod.db,
              onTap: () => notifier.setMethod(DepreciationMethod.db),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComputeButton(DeprWorksheetNotifier notifier) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: notifier.compute,
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

  Widget _buildResults(DeprWorksheetState state) {
    if (state.dep == null && state.rbv == null && state.rdv == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.dep != null) _buildResultRow('DEP', state.dep!.toStringAsFixed(2)),
        if (state.rbv != null) _buildResultRow('RBV', state.rbv!.toStringAsFixed(2)),
        if (state.rdv != null) _buildResultRow('RDV', state.rdv!.toStringAsFixed(2)),
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

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withOpacity(0.15) : AppColors.glassOverlay,
          border: Border.all(
            color: selected ? AppColors.accent.withOpacity(0.3) : AppColors.glassBorder,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.accent : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
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
}
