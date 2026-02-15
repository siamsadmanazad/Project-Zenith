import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// TVM Input Field - Custom text field for calculator inputs
class TVMInputField extends StatefulWidget {
  final String label;
  final String hint;
  final double? value;
  final Function(double?) onChanged;
  final bool isCurrency;

  const TVMInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.isCurrency = false,
  });

  @override
  State<TVMInputField> createState() => _TVMInputFieldState();
}

class _TVMInputFieldState extends State<TVMInputField> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(TVMInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller if value changed externally (e.g., clear button)
    if (widget.value != oldWidget.value &&
        widget.value?.toString() != _controller.text) {
      _controller.text = widget.value?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: _isFocused
            ? AppColors.surface.withOpacity(0.8)
            : AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: _isFocused ? AppColors.accent : AppColors.glassBorder,
          width: _isFocused ? 2.0 : AppDimensions.glassBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(
              left: AppDimensions.spacingM,
              top: AppDimensions.spacingS,
            ),
            child: Text(
              widget.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: _isFocused ? AppColors.accent : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Input field
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            inputFormatters: [
              // Allow numbers, decimal point, and minus sign
              FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
            ],
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textDisabled,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
              // Prefix for currency
              prefixText: widget.isCurrency && _controller.text.isNotEmpty
                  ? '\$ '
                  : null,
              prefixStyle: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            onChanged: (text) {
              if (text.isEmpty) {
                widget.onChanged(null);
              } else {
                final value = double.tryParse(text);
                widget.onChanged(value);
              }
            },
            onTap: () {
              setState(() => _isFocused = true);
            },
            onEditingComplete: () {
              setState(() => _isFocused = false);
            },
            onSubmitted: (_) {
              setState(() => _isFocused = false);
            },
          ),
        ],
      ),
    );
  }
}
