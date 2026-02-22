import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../providers/worksheets/bond_worksheet_provider.dart';

/// Shows the Bond worksheet as a modal bottom sheet.
void showBondWorksheetModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const BondWorksheetModal(),
  );
}

class BondWorksheetModal extends ConsumerStatefulWidget {
  const BondWorksheetModal({super.key});

  @override
  ConsumerState<BondWorksheetModal> createState() => _BondWorksheetModalState();
}

class _BondWorksheetModalState extends ConsumerState<BondWorksheetModal> {
  final _cpnController = TextEditingController();
  final _rvController = TextEditingController();
  final _yldController = TextEditingController();
  final _priController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(bondWorksheetProvider);
    _cpnController.text = state.cpn == 0 ? '' : state.cpn.toString();
    _rvController.text = state.rv.toString();
    if (state.yld != null) _yldController.text = state.yld.toString();
    if (state.pri != null) _priController.text = state.pri.toString();
  }

  @override
  void dispose() {
    _cpnController.dispose();
    _rvController.dispose();
    _yldController.dispose();
    _priController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bondWorksheetProvider);
    final notifier = ref.read(bondWorksheetProvider.notifier);

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
                  _buildDateRow(state, notifier),
                  const SizedBox(height: AppDimensions.spacingM),
                  _buildCpnAndRvRow(notifier),
                  const SizedBox(height: AppDimensions.spacingM),
                  _buildFreqSelector(state, notifier),
                  const SizedBox(height: AppDimensions.spacingM),
                  _buildDayCountToggle(state, notifier),
                  const SizedBox(height: AppDimensions.spacingL),
                  _buildYldAndPriFields(state, notifier),
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

  Widget _buildHeader(BondWorksheetNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.spacingM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Bond Worksheet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () {
              notifier.clear();
              _cpnController.clear();
              _rvController.text = '100';
              _yldController.clear();
              _priController.clear();
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

  Widget _buildDateRow(BondWorksheetState state, BondWorksheetNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(
            label: 'SDT (Settlement)',
            value: state.sdt,
            onPicked: (d) => notifier.setSdt(d),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: _buildDatePicker(
            label: 'RDT (Redemption)',
            value: state.rdt,
            onPicked: (d) => notifier.setRdt(d),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onPicked,
  }) {
    final display = value != null
        ? '${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}/${value.year}'
        : 'Select';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
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
            if (picked != null) onPicked(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: AppDimensions.spacingS + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.glassOverlay,
              border: Border.all(color: AppColors.glassBorder),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Text(
              display,
              style: TextStyle(
                color: value != null ? AppColors.textPrimary : AppColors.textDisabled,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCpnAndRvRow(BondWorksheetNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: _buildLabeledField(
            label: 'CPN (Coupon %)',
            controller: _cpnController,
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) notifier.setCpn(val);
            },
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: _buildLabeledField(
            label: 'RV (Redemption)',
            controller: _rvController,
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) notifier.setRv(val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFreqSelector(BondWorksheetState state, BondWorksheetNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Coupon Frequency',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Row(
          children: [
            _buildChip(
              label: '1/Y',
              selected: state.freq == 1,
              onTap: () => notifier.setFreq(1),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            _buildChip(
              label: '2/Y',
              selected: state.freq == 2,
              onTap: () => notifier.setFreq(2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDayCountToggle(BondWorksheetState state, BondWorksheetNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Day Count',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Row(
          children: [
            _buildChip(
              label: 'ACT',
              selected: state.dayCount == 0,
              onTap: () => notifier.setDayCount(0),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            _buildChip(
              label: '360',
              selected: state.dayCount == 1,
              onTap: () => notifier.setDayCount(1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildYldAndPriFields(BondWorksheetState state, BondWorksheetNotifier notifier) {
    // Sync controllers when state changes from compute
    if (state.yld != null && _yldController.text != state.yld.toString()) {
      _yldController.text = state.yld!.toStringAsFixed(4);
    }
    if (state.pri != null && _priController.text != state.pri.toString()) {
      _priController.text = state.pri!.toStringAsFixed(4);
    }

    return Row(
      children: [
        Expanded(
          child: _buildLabeledField(
            label: 'YLD (Yield %)',
            controller: _yldController,
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) notifier.setYld(val);
            },
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: _buildLabeledField(
            label: 'PRI (Price)',
            controller: _priController,
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) notifier.setPri(val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComputeRow(BondWorksheetNotifier notifier) {
    return Row(
      children: [
        Expanded(child: _buildActionButton(label: 'Price', onTap: notifier.computePrice)),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(child: _buildActionButton(label: 'Yield', onTap: notifier.computeYield)),
      ],
    );
  }

  Widget _buildResults(BondWorksheetState state) {
    if (state.ai == null && state.pri == null && state.yld == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.ai != null) _buildResultRow('AI', state.ai!.toStringAsFixed(4)),
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

  Widget _buildActionButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS + 4),
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
