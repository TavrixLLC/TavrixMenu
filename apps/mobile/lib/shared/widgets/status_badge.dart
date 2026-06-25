import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'waflo_status_badge.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    super.key,
    this.color = AppColors.greenLight,
    this.foregroundColor = AppColors.houseGreen,
  });

  final String label;
  final Color color;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return WafloStatusBadge(
      label: label,
      color: color,
      foregroundColor: foregroundColor,
    );
  }
}
