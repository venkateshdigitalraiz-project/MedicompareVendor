import 'package:intl/intl.dart';

extension PriceFormatterExtension on num {
  /// Formats the number with commas.
  /// Example: 6000 -> "6,000"
  /// Example: 150000 -> "1,50,000" (Indian numbering format)
  String toFormattedPrice() {
    final formatter = NumberFormat('#,##,##0', 'en_IN');
    return formatter.format(this);
  }

  /// Formats the number with Indian Rupee symbol and commas.
  /// Example: 6000 -> "₹6,000"
  /// Example: 150000 -> "₹1,50,000"
  String toRupeeFormat({int decimalDigits = 0}) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }
}
