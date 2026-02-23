import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/haptic_service.dart';
import '../providers/calculator_mode_provider.dart';

/// Glassmorphic segmented control pill for switching between keypad and form modes
class ModeSegmentedControl extends StatefulWidget {
  final CalculatorMode currentMode;
  final ValueChanged<CalculatorMode> onModeChanged;

  const ModeSegmentedControl({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  State<ModeSegmentedControl> createState() => _ModeSegmentedControlState();
}

class _ModeSegmentedControlState extends State<ModeSegmentedControl>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slide;

  static const double _segW   = 44;
  static const double _height = 30;
  static const double _pad    = 2;
  static const double _radius = _height / 2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: widget.currentMode == CalculatorMode.keypad ? 0.0 : 1.0,
    );
    _slide = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(ModeSegmentedControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentMode != oldWidget.currentMode) {
      widget.currentMode == CalculatorMode.form
          ? _controller.forward()
          : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(CalculatorMode mode) {
    if (widget.currentMode == mode) return;
    HapticService.mode();
    widget.onModeChanged(mode);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: _segW * 2 + _pad * 2,
          height: _height,
          decoration: BoxDecoration(
            color: AppColors.glassOverlay,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: AppColors.glassBorder, width: 0.5),
          ),
          child: AnimatedBuilder(
            animation: _slide,
            builder: (context, _) {
              // Smooth color lerp for icons
              final keypadColor = Color.lerp(
                AppColors.textSecondary,
                AppColors.accent,
                1 - _slide.value,
              )!;
              final formColor = Color.lerp(
                AppColors.textSecondary,
                AppColors.accent,
                _slide.value,
              )!;

              // Scale: active icon is slightly larger
              final keypadScale = 0.9 + 0.1 * (1 - _slide.value);
              final formScale   = 0.9 + 0.1 * _slide.value;

              return Stack(
                children: [
                  // Sliding pill highlight with glow
                  Positioned(
                    left: _pad + _slide.value * _segW,
                    top: _pad,
                    child: Container(
                      width: _segW,
                      height: _height - _pad * 2,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(_radius - _pad),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.25),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.18),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Icons with animated color + scale
                  Row(
                    children: [
                      _segment(CalculatorMode.keypad, Icons.grid_view_rounded, keypadColor, keypadScale),
                      _segment(CalculatorMode.form,   Icons.list_rounded,      formColor,   formScale),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _segment(CalculatorMode mode, IconData icon, Color color, double scale) {
    return GestureDetector(
      onTap: () => _onTap(mode),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _segW,
        height: _height,
        child: Center(
          child: Transform.scale(
            scale: scale,
            child: Icon(icon, size: 14, color: color),
          ),
        ),
      ),
    );
  }
}
