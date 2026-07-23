import 'package:flutter/material.dart';

import '../../core/theme/waflo_spacing.dart';

class WafloSectionCard extends StatelessWidget {
  const WafloSectionCard({
    required this.child,
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.semanticLabel,
  });

  final Widget child;
  final String? title;
  final IconData? leading;
  final Widget? trailing;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Card(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(WafloSpacing.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    if (leading != null) ...[
                      Icon(leading, size: 22),
                      const SizedBox(width: WafloSpacing.x2),
                    ],
                    Expanded(
                      child: Text(
                        title!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                if (trailing != null) ...[
                  const SizedBox(height: WafloSpacing.x2),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: trailing!,
                  ),
                ],
                const SizedBox(height: WafloSpacing.x3),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
