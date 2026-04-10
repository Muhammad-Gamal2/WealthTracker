import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _egpFormat = NumberFormat.currency(
    locale: 'ar_EG',
    symbol: 'EGP ',
    decimalDigits: 2,
  );

  static final _usdFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final _numberFormat = NumberFormat('#,##0.##');

  static String formatEgp(double amount) => _egpFormat.format(amount);

  static String formatUsd(double amount) => _usdFormat.format(amount);

  static String formatNumber(double number) => _numberFormat.format(number);

  static String formatPercent(double percent) =>
      '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(2)}%';

  static String formatGrams(double grams) => '${_numberFormat.format(grams)}g';
}
