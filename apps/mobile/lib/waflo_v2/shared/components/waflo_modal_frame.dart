import 'package:flutter/material.dart';

import '../../core/theme/waflo_radii.dart';
import '../../core/theme/waflo_spacing.dart';

class WafloBottomSheetFrame extends StatelessWidget {
  const WafloBottomSheetFrame({
    required this.title,
    required this.child,
    super.key,
    this.footer,
  });

  final String title;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: WafloSpacing.screenInset,
          top: WafloSpacing.x2,
          end: WafloSpacing.screenInset,
          bottom:
              MediaQuery.viewInsetsOf(context).bottom +
              WafloSpacing.screenInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(WafloRadii.pill),
                  ),
                ),
              ),
            ),
            const SizedBox(height: WafloSpacing.x4),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: WafloSpacing.x3),
            Flexible(child: SingleChildScrollView(child: child)),
            if (footer != null) ...[
              const SizedBox(height: WafloSpacing.x4),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class WafloDialogFrame extends StatelessWidget {
  const WafloDialogFrame({
    required this.title,
    required this.child,
    super.key,
    this.actions = const [],
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(WafloRadii.card)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(WafloSpacing.x5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: WafloSpacing.x3),
            child,
            if (actions.isNotEmpty) ...[
              const SizedBox(height: WafloSpacing.x4),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: WafloSpacing.x2,
                runSpacing: WafloSpacing.x2,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
