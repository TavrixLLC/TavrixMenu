class MoneyFormatter {
  const MoneyFormatter._();

  static String formatCents(int amount, {String currency = 'د.ع'}) {
    final sign = amount < 0 ? '-' : '';
    final digits = amount.abs().toString();
    final parts = <String>[];

    for (var end = digits.length; end > 0; end -= 3) {
      final start = end - 3 < 0 ? 0 : end - 3;
      parts.insert(0, digits.substring(start, end));
    }

    return '$sign${parts.join(',')} $currency';
  }
}
