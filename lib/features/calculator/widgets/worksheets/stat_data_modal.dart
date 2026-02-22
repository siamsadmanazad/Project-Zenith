import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../providers/worksheets/stat_worksheet_provider.dart';
import '../../../../math_engine/statistics/statistics_engine.dart';

/// Shows the Statistics / Data worksheet modal.
void showStatDataModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusL),
      ),
    ),
    builder: (_) => const _StatDataModal(),
  );
}

class _StatDataModal extends ConsumerStatefulWidget {
  const _StatDataModal();

  @override
  ConsumerState<_StatDataModal> createState() => _StatDataModalState();
}

class _StatDataModalState extends ConsumerState<_StatDataModal> {
  final List<TextEditingController> _xControllers = [];
  final List<TextEditingController> _yControllers = [];

  @override
  void dispose() {
    for (final c in _xControllers) {
      c.dispose();
    }
    for (final c in _yControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncControllers(List<(double, double)> dataPoints) {
    // Add controllers for new data points.
    while (_xControllers.length < dataPoints.length) {
      final i = _xControllers.length;
      _xControllers.add(
        TextEditingController(text: dataPoints[i].$1.toString()),
      );
      _yControllers.add(
        TextEditingController(text: dataPoints[i].$2.toString()),
      );
    }
    // Remove controllers for deleted data points.
    while (_xControllers.length > dataPoints.length) {
      _xControllers.removeLast().dispose();
      _yControllers.removeLast().dispose();
    }
  }

  void _updateControllerTexts(List<(double, double)> dataPoints) {
    for (var i = 0; i < dataPoints.length; i++) {
      final xText = dataPoints[i].$1.toString();
      final yText = dataPoints[i].$2.toString();
      if (_xControllers[i].text != xText) {
        _xControllers[i].text = xText;
      }
      if (_yControllers[i].text != yText) {
        _yControllers[i].text = yText;
      }
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
    final state = ref.watch(statWorksheetProvider);
    _syncControllers(state.dataPoints);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppDimensions.screenPaddingH,
            right: AppDimensions.screenPaddingH,
            top: AppDimensions.spacingM,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                AppDimensions.spacingM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──
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
              const Text(
                'Statistics / Data',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),

              // ── Data Points List ──
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: state.dataPoints.length,
                  itemBuilder: (context, index) {
                    final label =
                        (index + 1).toString().padLeft(2, '0');
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.spacingS,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 36,
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _xControllers[index],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                              decoration:
                                  _fieldDecoration('X${label}'),
                              onChanged: (val) {
                                final x = double.tryParse(val);
                                if (x != null) {
                                  ref
                                      .read(statWorksheetProvider
                                          .notifier)
                                      .updateDataPoint(
                                        index,
                                        x,
                                        state.dataPoints[index].$2,
                                      );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingS),
                          Expanded(
                            child: TextField(
                              controller: _yControllers[index],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                              decoration:
                                  _fieldDecoration('Y${label}'),
                              onChanged: (val) {
                                final y = double.tryParse(val);
                                if (y != null) {
                                  ref
                                      .read(statWorksheetProvider
                                          .notifier)
                                      .updateDataPoint(
                                        index,
                                        state.dataPoints[index].$1,
                                        y,
                                      );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingXs),
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(statWorksheetProvider.notifier)
                                  .deleteDataPoint(index);
                            },
                            child: const Icon(
                              Icons.remove_circle_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppDimensions.spacingS),

              // ── Add / Del / Clear Row ──
              Row(
                children: [
                  _ActionButton(
                    label: 'Add',
                    onTap: () {
                      ref
                          .read(statWorksheetProvider.notifier)
                          .addDataPoint(0, 0);
                    },
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  _ActionButton(
                    label: 'Del',
                    onTap: state.dataPoints.isEmpty
                        ? null
                        : () {
                            ref
                                .read(statWorksheetProvider.notifier)
                                .deleteDataPoint(
                                  state.dataPoints.length - 1,
                                );
                          },
                  ),
                  const Spacer(),
                  _ActionButton(
                    label: 'Clear',
                    onTap: () {
                      ref.read(statWorksheetProvider.notifier).clear();
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // ── Regression Model Chips ──
              const Text(
                'Regression Model',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Row(
                children: RegressionModel.values.map((m) {
                  final selected = state.model == m;
                  return Padding(
                    padding: const EdgeInsets.only(
                      right: AppDimensions.spacingS,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(statWorksheetProvider.notifier)
                            .setModel(m);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingM,
                          vertical: AppDimensions.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.accent.withOpacity(0.15)
                              : AppColors.glassOverlay,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusS),
                          border: Border.all(
                            color: selected
                                ? AppColors.accent.withOpacity(0.3)
                                : AppColors.glassBorder,
                          ),
                        ),
                        child: Text(
                          m.name.toUpperCase(),
                          style: TextStyle(
                            color: selected
                                ? AppColors.accent
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // ── Compute Button ──
              SizedBox(
                width: double.infinity,
                child: _ActionButton(
                  label: 'Compute',
                  onTap: () {
                    ref.read(statWorksheetProvider.notifier).compute();
                  },
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // ── Error ──
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.spacingS,
                  ),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),

              // ── Results ──
              if (state.result != null) _buildResults(state.result!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResults(StatResult r) {
    Widget row(String label, double value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            Text(
              value.toStringAsFixed(6),
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Results',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        row('n', r.n),
        row('x\u0304', r.meanX),
        row('y\u0304', r.meanY),
        row('Sx', r.sX),
        row('Sy', r.sY),
        row('a', r.a),
        row('b', r.b),
        row('r', r.r),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.accent.withOpacity(0.15)
              : AppColors.glassOverlay,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(
            color: enabled
                ? AppColors.accent.withOpacity(0.3)
                : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: enabled ? AppColors.accent : AppColors.textDisabled,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
