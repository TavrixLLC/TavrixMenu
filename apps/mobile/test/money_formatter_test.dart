import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/utils/money_formatter.dart';

void main() {
  group('MoneyFormatter', () {
    test('parses Western Arabic and Persian digits deterministically', () {
      expect(MoneyFormatter.parsePositiveMajorUnits('6500'), 6500);
      expect(MoneyFormatter.parsePositiveMajorUnits('٦٥٠٠'), 6500);
      expect(MoneyFormatter.parsePositiveMajorUnits('۶۵۰۰'), 6500);
      expect(MoneyFormatter.parsePositiveMajorUnits('٦٬٥٠٠'), 6500);
      expect(MoneyFormatter.parsePositiveMajorUnits('6,500'), 6500);
    });

    test('rejects empty zero negative decimal and mixed input', () {
      for (final value in ['', '0', '-1', '6.5', '٦٫٥', '6 500', 'IQD 6500']) {
        expect(
          MoneyFormatter.parsePositiveMajorUnits(value),
          isNull,
          reason: value,
        );
      }
    });

    test('formats IQD in grouped Arabic presentation', () {
      expect(MoneyFormatter.formatMajorUnits(6500), '6,500 د.ع');
      expect(MoneyFormatter.formatMajorUnits(42, currency: 'USD'), '42 USD');
    });
  });
}
