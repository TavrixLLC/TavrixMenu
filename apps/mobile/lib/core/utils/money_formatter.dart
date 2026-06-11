class MoneyFormatter {
  const MoneyFormatter._();

  static String formatCents(int amount, {String currency = 'IQD'}) {
    return '$amount $currency';
  }
}
