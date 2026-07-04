import 'package:flutter/material.dart';
import '../../../../core/theme/v2/waflo_tokens_v2.dart';

/// Waflo Button V2 Component
///
/// A highly interactive button wrapper featuring multiple semantic variants,
/// state-based micro-scale scaling on press, and built-in loading states.
enum WafloButtonV2Variant { primary, secondary, danger, success, ghost }

class WafloButtonV2 extends StatefulWidget {
  const WafloButtonV2({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.variant = WafloButtonV2Variant.primary,
    this.expand = true,
    this.isLoading = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final WafloButtonV2Variant variant;
  final bool expand;
  final bool isLoading;
  final String? semanticLabel;

  @override
  State<WafloButtonV2> createState() => _WafloButtonV2State();
}

class _WafloButtonV2State extends State<WafloButtonV2> {
  bool _isPressed = false;

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
        scale: _isPressed && enabled ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
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
      borderRadius: WafloRadiusV2.mdBorder,
      side: BorderSide(
        color: widget.onPressed == null
            ? WafloColorsV2.borderSoft
            : colors.border,
        width: 1.5,
      ),
    );

    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 54)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      backgroundColor: WidgetStatePropertyAll(
        widget.onPressed == null
            ? WafloColorsV2.borderExtraSoft
            : colors.background,
      ),
      foregroundColor: WidgetStatePropertyAll(
        widget.onPressed == null ? WafloColorsV2.textLight : colors.foreground,
      ),
      overlayColor: WidgetStatePropertyAll(colors.overlay),
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(shape),
      textStyle: const WidgetStatePropertyAll(WafloTypographyV2.buttonText),
    );

    return Listener(
      onPointerDown: (_) => setState(() => _isPressed = true),
      onPointerUp: (_) => setState(() => _isPressed = false),
      onPointerCancel: (_) => setState(() => _isPressed = false),
      child: TextButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: style,
        child: content,
      ),
    );
  }

  _WafloButtonColors _buttonColors(WafloButtonV2Variant variant) {
    return switch (variant) {
      WafloButtonV2Variant.primary => const _WafloButtonColors(
        background: WafloColorsV2.primaryCoral,
        foreground: WafloColorsV2.surfaceWhite,
        border: WafloColorsV2.primaryCoral,
        overlay: Color(0x15FFFFFF),
      ),
      WafloButtonV2Variant.secondary => const _WafloButtonColors(
        background: WafloColorsV2.surfaceWhite,
        foreground: WafloColorsV2.textDark,
        border: WafloColorsV2.borderSoft,
        overlay: Color(0x0A000000),
      ),
      WafloButtonV2Variant.danger => const _WafloButtonColors(
        background: WafloColorsV2.danger,
        foreground: WafloColorsV2.surfaceWhite,
        border: WafloColorsV2.danger,
        overlay: Color(0x15FFFFFF),
      ),
      WafloButtonV2Variant.success => const _WafloButtonColors(
        background: WafloColorsV2.success,
        foreground: WafloColorsV2.surfaceWhite,
        border: WafloColorsV2.success,
        overlay: Color(0x15FFFFFF),
      ),
      WafloButtonV2Variant.ghost => const _WafloButtonColors(
        background: Colors.transparent,
        foreground: WafloColorsV2.accentCrimson,
        border: Colors.transparent,
        overlay: Color(0x0A000000),
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
        color: IconTheme.of(context).color ?? WafloColorsV2.surfaceWhite,
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) spinner else if (icon != null) Icon(icon, size: 20),
        if (isLoading || icon != null) const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
