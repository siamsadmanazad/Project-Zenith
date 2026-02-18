import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../providers/calculator_mode_provider.dart';

/// Glassmorphic pill button for switching between keypad and form modes
class ModeToggleButton extends StatefulWidget {
  final CalculatorMode currentMode;
  final VoidCallback onToggle;

  const ModeToggleButton({
    super.key,
    required this.currentMode,
    required this.onToggle,
  });

  @override
  State<ModeToggleButton> createState() => _ModeToggleButtonState();
}

class _ModeToggleButtonState extends State<ModeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.currentMode == CalculatorMode.keypad ? 0.0 : 1.0,
    );
  }

  @override
  void didUpdateWidget(ModeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentMode != oldWidget.currentMode) {
      if (widget.currentMode == CalculatorMode.form) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onToggle();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.glassOverlay,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              border: Border.all(
                color: AppColors.glassBorder,
                width: AppDimensions.glassBorderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.glassShadow,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.rotate(
                  angle: _controller.value * 3.14159,
                  child: Icon(
                    widget.currentMode == CalculatorMode.keypad
                        ? Icons.grid_view_rounded
                        : Icons.list_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
