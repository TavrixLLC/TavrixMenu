import 'package:flutter/material.dart';

import 'waflo_button.dart';

class StampActionButton extends StatelessWidget {
  const StampActionButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return WafloButton(
      label: label,
      icon: Icons.add_circle_outline,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: WafloButtonVariant.success,
    );
  }
}
