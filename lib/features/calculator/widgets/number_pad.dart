import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../providers/calculator_state.dart';

/// 4x4 number pad grid matching BA II Plus layout
/// [ 7 ] [ 8 ] [ 9 ] [  <-  ]
/// [ 4 ] [ 5 ] [ 6 ] [ +/- ]
/// [ 1 ] [ 2 ] [ 3 ] [  .  ]
/// [     0     ] [BGN/END] [CPT]
class NumberPad extends ConsumerWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
      child: Column(
        children: [
          // Row 1: 7, 8, 9, Backspace
          Row(
            children: [
              _numKey('7', () => notifier.appendDigit('7')),
              _numKey('8', () => notifier.appendDigit('8')),
              _numKey('9', () => notifier.appendDigit('9')),
              _actionKey(
                Icons.backspace_outlined,
                null,
                () => notifier.backspace(),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Row 2: 4, 5, 6, +/-
          Row(
            children: [
              _numKey('4', () => notifier.appendDigit('4')),
              _numKey('5', () => notifier.appendDigit('5')),
              _numKey('6', () => notifier.appendDigit('6')),
              _actionKey(null, '+/\u2212', () => notifier.toggleSign()),
            ],
          ),
          const SizedBox(height: 6),

          // Row 3: 1, 2, 3, .
          Row(
            children: [
              _numKey('1', () => notifier.appendDigit('1')),
              _numKey('2', () => notifier.appendDigit('2')),
              _numKey('3', () => notifier.appendDigit('3')),
              _actionKey(null, '.', () => notifier.appendDecimal()),
            ],
          ),
          const SizedBox(height: 6),

          // Row 4: 0 (double-wide), BGN/END, CPT
          Row(
            children: [
              // 0 key — spans 2 columns
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _KeypadButton(
                    label: '0',
                    onTap: () => notifier.appendDigit('0'),
                    hapticType: HapticType.light,
                  ),
                ),
              ),
              // BGN/END toggle
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _KeypadButton(
                    label: state.pmtMode == 1 ? 'BGN' : 'END',
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.updatePmtMode(state.pmtMode == 0 ? 1 : 0);
                    },
                    isSpecial: true,
                    isHighlighted: state.pmtMode == 1,
                    hapticType: HapticType.medium,
                  ),
                ),
              ),
              // CPT key
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _KeypadButton(
                    label: 'CPT',
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.enterCptMode();
                    },
                    isSpecial: true,
                    isHighlighted: state.cptMode,
                    accentColor: state.cptMode
                        ? AppColors.accentSecondary
                        : null,
                    hapticType: HapticType.medium,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numKey(String digit, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: _KeypadButton(
          label: digit,
          onTap: onTap,
          hapticType: HapticType.light,
        ),
      ),
    );
  }

  Widget _actionKey(IconData? icon, String? label, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: _KeypadButton(
          label: label,
          icon: icon,
          onTap: onTap,
          isSpecial: true,
          hapticType: HapticType.light,
        ),
      ),
    );
  }
}

enum HapticType { light, medium }

class _KeypadButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isSpecial;
  final bool isHighlighted;
  final Color? accentColor;
  final HapticType hapticType;

  const _KeypadButton({
    this.label,
    this.icon,
    required this.onTap,
    this.isSpecial = false,
    this.isHighlighted = false,
    this.accentColor,
    this.hapticType = HapticType.light,
  });

  @override
  State<_KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<_KeypadButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _scaleController.forward();
        if (widget.hapticType == HapticType.light) {
          HapticFeedback.lightImpact();
        }
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _scaleController.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _scaleController.reverse();
      },
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 52,
              decoration: BoxDecoration(
                color: _isPressed
                    ? AppColors.glassOverlay.withOpacity(0.25)
                    : widget.isHighlighted
                        ? (widget.accentColor ?? AppColors.accent)
                            .withOpacity(0.15)
                        : AppColors.glassOverlay,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(
                  color: widget.isHighlighted
                      ? (widget.accentColor ?? AppColors.accent)
                      : AppColors.glassBorder,
                  width: widget.isHighlighted ? 1.5 : 0.5,
                ),
              ),
              child: Center(
                child: widget.icon != null
                    ? Icon(
                        widget.icon,
                        size: 20,
                        color: AppColors.textSecondary,
                      )
                    : Text(
                        widget.label ?? '',
                        style: TextStyle(
                          fontSize: widget.isSpecial ? 13 : 20,
                          fontWeight: widget.isSpecial
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: widget.isHighlighted
                              ? (widget.accentColor ?? AppColors.accent)
                              : widget.isSpecial
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                          letterSpacing: widget.isSpecial ? 0.8 : 0,
                          fontFeatures: widget.isSpecial
                              ? null
                              : const [FontFeature.tabularFigures()],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
