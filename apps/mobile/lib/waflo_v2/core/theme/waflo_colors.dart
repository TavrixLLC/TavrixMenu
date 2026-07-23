import 'package:flutter/material.dart';

import 'waflo_primitives.dart';

/// Semantic color authority for the isolated Waflo V2 foundation.
///
/// Raw Brand System values live in [WafloPrimitives]. Features consume these
/// intent-based roles so status, foreground, and container decisions remain
/// accessible and can evolve without leaking palette names into product code.
abstract final class WafloColors {
  static const Color actionPrimary = WafloPrimitives.brick;
  static const Color onActionPrimary = WafloPrimitives.white;
  static const Color actionSecondary = WafloPrimitives.coral;
  static const Color onActionSecondary = WafloPrimitives.warmInk;
  static const Color brandEmphasis = WafloPrimitives.ember;
  static const Color brandHighlight = WafloPrimitives.coral;

  static const Color canvas = WafloPrimitives.cloud;
  static const Color surface = WafloPrimitives.white;
  static const Color surfaceSubtle = WafloPrimitives.softCoral;
  static const Color surfaceMuted = Color(0xFFF1ECEA);
  static const Color surfaceStrong = Color(0xFFE7DDDA);

  static const Color textStrong = WafloPrimitives.warmInk;
  static const Color textMuted = WafloPrimitives.mutedClay;
  static const Color outline = Color(0xFFB9AAA6);
  static const Color divider = Color(0xFFE7DDDA);

  static const Color statusSuccess = WafloPrimitives.success;
  static const Color onStatusSuccess = Color(0xFF120B09);
  static const Color successContainer = Color(0xFFE8F5F0);
  static const Color onSuccessContainer = Color(0xFF145C45);

  static const Color statusWarning = WafloPrimitives.warning;
  static const Color onStatusWarning = WafloPrimitives.warmInk;
  static const Color warningContainer = Color(0xFFFFF4E1);
  static const Color onWarningContainer = WafloPrimitives.warmInk;

  static const Color statusDanger = WafloPrimitives.danger;
  static const Color onStatusDanger = WafloPrimitives.white;
  static const Color dangerContainer = Color(0xFFFBEAE7);
  static const Color onDangerContainer = WafloPrimitives.ember;

  /// Information is intentionally brand-neutral/warm rather than an
  /// unrelated blue. It is expressed by a quiet container and brand ink.
  static const Color statusInformation = WafloPrimitives.ember;
  static const Color informationContainer = WafloPrimitives.softCoral;
  static const Color onInformationContainer = WafloPrimitives.ember;

  static const Color disabledSurface = Color(0xFFE7DDDA);
  static const Color disabledForeground = WafloPrimitives.mutedClay;
  static const Color onSurface = textStrong;
}
