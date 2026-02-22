import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../providers/worksheets/profit_worksheet_provider.dart';
import '../../../../math_engine/financial/profit_engine.dart';

/// Shows the Profit Margin worksheet modal.
void showProfitWorksheetModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusL),
      ),
    ),
    builder: (_) => const _ProfitWorksheetModal(),
  );
}

class _ProfitWorksheetModal extends ConsumerStatefulWidget {
  const _ProfitWorksheetModal();

  @override
  ConsumerState<_ProfitWorksheetModal> createState() =>
      _ProfitWorksheetModalState();
}

class _ProfitWorksheetModalState
    extends ConsumerState<_ProfitWorksheetModal> {
  late final TextEditingController _costController;
  late final TextEditingController _sellingController;
  late final TextEditingController _marginController;

  @override
  void initState() {
    super.initState();
    _costController = TextEditingController();
    _sellingController = TextEditingController();
    _marginController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncFromState();
    });
  }

  @override
  void dispose() {
    _costController.dispose();
    _sellingController.dispose();
    _marginController.dispose();
    super.dispose();
  }

  void _syncFromState() {
    final s = ref.read(profitWorksheetProvider);
    _setIfDifferent(_costController, s.cost);
    _setIfDifferent(_sellingController, s.selling);
    _setIfDifferent(_marginController, s.margin);
  }

  void _setIfDifferent(TextEditingController c, double? value) {
    final text = value != null ? value.toString() : '';
    if (c.text != text) {
      c.text = text;
    }
  }

  void _syncFieldToState(String val, void Function(double?) setter) {
    final v = double.tryParse(val);
    setter(v);
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
    final state = ref.watch(profitWorksheetProvider);
    final notifier = ref.read(profitWorksheetProvider.notifier);

    // Sync computed values back into controllers.
    _setIfDifferent(_costController, state.cost);
    _setIfDifferent(_sellingController, state.selling);
    _setIfDifferent(_marginController, state.margin);

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
                  'Profit Margin',
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
                    _sellingController.clear();
                    _marginController.clear();
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

            // ── CST ──
            _VariableRow(
              label: 'CST',
              controller: _costController,
              decoration: _fieldDecoration('Cost'),
              onChanged: (val) =>
                  _syncFieldToState(val, notifier.setCost),
              onCompute: () => notifier.solve(ProfitVariable.cost),
            ),

            // ── SEL ──
            _VariableRow(
              label: 'SEL',
              controller: _sellingController,
              decoration: _fieldDecoration('Selling Price'),
              onChanged: (val) =>
                  _syncFieldToState(val, notifier.setSelling),
              onCompute: () => notifier.solve(ProfitVariable.selling),
            ),

            // ── MAR ──
            _VariableRow(
              label: 'MAR',
              controller: _marginController,
              decoration: _fieldDecoration('Margin %'),
              onChanged: (val) =>
                  _syncFieldToState(val, notifier.setMargin),
              onCompute: () => notifier.solve(ProfitVariable.margin),
            ),

            // ── Markup Result ──
            if (state.markupResult != null)
              Padding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.spacingS,
                  bottom: AppDimensions.spacingM,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.spacingM),
                  decoration: BoxDecoration(
                    color: AppColors.glassOverlay,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Markup %',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        state.markupResult!.toStringAsFixed(4),
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Error ──
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spacingS),
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

class _VariableRow extends StatelessWidget {
  const _VariableRow({
    required this.label,
    required this.controller,
    required this.decoration,
    required this.onChanged,
    required this.onCompute,
  });

  final String label;
  final TextEditingController controller;
  final InputDecoration decoration;
  final ValueChanged<String> onChanged;
  final VoidCallback onCompute;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: decoration,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          GestureDetector(
            onTap: onCompute,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingS + 2,
                vertical: AppDimensions.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.3),
                ),
              ),
              child: const Text(
                'CPT',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
