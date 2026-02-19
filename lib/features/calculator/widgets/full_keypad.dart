// Full TI BA II Plus Keypad — all 10 rows, ~40 keys
//
// Phase 1 functional wiring:
//   digits, decimal, +/-, backspace, ENTER
//   TVM keys (N, I/Y, PV, PMT, FV): store or compute (CPT mode)
//   CPT, CE|C, ON/OFF
//   2ND + → = CLR TVM
//   2ND + IRR = BGN/END toggle
//   2ND + CF = P/Y modal
//   All others = "— coming soon" status flash

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../providers/calculator_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Key action enum
// ─────────────────────────────────────────────────────────────────────────────

enum _KeyAction {
  digit0,
  digit1,
  digit2,
  digit3,
  digit4,
  digit5,
  digit6,
  digit7,
  digit8,
  digit9,
  decimal,
  toggleSign,
  backspace,
  enter,
  keyN,
  keyIY,
  keyPV,
  keyPMT,
  keyFV,
  twoNd,
  cpt,
  onOff,
  ceC,
  unimplemented,
}

// ─────────────────────────────────────────────────────────────────────────────
// Key definition
// ─────────────────────────────────────────────────────────────────────────────

class _KeyDef {
  final String primary;
  final String? secondary; // gold label shown above primary when 2ND active
  final _KeyAction action;
  final bool isTvmKey;
  final bool isCtrlKey;

  const _KeyDef({
    required this.primary,
    this.secondary,
    required this.action,
    this.isTvmKey = false,
    this.isCtrlKey = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout — 10 rows matching physical TI BA II Plus
// ─────────────────────────────────────────────────────────────────────────────

// ROW 1 (5 keys): CPT | ENTER | ↑ | ↓ | ON
const List<_KeyDef> _row1 = [
  _KeyDef(
      primary: 'CPT',
      secondary: 'QUIT',
      action: _KeyAction.cpt,
      isCtrlKey: true),
  _KeyDef(
      primary: 'ENTER',
      secondary: 'SET',
      action: _KeyAction.enter,
      isCtrlKey: true),
  _KeyDef(primary: '↑', secondary: 'DEL', action: _KeyAction.unimplemented),
  _KeyDef(primary: '↓', secondary: 'INS', action: _KeyAction.unimplemented),
  _KeyDef(
      primary: 'ON',
      secondary: 'OFF',
      action: _KeyAction.onOff,
      isCtrlKey: true),
];

// ROW 2 (5 keys): 2ND | CF | NPV | IRR | →
const List<_KeyDef> _row2 = [
  _KeyDef(primary: '2ND', action: _KeyAction.twoNd, isCtrlKey: true),
  _KeyDef(
      primary: 'CF', secondary: 'P·Y', action: _KeyAction.unimplemented),
  _KeyDef(
      primary: 'NPV',
      secondary: 'AMORT',
      action: _KeyAction.unimplemented),
  _KeyDef(
      primary: 'IRR', secondary: 'BGN', action: _KeyAction.unimplemented),
  _KeyDef(
      primary: '→',
      secondary: 'CLR TVM',
      action: _KeyAction.backspace,
      isCtrlKey: true),
];

// ROW 3 (5 keys): N | I/Y | PV | PMT | FV  ← TVM row
const List<_KeyDef> _row3 = [
  _KeyDef(primary: 'N', action: _KeyAction.keyN, isTvmKey: true),
  _KeyDef(primary: 'I/Y', action: _KeyAction.keyIY, isTvmKey: true),
  _KeyDef(primary: 'PV', action: _KeyAction.keyPV, isTvmKey: true),
  _KeyDef(primary: 'PMT', action: _KeyAction.keyPMT, isTvmKey: true),
  _KeyDef(primary: 'FV', action: _KeyAction.keyFV, isTvmKey: true),
];

// ROW 4 (5 keys): % | √x | x² | 1/x | ÷
const List<_KeyDef> _row4 = [
  _KeyDef(primary: '%', secondary: 'HYP', action: _KeyAction.unimplemented),
  _KeyDef(
      primary: '√x', secondary: 'SIN', action: _KeyAction.unimplemented),
  _KeyDef(
      primary: 'x²', secondary: 'COS', action: _KeyAction.unimplemented),
  _KeyDef(
      primary: '1/x', secondary: 'TAN', action: _KeyAction.unimplemented),
  _KeyDef(primary: '÷', secondary: 'x!', action: _KeyAction.unimplemented),
];

// ROW 5 (5 keys): INV | ( | ) | yˣ | ×
const List<_KeyDef> _row5 = [
  _KeyDef(
      primary: 'INV', secondary: 'eˣ', action: _KeyAction.unimplemented),
  _KeyDef(
      primary: '(', secondary: 'DATA', action: _KeyAction.unimplemented),
  _KeyDef(
      primary: ')', secondary: 'STAT', action: _KeyAction.unimplemented),
  _KeyDef(
      primary: 'yˣ', secondary: 'BOND', action: _KeyAction.unimplemented),
  _KeyDef(
      primary: '×', secondary: 'nPr', action: _KeyAction.unimplemented),
];

// ROW 6 (4 keys): 7 | 8 | 9 | -
const List<_KeyDef> _row6 = [
  _KeyDef(primary: '7', secondary: 'DEPR', action: _KeyAction.digit7),
  _KeyDef(primary: '8', secondary: 'Δ%', action: _KeyAction.digit8),
  _KeyDef(primary: '9', secondary: 'BRKEVN', action: _KeyAction.digit9),
  _KeyDef(primary: '-', secondary: 'nCr', action: _KeyAction.unimplemented),
];

// ROW 7 (4 keys): 4 | 5 | 6 | +
const List<_KeyDef> _row7 = [
  _KeyDef(primary: '4', secondary: 'DATE', action: _KeyAction.digit4),
  _KeyDef(primary: '5', secondary: 'ICONV', action: _KeyAction.digit5),
  _KeyDef(primary: '6', secondary: 'PROFIT', action: _KeyAction.digit6),
  _KeyDef(
      primary: '+', secondary: 'ANS', action: _KeyAction.unimplemented),
];

// ROW 8 (4 keys): 1 | 2 | 3 | =
const List<_KeyDef> _row8 = [
  _KeyDef(primary: '1', secondary: 'MEM', action: _KeyAction.digit1),
  _KeyDef(primary: '2', secondary: 'FORMAT', action: _KeyAction.digit2),
  _KeyDef(primary: '3', secondary: 'RESET', action: _KeyAction.digit3),
  _KeyDef(primary: '=', action: _KeyAction.enter, isCtrlKey: true),
];

// ROW 9 (4 keys): ROUND | LN | STO | RCL
const List<_KeyDef> _row9 = [
  _KeyDef(primary: 'ROUND', action: _KeyAction.unimplemented),
  _KeyDef(
      primary: 'LN', secondary: 'eˣ', action: _KeyAction.unimplemented),
  _KeyDef(primary: 'STO', action: _KeyAction.unimplemented),
  _KeyDef(
      primary: 'RCL',
      secondary: 'CLR WORK',
      action: _KeyAction.unimplemented),
];

// ROW 10 (4 keys): 0 | . | +/- | CE|C
const List<_KeyDef> _row10 = [
  _KeyDef(primary: '0', secondary: 'MEM', action: _KeyAction.digit0),
  _KeyDef(primary: '.', secondary: 'FORMAT', action: _KeyAction.decimal),
  _KeyDef(primary: '+/-', secondary: '±', action: _KeyAction.toggleSign),
  _KeyDef(primary: 'CE|C', action: _KeyAction.ceC, isCtrlKey: true),
];

// ─────────────────────────────────────────────────────────────────────────────
// FullKeypad widget
// ─────────────────────────────────────────────────────────────────────────────

class FullKeypad extends ConsumerWidget {
  const FullKeypad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildRow(context, ref, _row1),
        const SizedBox(height: 4),
        _buildRow(context, ref, _row2),
        const SizedBox(height: 4),
        _buildRow(context, ref, _row3),
        const SizedBox(height: 4),
        _buildRow(context, ref, _row4),
        const SizedBox(height: 4),
        _buildRow(context, ref, _row5),
        const SizedBox(height: 4),
        _buildRow(context, ref, _row6),
        const SizedBox(height: 4),
        _buildRow(context, ref, _row7),
        const SizedBox(height: 4),
        _buildRow(context, ref, _row8),
        const SizedBox(height: 4),
        _buildRow(context, ref, _row9),
        const SizedBox(height: 4),
        _buildRow(context, ref, _row10),
      ],
    );
  }

  Widget _buildRow(
      BuildContext context, WidgetRef ref, List<_KeyDef> keys) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < keys.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: _FullKey(
                keyDef: keys[i],
                onTap: () => _dispatch(context, ref, keys[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Action dispatcher ─────────────────────────────────────────────────────

  void _dispatch(BuildContext context, WidgetRef ref, _KeyDef key) {
    final notifier = ref.read(calculatorProvider.notifier);
    final state = ref.read(calculatorProvider);

    HapticFeedback.lightImpact();

    // 2ND key always just toggles
    if (key.action == _KeyAction.twoNd) {
      notifier.toggle2nd();
      return;
    }

    // ── 2ND function dispatch ──────────────────────────────────────────────
    if (state.twoNdActive) {
      // 2ND + → = CLR TVM
      if (key.primary == '→') {
        notifier.clearTVM();
        return;
      }
      // 2ND + IRR = BGN/END toggle
      if (key.primary == 'IRR') {
        notifier.updatePmtMode(state.pmtMode == 0 ? 1 : 0);
        notifier.toggle2nd();
        return;
      }
      // 2ND + CF = P/Y modal
      if (key.primary == 'CF') {
        notifier.toggle2nd();
        _showPYModal(context, ref);
        return;
      }
      // Other keys with a secondary label → "coming soon"
      if (key.secondary != null && key.secondary!.isNotEmpty) {
        notifier.toggle2nd();
        notifier.setStatusMessage('${key.secondary} — coming soon');
        return;
      }
      // No secondary label → cancel 2ND and fall through to primary action
      notifier.toggle2nd();
    }

    // ── Primary dispatch ───────────────────────────────────────────────────
    switch (key.action) {
      case _KeyAction.digit0:
        notifier.appendDigit('0');
      case _KeyAction.digit1:
        notifier.appendDigit('1');
      case _KeyAction.digit2:
        notifier.appendDigit('2');
      case _KeyAction.digit3:
        notifier.appendDigit('3');
      case _KeyAction.digit4:
        notifier.appendDigit('4');
      case _KeyAction.digit5:
        notifier.appendDigit('5');
      case _KeyAction.digit6:
        notifier.appendDigit('6');
      case _KeyAction.digit7:
        notifier.appendDigit('7');
      case _KeyAction.digit8:
        notifier.appendDigit('8');
      case _KeyAction.digit9:
        notifier.appendDigit('9');

      case _KeyAction.decimal:
        notifier.appendDecimal();

      case _KeyAction.toggleSign:
        notifier.toggleSign();

      case _KeyAction.backspace:
        notifier.backspace();

      case _KeyAction.enter:
        final s = ref.read(calculatorProvider);
        if (s.activeVariable != null && s.displayBuffer.isNotEmpty) {
          notifier.storeTVMVariable(s.activeVariable!);
        }

      case _KeyAction.keyN:
        final s = ref.read(calculatorProvider);
        if (s.cptMode) {
          notifier.computeVariable('N');
        } else {
          notifier.storeTVMVariable('N');
        }

      case _KeyAction.keyIY:
        final s = ref.read(calculatorProvider);
        if (s.cptMode) {
          notifier.computeVariable('I/Y');
        } else {
          notifier.storeTVMVariable('I/Y');
        }

      case _KeyAction.keyPV:
        final s = ref.read(calculatorProvider);
        if (s.cptMode) {
          notifier.computeVariable('PV');
        } else {
          notifier.storeTVMVariable('PV');
        }

      case _KeyAction.keyPMT:
        final s = ref.read(calculatorProvider);
        if (s.cptMode) {
          notifier.computeVariable('PMT');
        } else {
          notifier.storeTVMVariable('PMT');
        }

      case _KeyAction.keyFV:
        final s = ref.read(calculatorProvider);
        if (s.cptMode) {
          notifier.computeVariable('FV');
        } else {
          notifier.storeTVMVariable('FV');
        }

      case _KeyAction.cpt:
        notifier.enterCptMode();

      case _KeyAction.ceC:
        notifier.clearEntry();

      case _KeyAction.onOff:
        notifier.clearEntry();

      case _KeyAction.twoNd:
        break; // handled above

      case _KeyAction.unimplemented:
        notifier.setStatusMessage('${key.primary} — coming soon');
    }
  }

  // ── P/Y modal ─────────────────────────────────────────────────────────────

  void _showPYModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      builder: (_) => _PYModal(outerRef: ref),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// P/Y selector modal
// ─────────────────────────────────────────────────────────────────────────────

class _PYModal extends ConsumerWidget {
  final WidgetRef outerRef;
  const _PYModal({required this.outerRef});

  static const _options = [1, 2, 4, 12, 24, 52, 365];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingM,
        AppDimensions.spacingM,
        AppDimensions.spacingM,
        AppDimensions.spacingM + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payments per Year (P/Y)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _options.map((v) {
              final selected = state.ppy == v;
              return GestureDetector(
                onTap: () {
                  notifier.updatePpy(v);
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accentSecondary.withOpacity(0.2)
                        : AppColors.glassOverlay,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(
                      color: selected
                          ? AppColors.accentSecondary
                          : AppColors.glassBorder,
                    ),
                  ),
                  child: Text(
                    '$v',
                    style: TextStyle(
                      color: selected
                          ? AppColors.accentSecondary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.spacingS),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual key button
// ─────────────────────────────────────────────────────────────────────────────

class _FullKey extends ConsumerStatefulWidget {
  final _KeyDef keyDef;
  final VoidCallback onTap;

  const _FullKey({required this.keyDef, required this.onTap});

  @override
  ConsumerState<_FullKey> createState() => _FullKeyState();
}

class _FullKeyState extends ConsumerState<_FullKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculatorProvider);
    final key = widget.keyDef;

    // ── Resolve color scheme ────────────────────────────────────────────────
    Color borderColor = AppColors.glassBorder;
    double borderWidth = 0.5;
    Color bgColor = AppColors.glassOverlay;
    Color primaryColor = AppColors.textPrimary;

    final bool is2NdKey = key.action == _KeyAction.twoNd;
    final bool isCptKey = key.action == _KeyAction.cpt;

    if (is2NdKey && state.twoNdActive) {
      borderColor = AppColors.accentSecondary;
      borderWidth = 1.5;
      bgColor = AppColors.accentSecondary.withOpacity(0.15);
      primaryColor = AppColors.accentSecondary;
    } else if (isCptKey && state.cptMode) {
      borderColor = AppColors.accentSecondary;
      borderWidth = 1.5;
      bgColor = AppColors.accentSecondary.withOpacity(0.10);
      primaryColor = AppColors.accentSecondary;
    } else if (key.isTvmKey && state.activeVariable == key.primary) {
      // TVM key currently focused
      borderColor = AppColors.accent;
      borderWidth = 1.5;
      bgColor = AppColors.accent.withOpacity(0.10);
      primaryColor = AppColors.accent;
    } else if (key.isTvmKey && state.cptMode) {
      // TVM key while CPT mode is active
      borderColor = AppColors.accentSecondary.withOpacity(0.5);
      borderWidth = 1.0;
      primaryColor = AppColors.accentSecondary;
    } else if (state.twoNdActive &&
        !is2NdKey &&
        key.secondary != null &&
        key.secondary!.isNotEmpty) {
      // 2ND active and this key has a secondary — dim the primary label
      primaryColor = AppColors.textPrimary.withOpacity(0.4);
    }

    // Secondary label opacity: bright when 2ND is active, dim otherwise
    final double secOpacity =
        state.twoNdActive && !is2NdKey ? 1.0 : 0.35;

    // Value dot: TVM keys that have a stored value
    final bool showDot = key.isTvmKey && _hasValue(state, key.primary);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border:
                    Border.all(color: borderColor, width: borderWidth),
              ),
              child: Stack(
                children: [
                  // Secondary (2ND function) label — top-left, gold, 7px
                  if (key.secondary != null && key.secondary!.isNotEmpty)
                    Positioned(
                      top: 2,
                      left: 3,
                      child: Opacity(
                        opacity: secOpacity,
                        child: Text(
                          key.secondary!,
                          style: const TextStyle(
                            fontSize: 7,
                            color: AppColors.accentSecondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                  // Value dot — top-right, for TVM keys with stored value
                  if (showDot)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.accentSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                  // Primary label — centered
                  Center(
                    child: Text(
                      key.primary,
                      style: TextStyle(
                        fontSize: _fontSize(key.primary),
                        color: primaryColor,
                        fontWeight: key.isCtrlKey || key.isTvmKey
                            ? FontWeight.w600
                            : FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _hasValue(CalculatorState state, String variable) {
    switch (variable) {
      case 'N':
        return state.n != null;
      case 'I/Y':
        return state.iy != null;
      case 'PV':
        return state.pv != null;
      case 'PMT':
        return state.pmt != null;
      case 'FV':
        return state.fv != null;
      default:
        return false;
    }
  }

  double _fontSize(String label) {
    if (label.length <= 2) return 13;
    if (label.length <= 4) return 11;
    return 9;
  }
}
