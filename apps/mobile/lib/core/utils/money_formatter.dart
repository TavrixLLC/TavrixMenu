class MoneyFormatter {
  const MoneyFormatter._();

  static String formatCents(int cents, {String currency = 'IQD'}) {
    final amount = cents / 100;
    return '${amount.toStringAsFixed(2)} $currency';
  }
}
