import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../providers/calculator_state.dart';

/// Row of 5 TVM keys: N, I/Y, PV, PMT, FV
/// Mirrors the BA II Plus third row but with glassmorphic styling
class TVMKeyRow extends ConsumerWidget {
  const TVMKeyRow({super.key});

  static const _variables = ['N', 'I/Y', 'PV', 'PMT', 'FV'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
      child: Row(
        children: _variables.map((variable) {
          final hasValue = state.getVariable(variable) != null;
          final isActive = state.activeVariable == variable;
          final isCptMode = state.cptMode;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _TVMKey(
                label: variable,
                hasValue: hasValue,
                isActive: isActive,
                isCptMode: isCptMode,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (isCptMode) {
                    notifier.computeVariable(variable);
                  } else {
                    notifier.storeTVMVariable(variable);
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TVMKey extends StatefulWidget {
  final String label;
  final bool hasValue;
  final bool isActive;
  final bool isCptMode;
  final VoidCallback onTap;

  const _TVMKey({
    required this.label,
    required this.hasValue,
    required this.isActive,
    required this.isCptMode,
    required this.onTap,
  });

  @override
  State<_TVMKey> createState() => _TVMKeyState();
}

class _TVMKeyState extends State<_TVMKey> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
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
    final borderColor = widget.isCptMode
        ? AppColors.accentSecondary
        : widget.isActive
            ? AppColors.accent
            : AppColors.glassBorder;

    final borderWidth = (widget.isActive || widget.isCptMode) ? 1.5 : 1.0;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _scaleController.forward();
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: _isPressed
                ? AppColors.glassOverlay.withOpacity(0.25)
                : AppColors.glassOverlay,
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : widget.isCptMode
                    ? [
                        BoxShadow(
                          color: AppColors.accentSecondary.withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Value indicator dot
              if (widget.hasValue)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: widget.isActive
                          ? AppColors.accent
                          : AppColors.textSecondary.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

              // Label
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: widget.isCptMode
                      ? AppColors.accentSecondary
                      : widget.isActive
                          ? AppColors.accent
                          : AppColors.textPrimary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ).animate(target: widget.isCptMode ? 1 : 0).shimmer(
              duration: 1500.ms,
              color: AppColors.accentSecondary.withOpacity(0.15),
            ),
      ),
    );
  }
}
