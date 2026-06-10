class MoneyFormatter {
  const MoneyFormatter._();

  static String formatPrice(String price, {String currency = 'IQD'}) {
    final trimmed = price.trim();
    if (trimmed.isEmpty) {
      return '0 $currency';
    }

    final amount = num.tryParse(trimmed);
    if (amount == null) {
      return '$trimmed $currency';
    }

    final formatted = amount % 1 == 0
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    return '$formatted $currency';
  }

  static String formatCents(int cents, {String currency = 'IQD'}) {
    final amount = cents / 100;
    return '${amount.toStringAsFixed(2)} $currency';
  }
}
