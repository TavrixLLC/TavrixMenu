import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  const AppShadows._();

  static const soft = [
    BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 8)),
  ];

  static const medium = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 12)),
  ];

  static const header = [
    BoxShadow(color: Color(0x24006241), blurRadius: 24, offset: Offset(0, 12)),
  ];

  static const focusRing = [
    BoxShadow(color: AppColors.greenLight, blurRadius: 0, spreadRadius: 3),
  ];
}
