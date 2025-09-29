import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormatter = NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 0,
  );

  /// Format a number as currency (e.g., $1,234.56)
  static String format(double amount) {
    return _formatter.format(amount);
  }

  /// Format a number as compact currency (e.g., $1.2K, $1.5M)
  static String formatCompact(double amount) {
    return _compactFormatter.format(amount);
  }

  /// Format with custom symbol
  static String formatWithSymbol(double amount, String symbol) {
    final customFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: symbol,
      decimalDigits: 2,
    );
    return customFormatter.format(amount);
  }

  /// Format without decimal places for whole numbers
  static String formatWhole(double amount) {
    final wholeFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: amount == amount.roundToDouble() ? 0 : 2,
    );
    return wholeFormatter.format(amount);
  }
}