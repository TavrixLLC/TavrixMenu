import 'package:flutter/material.dart';

import 'waflo_button.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return WafloButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      expand: expand,
      variant: switch (variant) {
        AppButtonVariant.primary => WafloButtonVariant.primary,
        AppButtonVariant.secondary => WafloButtonVariant.secondary,
        AppButtonVariant.danger => WafloButtonVariant.danger,
        AppButtonVariant.ghost => WafloButtonVariant.ghost,
      },
    );
  }
}
