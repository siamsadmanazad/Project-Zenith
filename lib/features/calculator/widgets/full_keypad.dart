// Full TI BA II Plus Keypad — all 10 rows, ~40 keys
//
// Functional wiring:
//   All digits, decimal, +/-, backspace, ENTER, =
//   TVM keys (N, I/Y, PV, PMT, FV): store or compute (CPT mode)
//   Arithmetic: +, -, ×, ÷, (, ), =
//   Math: √x, x², 1/x, LN, yˣ, %, INV
//   Trig (2ND): SIN, COS, TAN, HYP
//   Combinatorics (2ND): x!, nPr, nCr
//   Memory: STO, RCL, ANS, MEM
//   Utility: ROUND, FORMAT, RESET
//   Financial: Δ%, ICONV (modal)
//   Control: CPT, CE|C, ON/OFF, 2ND, CLR TVM, BGN, P/Y

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../math_engine/financial/interest_conversion.dart';
import '../providers/calculator_state.dart';
import 'worksheets/cf_worksheet_modal.dart';
import 'worksheets/amort_worksheet_modal.dart';
import 'worksheets/bond_worksheet_modal.dart';
import 'worksheets/depr_worksheet_modal.dart';
import 'worksheets/stat_data_modal.dart';
import 'worksheets/date_worksheet_modal.dart';
import 'worksheets/brkevn_worksheet_modal.dart';
import 'worksheets/profit_worksheet_modal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Key action enum
// ─────────────────────────────────────────────────────────────────────────────

enum _KeyAction {
  digit0, digit1, digit2, digit3, digit4,
  digit5, digit6, digit7, digit8, digit9,
  decimal,
  toggleSign,
  backspace,
  enter,
  equals,
  keyN, keyIY, keyPV, keyPMT, keyFV,
  twoNd,
  cpt,
  onOff,
  ceC,
  // Arithmetic
  opAdd, opSubtract, opMultiply, opDivide,
  openParen, closeParen,
  // Math functions
  sqrtX, xSquared, reciprocal, ln, yPowerX, percent,
  inv,
  // Memory
  sto, rcl, round_,
  // Worksheet navigation
  arrowUp, arrowDown, cf, npv, irr,
}

// ─────────────────────────────────────────────────────────────────────────────
// Key category enum — drives Layer 1 resting tints
// ─────────────────────────────────────────────────────────────────────────────

enum _KeyCategory {
  digit,
  tvm,
  operator_,
  function,
  control,
  clear,
  special2nd,
}

// ─────────────────────────────────────────────────────────────────────────────
// Key definition
// ─────────────────────────────────────────────────────────────────────────────

class _KeyDef {
  final String primary;
  final String? secondary;
  final _KeyAction action;
  final bool isTvmKey;
  final bool isCtrlKey;
  final _KeyCategory category;

  const _KeyDef({
    required this.primary,
    this.secondary,
    required this.action,
    this.isTvmKey = false,
    this.isCtrlKey = false,
    this.category = _KeyCategory.function,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout — 10 rows matching physical TI BA II Plus
// ─────────────────────────────────────────────────────────────────────────────

// ROW 1: CPT | ENTER | ↑ | ↓ | ON
const List<_KeyDef> _row1 = [
  _KeyDef(primary: 'CPT', secondary: 'QUIT', action: _KeyAction.cpt,
      isCtrlKey: true, category: _KeyCategory.control),
  _KeyDef(primary: 'ENTER', secondary: 'SET', action: _KeyAction.enter,
      isCtrlKey: true, category: _KeyCategory.control),
  _KeyDef(primary: '↑', secondary: 'DEL', action: _KeyAction.arrowUp,
      category: _KeyCategory.function),
  _KeyDef(primary: '↓', secondary: 'INS', action: _KeyAction.arrowDown,
      category: _KeyCategory.function),
  _KeyDef(primary: 'ON', secondary: 'OFF', action: _KeyAction.onOff,
      isCtrlKey: true, category: _KeyCategory.clear),
];

// ROW 2: 2ND | CF | NPV | IRR | →
const List<_KeyDef> _row2 = [
  _KeyDef(primary: '2ND', action: _KeyAction.twoNd, isCtrlKey: true,
      category: _KeyCategory.special2nd),
  _KeyDef(primary: 'CF', secondary: 'P·Y', action: _KeyAction.cf,
      category: _KeyCategory.function),
  _KeyDef(primary: 'NPV', secondary: 'AMORT', action: _KeyAction.npv,
      category: _KeyCategory.function),
  _KeyDef(primary: 'IRR', secondary: 'BGN', action: _KeyAction.irr,
      category: _KeyCategory.function),
  _KeyDef(primary: '→', secondary: 'CLR TVM', action: _KeyAction.backspace,
      isCtrlKey: true, category: _KeyCategory.clear),
];

// ROW 3: N | I/Y | PV | PMT | FV
const List<_KeyDef> _row3 = [
  _KeyDef(primary: 'N', action: _KeyAction.keyN, isTvmKey: true,
      category: _KeyCategory.tvm),
  _KeyDef(primary: 'I/Y', action: _KeyAction.keyIY, isTvmKey: true,
      category: _KeyCategory.tvm),
  _KeyDef(primary: 'PV', action: _KeyAction.keyPV, isTvmKey: true,
      category: _KeyCategory.tvm),
  _KeyDef(primary: 'PMT', action: _KeyAction.keyPMT, isTvmKey: true,
      category: _KeyCategory.tvm),
  _KeyDef(primary: 'FV', action: _KeyAction.keyFV, isTvmKey: true,
      category: _KeyCategory.tvm),
];

// ROW 4: % | √x | x² | 1/x | ÷
const List<_KeyDef> _row4 = [
  _KeyDef(primary: '%', secondary: 'HYP', action: _KeyAction.percent,
      category: _KeyCategory.function),
  _KeyDef(primary: '√x', secondary: 'SIN', action: _KeyAction.sqrtX,
      category: _KeyCategory.function),
  _KeyDef(primary: 'x²', secondary: 'COS', action: _KeyAction.xSquared,
      category: _KeyCategory.function),
  _KeyDef(primary: '1/x', secondary: 'TAN', action: _KeyAction.reciprocal,
      category: _KeyCategory.function),
  _KeyDef(primary: '÷', secondary: 'x!', action: _KeyAction.opDivide,
      category: _KeyCategory.operator_),
];

// ROW 5: INV | ( | ) | yˣ | ×
const List<_KeyDef> _row5 = [
  _KeyDef(primary: 'INV', secondary: 'eˣ', action: _KeyAction.inv,
      category: _KeyCategory.function),
  _KeyDef(primary: '(', secondary: 'DATA', action: _KeyAction.openParen,
      category: _KeyCategory.function),
  _KeyDef(primary: ')', secondary: 'STAT', action: _KeyAction.closeParen,
      category: _KeyCategory.function),
  _KeyDef(primary: 'yˣ', secondary: 'BOND', action: _KeyAction.yPowerX,
      category: _KeyCategory.function),
  _KeyDef(primary: '×', secondary: 'nPr', action: _KeyAction.opMultiply,
      category: _KeyCategory.operator_),
];

// ROW 6: 7 | 8 | 9 | -
const List<_KeyDef> _row6 = [
  _KeyDef(primary: '7', secondary: 'DEPR', action: _KeyAction.digit7,
      category: _KeyCategory.digit),
  _KeyDef(primary: '8', secondary: 'Δ%', action: _KeyAction.digit8,
      category: _KeyCategory.digit),
  _KeyDef(primary: '9', secondary: 'BRKEVN', action: _KeyAction.digit9,
      category: _KeyCategory.digit),
  _KeyDef(primary: '-', secondary: 'nCr', action: _KeyAction.opSubtract,
      category: _KeyCategory.operator_),
];

// ROW 7: 4 | 5 | 6 | +
const List<_KeyDef> _row7 = [
  _KeyDef(primary: '4', secondary: 'DATE', action: _KeyAction.digit4,
      category: _KeyCategory.digit),
  _KeyDef(primary: '5', secondary: 'ICONV', action: _KeyAction.digit5,
      category: _KeyCategory.digit),
  _KeyDef(primary: '6', secondary: 'PROFIT', action: _KeyAction.digit6,
      category: _KeyCategory.digit),
  _KeyDef(primary: '+', secondary: 'ANS', action: _KeyAction.opAdd,
      category: _KeyCategory.operator_),
];

// ROW 8: 1 | 2 | 3 | =
const List<_KeyDef> _row8 = [
  _KeyDef(primary: '1', secondary: 'MEM', action: _KeyAction.digit1,
      category: _KeyCategory.digit),
  _KeyDef(primary: '2', secondary: 'FORMAT', action: _KeyAction.digit2,
      category: _KeyCategory.digit),
  _KeyDef(primary: '3', secondary: 'RESET', action: _KeyAction.digit3,
      category: _KeyCategory.digit),
  _KeyDef(primary: '=', action: _KeyAction.equals, isCtrlKey: true,
      category: _KeyCategory.operator_),
];

// ROW 9: ROUND | LN | STO | RCL
const List<_KeyDef> _row9 = [
  _KeyDef(primary: 'ROUND', action: _KeyAction.round_,
      category: _KeyCategory.function),
  _KeyDef(primary: 'LN', secondary: 'eˣ', action: _KeyAction.ln,
      category: _KeyCategory.function),
  _KeyDef(primary: 'STO', action: _KeyAction.sto,
      category: _KeyCategory.function),
  _KeyDef(primary: 'RCL', secondary: 'CLR WORK', action: _KeyAction.rcl,
      category: _KeyCategory.function),
];

// ROW 10: 0 | . | +/- | CE|C
const List<_KeyDef> _row10 = [
  _KeyDef(primary: '0', secondary: 'MEM', action: _KeyAction.digit0,
      category: _KeyCategory.digit),
  _KeyDef(primary: '.', secondary: 'FORMAT', action: _KeyAction.decimal,
      category: _KeyCategory.digit),
  _KeyDef(primary: '+/-', secondary: '±', action: _KeyAction.toggleSign,
      category: _KeyCategory.digit),
  _KeyDef(primary: 'CE|C', action: _KeyAction.ceC, isCtrlKey: true,
      category: _KeyCategory.clear),
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

  Widget _buildRow(BuildContext context, WidgetRef ref, List<_KeyDef> keys) {
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

    // STO/RCL mode intercept — digits handled inside appendDigit,
    // non-digit cancels mode
    if ((state.stoMode || state.rclMode) &&
        !_isDigitAction(key.action) &&
        key.action != _KeyAction.twoNd) {
      notifier.cancelMemoryMode();
      // Fall through to normal dispatch
    }

    // FORMAT mode intercept — digits handled inside appendDigit,
    // non-digit cancels
    if (state.formatMode &&
        !_isDigitAction(key.action) &&
        key.action != _KeyAction.twoNd) {
      notifier.cancelMemoryMode();
    }

    // 2ND key always just toggles
    if (key.action == _KeyAction.twoNd) {
      notifier.toggle2nd();
      return;
    }

    // ── 2ND function dispatch ──────────────────────────────────────────────
    if (state.twoNdActive) {
      notifier.toggle2nd(); // consume 2ND

      switch (key.primary) {
        // Row 1
        case 'CPT':  // QUIT — exit worksheet (placeholder)
          notifier.setStatusMessage('QUIT');
          return;
        case 'ENTER': // SET — placeholder
          notifier.setStatusMessage('SET — coming soon');
          return;
        case '↑': // DEL — remove current entry in CF/DATA worksheet
          if (state.activeWorksheet != null) {
            notifier.setStatusMessage('DEL — open worksheet to delete entry');
          } else {
            notifier.setStatusMessage('DEL — no active worksheet');
          }
          return;
        case '↓': // INS — insert entry in CF/DATA worksheet
          if (state.activeWorksheet != null) {
            notifier.setStatusMessage('INS — open worksheet to insert entry');
          } else {
            notifier.setStatusMessage('INS — no active worksheet');
          }
          return;

        // Row 2
        case '→': // CLR TVM
          notifier.clearTVM();
          return;
        case 'IRR': // BGN/END toggle
          notifier.updatePmtMode(state.pmtMode == 0 ? 1 : 0);
          return;
        case 'CF': // P/Y modal
          _showPYModal(context, ref);
          return;
        case 'NPV': // AMORT — amortization worksheet
          showAmortWorksheetModal(context);
          return;

        // Row 4 — trig / HYP / factorial
        case '%': // HYP toggle
          notifier.toggleHyp();
          return;
        case '√x': // SIN
          notifier.trigFunction('sin');
          return;
        case 'x²': // COS
          notifier.trigFunction('cos');
          return;
        case '1/x': // TAN
          notifier.trigFunction('tan');
          return;
        case '÷': // x!
          notifier.factorial();
          return;

        // Row 5 — eˣ / DATA / STAT / BOND / nPr
        case 'INV': // eˣ
          notifier.expX();
          return;
        case '(': // DATA — statistics data entry worksheet
          showStatDataModal(context);
          return;
        case ')': // STAT — statistics compute worksheet
          showStatDataModal(context);
          return;
        case 'yˣ': // BOND — bond worksheet
          showBondWorksheetModal(context);
          return;
        case '×': // nPr
          notifier.nPrOperator();
          return;

        // Row 6 — DEPR / Δ% / BRKEVN / nCr
        case '7': // DEPR — depreciation worksheet
          showDeprWorksheetModal(context);
          return;
        case '8': // Δ%
          notifier.enterDeltaPercent();
          return;
        case '9': // BRKEVN — break-even worksheet
          showBrkevnWorksheetModal(context);
          return;
        case '-': // nCr
          notifier.nCrOperator();
          return;

        // Row 7 — DATE / ICONV / PROFIT / ANS
        case '4': // DATE — date worksheet
          showDateWorksheetModal(context);
          return;
        case '5': // ICONV
          _showIConvModal(context, ref);
          return;
        case '6': // PROFIT — profit margin worksheet
          showProfitWorksheetModal(context);
          return;
        case '+': // ANS
          notifier.recallAns();
          return;

        // Row 8 — MEM / FORMAT / RESET
        case '1': // MEM
          notifier.showMemStatus();
          return;
        case '2': // FORMAT
          notifier.enterFormatMode();
          return;
        case '3': // RESET
          notifier.reset();
          return;

        // Row 9 — eˣ (2ND+LN) / CLR WORK (2ND+RCL)
        case 'LN': // eˣ
          notifier.expX();
          return;
        case 'RCL': // CLR WORK — deactivate active worksheet
          if (state.activeWorksheet != null) {
            notifier.setActiveWorksheet(null);
            notifier.setStatusMessage('WORK CLEARED');
          } else {
            notifier.setStatusMessage('CLR WORK — no active worksheet');
          }
          return;

        // Row 10 — MEM (2ND+0) / FORMAT (2ND+.)
        case '0': // MEM
          notifier.showMemStatus();
          return;
        case '.': // FORMAT
          notifier.enterFormatMode();
          return;
      }

      // Fallback for any unhandled 2ND combo
      if (key.secondary != null && key.secondary!.isNotEmpty) {
        notifier.setStatusMessage('${key.secondary} — coming soon');
      }
      return;
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
        // ENTER stores into active TVM variable
        final s = ref.read(calculatorProvider);
        if (s.activeVariable != null && s.displayBuffer.isNotEmpty) {
          notifier.storeTVMVariable(s.activeVariable!);
        }

      case _KeyAction.equals:
        // = triggers arithmetic evaluation
        if (state.deltaPercentMode) {
          notifier.enterDeltaPercent(); // computes Δ% result
        } else {
          notifier.pressEquals();
        }

      // Arithmetic operators
      case _KeyAction.opAdd:
        notifier.pressOperator('+');
      case _KeyAction.opSubtract:
        notifier.pressOperator('-');
      case _KeyAction.opMultiply:
        notifier.pressOperator('*');
      case _KeyAction.opDivide:
        notifier.pressOperator('/');

      case _KeyAction.openParen:
        notifier.openParen();
      case _KeyAction.closeParen:
        notifier.closeParen();

      // Math functions
      case _KeyAction.sqrtX:
        notifier.sqrtX();
      case _KeyAction.xSquared:
        notifier.xSquared();
      case _KeyAction.reciprocal:
        notifier.reciprocal();
      case _KeyAction.ln:
        notifier.naturalLog();
      case _KeyAction.yPowerX:
        notifier.yPowerX();
      case _KeyAction.percent:
        notifier.percent();
      case _KeyAction.inv:
        notifier.toggleInv();

      // Memory
      case _KeyAction.sto:
        notifier.enterStoMode();
      case _KeyAction.rcl:
        notifier.enterRclMode();
      case _KeyAction.round_:
        notifier.roundDisplay();

      // TVM
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

      // Worksheet navigation
      case _KeyAction.arrowUp:
        if (state.activeWorksheet != null) {
          notifier.setStatusMessage('↑ — use worksheet UI to navigate');
        } else {
          notifier.setStatusMessage('↑ — no active worksheet');
        }
      case _KeyAction.arrowDown:
        if (state.activeWorksheet != null) {
          notifier.setStatusMessage('↓ — use worksheet UI to navigate');
        } else {
          notifier.setStatusMessage('↓ — no active worksheet');
        }

      // Worksheet openers
      case _KeyAction.cf:
        showCfWorksheetModal(context);
      case _KeyAction.npv:
        showCfWorksheetModal(context); // NPV computed inside CF modal
      case _KeyAction.irr:
        showCfWorksheetModal(context); // IRR computed inside CF modal

      case _KeyAction.twoNd:
        break; // handled above
    }
  }

  bool _isDigitAction(_KeyAction action) {
    return action == _KeyAction.digit0 ||
        action == _KeyAction.digit1 ||
        action == _KeyAction.digit2 ||
        action == _KeyAction.digit3 ||
        action == _KeyAction.digit4 ||
        action == _KeyAction.digit5 ||
        action == _KeyAction.digit6 ||
        action == _KeyAction.digit7 ||
        action == _KeyAction.digit8 ||
        action == _KeyAction.digit9;
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

  // ── ICONV modal ───────────────────────────────────────────────────────────

  void _showIConvModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      builder: (_) => _IConvModal(outerRef: ref),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accentSecondary.withOpacity(0.2)
                        : AppColors.glassOverlay,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusS),
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
// ICONV modal — Interest Conversion (Nominal ↔ Effective)
// ─────────────────────────────────────────────────────────────────────────────

class _IConvModal extends ConsumerStatefulWidget {
  final WidgetRef outerRef;
  const _IConvModal({required this.outerRef});

  @override
  ConsumerState<_IConvModal> createState() => _IConvModalState();
}

class _IConvModalState extends ConsumerState<_IConvModal> {
  final _nomController = TextEditingController();
  final _effController = TextEditingController();
  String? _result;

  @override
  void dispose() {
    _nomController.dispose();
    _effController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculatorProvider);

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
            'Interest Conversion',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'C/Y = ${state.cpy}',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          _buildField('Nominal Rate (%)', _nomController),
          const SizedBox(height: 12),
          _buildField('Effective Rate (%)', _effController),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildButton('NOM → EFF', () {
                  final nom = double.tryParse(_nomController.text);
                  if (nom == null) return;
                  final eff =
                      InterestConversion.nominalToEffective(nom, state.cpy);
                  _effController.text = eff.toStringAsFixed(4);
                  setState(() => _result = 'EFF = ${eff.toStringAsFixed(4)}%');
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildButton('EFF → NOM', () {
                  final eff = double.tryParse(_effController.text);
                  if (eff == null) return;
                  final nom =
                      InterestConversion.effectiveToNominal(eff, state.cpy);
                  _nomController.text = nom.toStringAsFixed(4);
                  setState(() => _result = 'NOM = ${nom.toStringAsFixed(4)}%');
                }),
              ),
            ],
          ),
          if (_result != null) ...[
            const SizedBox(height: 12),
            Text(
              _result!,
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.spacingS),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.glassBorder),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.accent),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        filled: true,
        fillColor: AppColors.glassOverlay,
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
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

  void _haptic() {
    switch (widget.keyDef.category) {
      case _KeyCategory.digit:      HapticService.digit();
      case _KeyCategory.tvm:        HapticService.tvm();
      case _KeyCategory.operator_:  HapticService.operator_();
      case _KeyCategory.function:   HapticService.function_();
      case _KeyCategory.control:    HapticService.function_();
      case _KeyCategory.clear:      HapticService.clear();
      case _KeyCategory.special2nd: HapticService.function_();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculatorProvider);
    final key = widget.keyDef;

    // ── LAYER 1: Category base colours (resting) ─────────────────────────────
    Color borderColor;
    double borderWidth = 0.5;
    Color bgColor;
    Color primaryColor;

    switch (key.category) {
      case _KeyCategory.digit:
        bgColor = AppColors.keyDigitBg;
        borderColor = AppColors.keyDigitBorder;
        primaryColor = AppColors.textPrimary;
      case _KeyCategory.tvm:
        bgColor = AppColors.keyTvmBg;
        borderColor = AppColors.keyTvmBorder;
        primaryColor = AppColors.textPrimary;
      case _KeyCategory.operator_:
        bgColor = AppColors.keyOperatorBg;
        borderColor = AppColors.keyOperatorBorder;
        primaryColor = AppColors.keyOperatorText;
      case _KeyCategory.function:
        bgColor = AppColors.keyFunctionBg;
        borderColor = AppColors.keyFunctionBorder;
        primaryColor = AppColors.keyFunctionText;
      case _KeyCategory.control:
        bgColor = AppColors.keyControlBg;
        borderColor = AppColors.keyControlBorder;
        primaryColor = AppColors.textPrimary;
      case _KeyCategory.clear:
        bgColor = AppColors.keyClearBg;
        borderColor = AppColors.keyClearBorder;
        primaryColor = AppColors.keyClearText;
      case _KeyCategory.special2nd:
        bgColor = AppColors.key2NdBg;
        borderColor = AppColors.key2NdBorder;
        primaryColor = AppColors.textPrimary;
    }

    // ── LAYER 2: Active-state overrides ───────────────────────────────────
    final bool is2NdKey = key.action == _KeyAction.twoNd;
    final bool isCptKey = key.action == _KeyAction.cpt;
    final bool isInvKey = key.action == _KeyAction.inv;

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
    } else if (isInvKey && state.invActive) {
      borderColor = AppColors.accent;
      borderWidth = 1.5;
      bgColor = AppColors.accent.withOpacity(0.10);
      primaryColor = AppColors.accent;
    } else if (key.isTvmKey && state.activeVariable == key.primary) {
      borderColor = AppColors.accent;
      borderWidth = 1.5;
      bgColor = AppColors.accent.withOpacity(0.10);
      primaryColor = AppColors.accent;
    } else if (key.isTvmKey && state.cptMode) {
      borderColor = AppColors.accentSecondary.withOpacity(0.5);
      borderWidth = 1.0;
      primaryColor = AppColors.accentSecondary;
    } else if (state.twoNdActive &&
        !is2NdKey &&
        key.secondary != null &&
        key.secondary!.isNotEmpty) {
      primaryColor = AppColors.textPrimary.withOpacity(0.4);
    }

    final double secOpacity = state.twoNdActive && !is2NdKey ? 1.0 : 0.35;
    final bool showDot = key.isTvmKey && _hasValue(state, key.primary);

    return GestureDetector(
      onTapDown: (_) {
        _haptic();
        setState(() => _pressed = true);
      },
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
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: Stack(
                children: [
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
