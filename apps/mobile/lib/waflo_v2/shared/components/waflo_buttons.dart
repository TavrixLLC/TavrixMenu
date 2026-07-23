import 'package:flutter/material.dart';

import '../../core/theme/waflo_spacing.dart';

class WafloPrimaryButton extends StatelessWidget {
  const WafloPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.disabledReason,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? disabledReason;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          enabled: enabled,
          label: label,
          value: isLoading ? 'loading' : null,
          liveRegion: isLoading,
          excludeSemantics: true,
          child: FilledButton(
            onPressed: enabled ? onPressed : null,
            child: _ButtonContent(
              label: label,
              isLoading: isLoading,
              leading: leading,
            ),
          ),
        ),
        if (!enabled && !isLoading && disabledReason != null) ...[
          const SizedBox(height: WafloSpacing.x2),
          Text(disabledReason!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}

class WafloSecondaryButton extends StatelessWidget {
  const WafloSecondaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      value: isLoading ? 'loading' : null,
      liveRegion: isLoading,
      excludeSemantics: true,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        child: _ButtonContent(
          label: label,
          isLoading: isLoading,
          leading: leading,
        ),
      ),
    );
  }
}

class WafloRetryButton extends StatelessWidget {
  const WafloRetryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return WafloSecondaryButton(
      label: label,
      onPressed: onPressed,
      leading: Icons.refresh_rounded,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.isLoading,
    this.leading,
  });

  final String label;
  final bool isLoading;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (leading != null)
          Icon(leading, size: 20),
        if (isLoading || leading != null)
          const SizedBox(width: WafloSpacing.x2),
        Flexible(
          child: Text(label, textAlign: TextAlign.center, softWrap: true),
        ),
      ],
    );
  }
}
