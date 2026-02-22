import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../providers/worksheets/brkevn_worksheet_provider.dart';
import '../../../../math_engine/financial/breakeven_engine.dart';

/// Shows the Break-Even worksheet modal.
void showBrkevnWorksheetModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusL),
      ),
    ),
    builder: (_) => const _BrkevnWorksheetModal(),
  );
}

class _BrkevnWorksheetModal extends ConsumerStatefulWidget {
  const _BrkevnWorksheetModal();

  @override
  ConsumerState<_BrkevnWorksheetModal> createState() =>
      _BrkevnWorksheetModalState();
}

class _BrkevnWorksheetModalState
    extends ConsumerState<_BrkevnWorksheetModal> {
  late final TextEditingController _fcController;
  late final TextEditingController _vcController;
  late final TextEditingController _priceController;
  late final TextEditingController _profitController;
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _fcController = TextEditingController();
    _vcController = TextEditingController();
    _priceController = TextEditingController();
    _profitController = TextEditingController();
    _quantityController = TextEditingController();

    // Populate from current state after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncFromState();
    });
  }

  @override
  void dispose() {
    _fcController.dispose();
    _vcController.dispose();
    _priceController.dispose();
    _profitController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _syncFromState() {
    final s = ref.read(brkevnWorksheetProvider);
    _setIfDifferent(_fcController, s.fc);
    _setIfDifferent(_vcController, s.vc);
    _setIfDifferent(_priceController, s.price);
    _setIfDifferent(_profitController, s.profit);
    _setIfDifferent(_quantityController, s.quantity);
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
    final state = ref.watch(brkevnWorksheetProvider);
    final notifier = ref.read(brkevnWorksheetProvider.notifier);

    // Sync computed values back into controllers.
    _setIfDifferent(_fcController, state.fc);
    _setIfDifferent(_vcController, state.vc);
    _setIfDifferent(_priceController, state.price);
    _setIfDifferent(_profitController, state.profit);
    _setIfDifferent(_quantityController, state.quantity);

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
                  'Break-Even',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    notifier.clear();
                    _fcController.clear();
                    _vcController.clear();
                    _priceController.clear();
                    _profitController.clear();
                    _quantityController.clear();
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

            // ── FC ──
            _VariableRow(
              label: 'FC',
              hint: 'Fixed Cost',
              controller: _fcController,
              decoration: _fieldDecoration('Fixed Cost'),
              onChanged: (val) =>
                  _syncFieldToState(val, notifier.setFc),
              onCompute: () => notifier.solve(BreakevenVariable.fixedCost),
            ),

            // ── VC ──
            _VariableRow(
              label: 'VC',
              hint: 'Variable Cost',
              controller: _vcController,
              decoration: _fieldDecoration('Variable Cost'),
              onChanged: (val) =>
                  _syncFieldToState(val, notifier.setVc),
              onCompute: () =>
                  notifier.solve(BreakevenVariable.variableCost),
            ),

            // ── P ──
            _VariableRow(
              label: 'P',
              hint: 'Price',
              controller: _priceController,
              decoration: _fieldDecoration('Price'),
              onChanged: (val) =>
                  _syncFieldToState(val, notifier.setPrice),
              onCompute: () => notifier.solve(BreakevenVariable.price),
            ),

            // ── PFT ──
            _VariableRow(
              label: 'PFT',
              hint: 'Profit',
              controller: _profitController,
              decoration: _fieldDecoration('Profit'),
              onChanged: (val) =>
                  _syncFieldToState(val, notifier.setProfit),
              onCompute: () => notifier.solve(BreakevenVariable.profit),
            ),

            // ── Q ──
            _VariableRow(
              label: 'Q',
              hint: 'Quantity',
              controller: _quantityController,
              decoration: _fieldDecoration('Quantity'),
              onChanged: (val) =>
                  _syncFieldToState(val, notifier.setQuantity),
              onCompute: () =>
                  notifier.solve(BreakevenVariable.quantity),
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
    required this.hint,
    required this.controller,
    required this.decoration,
    required this.onChanged,
    required this.onCompute,
  });

  final String label;
  final String hint;
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
