import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';

enum WafloButtonVariant { primary, secondary, danger, ghost, success }

class WafloButton extends StatefulWidget {
  const WafloButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.variant = WafloButtonVariant.primary,
    this.expand = true,
    this.isLoading = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final WafloButtonVariant variant;
  final bool expand;
  final bool isLoading;
  final String? semanticLabel;

  @override
  State<WafloButton> createState() => _WafloButtonState();
}

class _WafloButtonState extends State<WafloButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final colors = _buttonColors(widget.variant);
    final content = _ButtonContent(
      icon: widget.icon,
      label: widget.label,
      isLoading: widget.isLoading,
    );
    final button = Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label,
      enabled: enabled,
      child: AnimatedScale(
        scale: _pressed && enabled ? 0.98 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: _buildButton(colors, content),
      ),
    );

    if (!widget.expand) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }

  Widget _buildButton(_WafloButtonColors colors, Widget content) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: BorderSide(color: colors.border),
    );
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsetsDirectional.symmetric(horizontal: 18, vertical: 14),
      ),
      backgroundColor: WidgetStatePropertyAll(colors.background),
      foregroundColor: WidgetStatePropertyAll(colors.foreground),
      overlayColor: WidgetStatePropertyAll(colors.overlay),
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(shape),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w800),
      ),
    );

    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: TextButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: style,
        child: content,
      ),
    );
  }

  _WafloButtonColors _buttonColors(WafloButtonVariant variant) {
    return switch (variant) {
      WafloButtonVariant.primary => const _WafloButtonColors(
        background: AppColors.primaryCoral,
        foreground: AppColors.surfaceWhite,
        border: AppColors.primaryCoral,
        overlay: Color(0x1AFFFFFF),
      ),
      WafloButtonVariant.secondary => const _WafloButtonColors(
        background: AppColors.surfaceWhite,
        foreground: AppColors.textDark,
        border: AppColors.softBorder,
        overlay: AppColors.coralTint,
      ),
      WafloButtonVariant.danger => const _WafloButtonColors(
        background: AppColors.dangerRed,
        foreground: AppColors.surfaceWhite,
        border: AppColors.dangerRed,
        overlay: Color(0x1AFFFFFF),
      ),
      WafloButtonVariant.ghost => const _WafloButtonColors(
        background: Colors.transparent,
        foreground: AppColors.primaryCoralDark,
        border: Colors.transparent,
        overlay: AppColors.coralTint,
      ),
      WafloButtonVariant.success => const _WafloButtonColors(
        background: AppColors.freshGreen,
        foreground: AppColors.surfaceWhite,
        border: AppColors.freshGreen,
        overlay: Color(0x1AFFFFFF),
      ),
    };
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.isLoading,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final spinner = SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: IconTheme.of(context).color,
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) spinner else if (icon != null) Icon(icon, size: 20),
        if (isLoading || icon != null) const SizedBox(width: 10),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _WafloButtonColors {
  const _WafloButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
    required this.overlay,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final Color overlay;
}
