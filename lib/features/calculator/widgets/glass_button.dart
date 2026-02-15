import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Glass Button - Premium glassmorphic button with haptic feedback
class GlassButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isPrimary;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isPrimary = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _scaleController.forward();
      // Haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppDimensions.glassBlur,
              sigmaY: AppDimensions.glassBlur,
            ),
            child: Container(
              height: AppDimensions.buttonHeight,
              decoration: BoxDecoration(
                // Primary button has accent gradient
                gradient: widget.isPrimary && !isDisabled
                    ? AppColors.accentGradient
                    : null,
                // Secondary button has glass effect
                color: widget.isPrimary || isDisabled
                    ? null
                    : (_isPressed
                        ? AppColors.glassOverlay.withOpacity(0.2)
                        : AppColors.glassOverlay),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(
                  color: isDisabled
                      ? AppColors.glassBorder.withOpacity(0.3)
                      : (_isPressed ? AppColors.accent : AppColors.glassBorder),
                  width: AppDimensions.glassBorderWidth,
                ),
                boxShadow: widget.isPrimary && !isDisabled
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.glassShadow,
                          blurRadius: AppDimensions.glassShadowBlur,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDisabled
                        ? AppColors.textDisabled
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
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
