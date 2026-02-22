import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../math_engine/financial/cash_flow_engine.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../providers/worksheets/cf_worksheet_provider.dart';

/// Shows the Cash Flow worksheet as a modal bottom sheet.
void showCfWorksheetModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CfWorksheetModal(),
  );
}

class CfWorksheetModal extends ConsumerStatefulWidget {
  const CfWorksheetModal({super.key});

  @override
  ConsumerState<CfWorksheetModal> createState() => _CfWorksheetModalState();
}

class _CfWorksheetModalState extends ConsumerState<CfWorksheetModal> {
  final _iRateController = TextEditingController();
  final _amountController = TextEditingController();
  final _freqController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    final state = ref.read(cfWorksheetProvider);
    _iRateController.text = state.iRate == 0 ? '' : state.iRate.toString();
  }

  @override
  void dispose() {
    _iRateController.dispose();
    _amountController.dispose();
    _freqController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cfWorksheetProvider);
    final notifier = ref.read(cfWorksheetProvider.notifier);

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
                  _buildCashFlowList(state, notifier),
                  const SizedBox(height: AppDimensions.spacingM),
                  _buildAddCashFlowRow(notifier),
                  const SizedBox(height: AppDimensions.spacingL),
                  _buildIRateField(notifier),
                  const SizedBox(height: AppDimensions.spacingL),
                  _buildComputeRow(notifier),
                  const SizedBox(height: AppDimensions.spacingM),
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

  Widget _buildHeader(CfWorksheetNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.spacingM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Cash Flow Worksheet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () {
              notifier.clear();
              _iRateController.clear();
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

  Widget _buildCashFlowList(CfWorksheetState state, CfWorksheetNotifier notifier) {
    if (state.cashFlows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
        child: Text(
          'No cash flows added yet.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.cashFlows.length,
      itemBuilder: (context, index) {
        final cf = state.cashFlows[index];
        final label = index == 0 ? 'CF0' : 'CF$index / F$index';
        return _CashFlowTile(
          label: label,
          entry: cf,
          showFrequency: index > 0,
          onUpdate: (amount, freq) => notifier.updateCashFlow(index, amount, freq),
          onDelete: index > 0 ? () => notifier.deleteCashFlow(index) : null,
        );
      },
    );
  }

  Widget _buildAddCashFlowRow(CfWorksheetNotifier notifier) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildTextField(
            controller: _amountController,
            hint: 'Amount',
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Expanded(
          flex: 2,
          child: _buildTextField(
            controller: _freqController,
            hint: 'Freq',
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        _buildActionButton(
          label: 'Add CF',
          onTap: () {
            final amount = double.tryParse(_amountController.text) ?? 0;
            final freq = int.tryParse(_freqController.text) ?? 1;
            notifier.addCashFlow(amount, freq);
            _amountController.clear();
            _freqController.text = '1';
          },
        ),
      ],
    );
  }

  Widget _buildIRateField(CfWorksheetNotifier notifier) {
    return Row(
      children: [
        const Text(
          'I  ',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: _buildTextField(
            controller: _iRateController,
            hint: 'Discount rate %',
            onChanged: (v) {
              final rate = double.tryParse(v);
              if (rate != null) notifier.setIRate(rate);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComputeRow(CfWorksheetNotifier notifier) {
    return Row(
      children: [
        Expanded(child: _buildActionButton(label: 'NPV', onTap: notifier.computeNpv)),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(child: _buildActionButton(label: 'IRR', onTap: notifier.computeIrr)),
      ],
    );
  }

  Widget _buildResults(CfWorksheetState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.npvResult != null)
          _buildResultRow('NPV', state.npvResult!.toStringAsFixed(2)),
        if (state.irrResult != null)
          _buildResultRow('IRR', '${state.irrResult!.toStringAsFixed(4)}%'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
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
    );
  }

  Widget _buildActionButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS + 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.15),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Inline tile for a single cash flow entry with editable fields.
class _CashFlowTile extends StatefulWidget {
  final String label;
  final CashFlowEntry entry;
  final bool showFrequency;
  final void Function(double amount, int freq) onUpdate;
  final VoidCallback? onDelete;

  const _CashFlowTile({
    required this.label,
    required this.entry,
    required this.showFrequency,
    required this.onUpdate,
    this.onDelete,
  });

  @override
  State<_CashFlowTile> createState() => _CashFlowTileState();
}

class _CashFlowTileState extends State<_CashFlowTile> {
  late final TextEditingController _amtCtrl;
  late final TextEditingController _freqCtrl;

  @override
  void initState() {
    super.initState();
    _amtCtrl = TextEditingController(text: widget.entry.amount.toString());
    _freqCtrl = TextEditingController(text: widget.entry.frequency.toString());
  }

  @override
  void didUpdateWidget(covariant _CashFlowTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.amount != widget.entry.amount) {
      _amtCtrl.text = widget.entry.amount.toString();
    }
    if (oldWidget.entry.frequency != widget.entry.frequency) {
      _freqCtrl.text = widget.entry.frequency.toString();
    }
  }

  @override
  void dispose() {
    _amtCtrl.dispose();
    _freqCtrl.dispose();
    super.dispose();
  }

  void _commit() {
    final amt = double.tryParse(_amtCtrl.text) ?? widget.entry.amount;
    final freq = int.tryParse(_freqCtrl.text) ?? widget.entry.frequency;
    widget.onUpdate(amt, freq);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              widget.label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _amtCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              onChanged: (_) => _commit(),
              decoration: _tileInputDecoration('Amount'),
            ),
          ),
          if (widget.showFrequency) ...[
            const SizedBox(width: AppDimensions.spacingXs),
            SizedBox(
              width: 56,
              child: TextField(
                controller: _freqCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                onChanged: (_) => _commit(),
                decoration: _tileInputDecoration('F'),
              ),
            ),
          ],
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: AppColors.error),
              onPressed: widget.onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  InputDecoration _tileInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 12),
      filled: true,
      fillColor: AppColors.glassOverlay,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingXs + 2,
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
    );
  }
}
