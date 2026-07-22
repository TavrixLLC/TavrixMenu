import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations_extension.dart';
import '../../../core/theme/v3/waflo_v3_theme.dart';
import '../../../core/theme/v3/waflo_v3_tokens.dart';

class WafloPrimaryButton extends StatefulWidget {
  const WafloPrimaryButton({
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
  State<WafloPrimaryButton> createState() => _WafloPrimaryButtonState();
}

class _WafloPrimaryButtonState extends State<WafloPrimaryButton> {
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
        ? WafloV3Theme.primaryButtonStyle.copyWith(
            backgroundColor: const WidgetStatePropertyAll(
              WafloV3Colors.primary,
            ),
            foregroundColor: const WidgetStatePropertyAll(
              WafloV3Colors.surface,
            ),
          )
        : WafloV3Theme.primaryButtonStyle;
    final button = Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.label,
      value: widget.isLoading
          ? widget.loadingSemanticLabel ?? context.l10n.genericLoading
          : null,
      liveRegion: widget.isLoading,
      excludeSemantics: true,
      child: ElevatedButton(
        onPressed: _isEnabled ? _handlePressed : null,
        style: style,
        child: _ButtonContent(
          label: widget.label,
          isLoading: widget.isLoading,
          indicatorColor: WafloV3Colors.surface,
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
