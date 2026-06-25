import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  const AppShadows._();

  static const soft = [
    BoxShadow(color: Color(0x10000000), blurRadius: 18, offset: Offset(0, 8)),
  ];

  static const medium = [
    BoxShadow(color: Color(0x18000000), blurRadius: 28, offset: Offset(0, 14)),
  ];

  static const header = [
    BoxShadow(color: Color(0x24101820), blurRadius: 30, offset: Offset(0, 14)),
  ];

  static const focusRing = [
    BoxShadow(color: AppColors.coralTint, blurRadius: 0, spreadRadius: 3),
  ];
}
