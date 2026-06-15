import 'package:flutter/material.dart';

Color loyaltyColorFromHex(String? value, Color fallback) {
  final raw = value?.trim();
  if (raw == null || raw.isEmpty) {
    return fallback;
  }

  final hex = raw.startsWith('#') ? raw.substring(1) : raw;
  if (hex.length != 3 && hex.length != 6 && hex.length != 8) {
    return fallback;
  }

  final expanded = hex.length == 3
      ? hex.split('').map((digit) => '$digit$digit').join()
      : hex;
  final parsed = int.tryParse(expanded, radix: 16);
  if (parsed == null) {
    return fallback;
  }

  return Color(expanded.length == 6 ? 0xFF000000 | parsed : parsed);
}

Color loyaltyMixWithBlack(Color color, double amount) {
  final clamped = amount.clamp(0, 1).toDouble();
  return Color.fromARGB(
    (color.a * 255).round(),
    (color.r * 255 * (1 - clamped)).round(),
    (color.g * 255 * (1 - clamped)).round(),
    (color.b * 255 * (1 - clamped)).round(),
  );
}
