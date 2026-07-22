import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations_extension.dart';
import '../../../core/theme/v3/waflo_v3_tokens.dart';
import 'waflo_secondary_button.dart';

class WafloInlineError extends StatelessWidget {
  const WafloInlineError({
    required this.message,
    super.key,
    this.title,
    this.onRetry,
    this.isRetrying = false,
    this.retryLabel,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final bool isRetrying;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final semanticLabel = title == null ? message : '$title، $message';

    return Semantics(
      container: true,
      explicitChildNodes: true,
      liveRegion: true,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: WafloV3Colors.error.withValues(alpha: 0.08),
          borderRadius: const BorderRadius.all(
            Radius.circular(WafloV3Radius.standardCard),
          ),
          border: Border.all(
            color: WafloV3Colors.error.withValues(alpha: 0.24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(WafloV3Spacing.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.error_outline,
                color: WafloV3Colors.error,
                size: WafloV3Spacing.space24,
              ),
              if (title != null) ...[
                const SizedBox(height: WafloV3Spacing.space8),
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: WafloV3Colors.error,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.start,
                  softWrap: true,
                ),
              ],
              const SizedBox(height: WafloV3Spacing.space4),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: WafloV3Colors.primaryText,
                ),
                textAlign: TextAlign.start,
                softWrap: true,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: WafloV3Spacing.space12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: WafloSecondaryButton(
                    label: retryLabel ?? context.l10n.genericRetry,
                    onPressed: onRetry,
                    isLoading: isRetrying,
                    fullWidth: false,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
