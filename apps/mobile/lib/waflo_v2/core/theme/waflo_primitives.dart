import 'package:flutter/material.dart';

/// Raw values from the official Waflo Brand System.
///
/// Application features must consume semantic roles from [WafloColors], not
/// these primitives directly.
abstract final class WafloPrimitives {
  static const Color brick = Color(0xFFAE3115);
  static const Color coral = Color(0xFFFF6B4A);
  static const Color ember = Color(0xFF7D2311);
  static const Color softCoral = Color(0xFFFFF0EC);
  static const Color warmInk = Color(0xFF241916);
  static const Color mutedClay = Color(0xFF76645F);
  static const Color cloud = Color(0xFFF7F9FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF1F8F6A);
  static const Color warning = Color(0xFFE6A23C);
  static const Color danger = Color(0xFFC93C2B);
}
