import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations_extension.dart';
import '../../../core/theme/v3/waflo_v3_theme.dart';
import '../../../core/theme/v3/waflo_v3_tokens.dart';

class WafloSecondaryButton extends StatefulWidget {
  const WafloSecondaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.fullWidth = true,
    this.loadingSemanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final String? loadingSemanticLabel;

  @override
  State<WafloSecondaryButton> createState() => _WafloSecondaryButtonState();
}

class _WafloSecondaryButtonState extends State<WafloSecondaryButton> {
  bool _tapLocked = false;

  bool get _isEnabled {
    return widget.onPressed != null && !widget.isLoading && !_tapLocked;
  }

  void _handlePressed() {
    if (!_isEnabled) {
      return;
    }

    setState(() => _tapLocked = true);
    try {
      widget.onPressed!.call();
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _tapLocked = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.isLoading
        ? WafloV3Theme.secondaryButtonStyle.copyWith(
            backgroundColor: const WidgetStatePropertyAll(
              WafloV3Colors.surface,
            ),
            foregroundColor: const WidgetStatePropertyAll(
              WafloV3Colors.primary,
            ),
            side: const WidgetStatePropertyAll(
              BorderSide(color: WafloV3Colors.primary),
            ),
          )
        : WafloV3Theme.secondaryButtonStyle;
    final button = Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.label,
      value: widget.isLoading
          ? widget.loadingSemanticLabel ?? context.l10n.genericLoading
          : null,
      liveRegion: widget.isLoading,
      excludeSemantics: true,
      child: OutlinedButton(
        onPressed: _isEnabled ? _handlePressed : null,
        style: style,
        child: _ButtonContent(
          label: widget.label,
          isLoading: widget.isLoading,
          indicatorColor: WafloV3Colors.primary,
        ),
      ),
    );

    if (!widget.fullWidth) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.isLoading,
    required this.indicatorColor,
  });

  final String label;
  final bool isLoading;
  final Color indicatorColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox.square(
            dimension: WafloV3Spacing.space20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: indicatorColor,
            ),
          ),
          const SizedBox(width: WafloV3Spacing.space8),
        ],
        Flexible(
          child: Text(label, textAlign: TextAlign.center, softWrap: true),
        ),
      ],
    );
  }
}
