import 'package:flutter/material.dart';

/// Official Waflo elevation token. Border-based surfaces remain the default;
/// this shadow is reserved for content that materially needs elevation.
abstract final class WafloShadows {
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color.fromRGBO(36, 25, 22, 0.10),
      offset: Offset(0, 12),
      blurRadius: 32,
    ),
  ];
}
