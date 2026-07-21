class MoneyFormatter {
  const MoneyFormatter._();

  static String formatCents(int amount, {String currency = 'IQD'}) {
    return '$amount $currency';
  }

  static String formatMajorUnits(int amount, {String currency = 'IQD'}) {
    final digits = amount.abs().toString();
    final grouped = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    final signed = amount < 0 ? '-$grouped' : grouped;
    final label = currency.trim().toUpperCase() == 'IQD'
        ? 'د.ع'
        : currency.trim().toUpperCase();
    return '$signed $label';
  }

  static int? parsePositiveMajorUnits(String input) {
    final normalized = _normalizeDigits(
      input.trim(),
    ).replaceAll('٬', '').replaceAll(',', '');
    if (!RegExp(r'^[0-9]+$').hasMatch(normalized)) {
      return null;
    }

    final parsed = int.tryParse(normalized);
    return parsed != null && parsed > 0 ? parsed : null;
  }

  static String _normalizeDigits(String input) {
    const source = '٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹';
    const target = '01234567890123456789';
    return input.split('').map((character) {
      final index = source.indexOf(character);
      return index == -1 ? character : target[index];
    }).join();
  }
}
