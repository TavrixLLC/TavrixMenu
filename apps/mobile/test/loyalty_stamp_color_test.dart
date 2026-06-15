import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/loyalty/presentation/utils/loyalty_stamp_color.dart';

void main() {
  test('valid hex color parses', () {
    expect(
      loyaltyColorFromHex('#111827', Colors.white),
      const Color(0xFF111827),
    );
    expect(loyaltyColorFromHex('#abc', Colors.white), const Color(0xFFAABBCC));
    expect(
      loyaltyColorFromHex('80111827', Colors.white),
      const Color(0x80111827),
    );
  });

  test('invalid hex falls back safely', () {
    expect(loyaltyColorFromHex('#xyzxyz', Colors.red), Colors.red);
    expect(loyaltyColorFromHex('#12345', Colors.red), Colors.red);
  });

  test('null and empty hex fall back safely', () {
    expect(loyaltyColorFromHex(null, Colors.blue), Colors.blue);
    expect(loyaltyColorFromHex(' ', Colors.blue), Colors.blue);
  });

  test('mix with black darkens channels safely', () {
    expect(
      loyaltyMixWithBlack(const Color(0xFF7C2D12), 0.22),
      const Color(0xFF61230E),
    );
  });
}
