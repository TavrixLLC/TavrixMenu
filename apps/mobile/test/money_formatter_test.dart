import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/utils/money_formatter.dart';

void main() {
  test('formats IQD amounts with separators and Arabic dinar suffix', () {
    expect(MoneyFormatter.formatCents(3000), '3,000 د.ع');
    expect(MoneyFormatter.formatCents(1250000), '1,250,000 د.ع');
    expect(MoneyFormatter.formatCents(3000, currency: 'IQD'), '3,000 IQD');
  });
}
