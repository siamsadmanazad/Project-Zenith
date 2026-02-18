import 'package:intl/intl.dart';

/// Consistent number formatting across both calculator modes
class NumberFormatter {
  static final _currencyFormat = NumberFormat('#,##0.00');
  static final _plainFormat = NumberFormat('#,##0.##');

  /// Format a number for the display panel: "500,000.00"
  static String formatDisplay(double value) {
    return _currencyFormat.format(value);
  }

  /// Format with variable label: "PV = 500,000.00"
  static String formatWithLabel(String variable, double value) {
    return '$variable = ${formatDisplay(value)}';
  }

  /// Format result based on variable type:
  /// Currency vars (PV, PMT, FV) get "$" prefix
  /// I/Y gets "%" suffix
  /// N stays plain
  static String formatResult(double value, String? variable) {
    switch (variable) {
      case 'I/Y':
        return '${value.toStringAsFixed(2)}%';
      case 'PV':
      case 'PMT':
      case 'FV':
        final sign = value < 0 ? '-' : '';
        return '$sign\$${_currencyFormat.format(value.abs())}';
      case 'N':
        return _plainFormat.format(value);
      default:
        return _currencyFormat.format(value);
    }
  }

  /// Parse a display buffer string to double
  static double? parseBuffer(String buffer) {
    if (buffer.isEmpty) return null;
    // Remove commas if any
    final cleaned = buffer.replaceAll(',', '');
    return double.tryParse(cleaned);
  }

  /// Format buffer for display (add commas while typing)
  static String formatBuffer(String buffer) {
    if (buffer.isEmpty) return '0';
    if (buffer == '-') return '-';
    if (buffer == '.' || buffer == '0.') return '0.';
    if (buffer == '-.') return '-0.';

    // Split on decimal
    final parts = buffer.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : null;

    // Format integer part with commas
    final isNegative = intPart.startsWith('-');
    final digits = isNegative ? intPart.substring(1) : intPart;

    if (digits.isEmpty) {
      final formatted = isNegative ? '-0' : '0';
      return decPart != null ? '$formatted.$decPart' : formatted;
    }

    final number = int.tryParse(digits);
    if (number == null) return buffer;

    final formatted = NumberFormat('#,###').format(number);
    final signed = isNegative ? '-$formatted' : formatted;

    return decPart != null ? '$signed.$decPart' : signed;
  }
}
