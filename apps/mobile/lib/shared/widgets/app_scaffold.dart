import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import 'waflo_scaffold.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.child,
    super.key,
    this.title,
    this.actions,
    this.scrollable = false,
    this.padding = const EdgeInsetsDirectional.all(AppSpacing.md),
    this.bottomNavigation,
    this.embeddedInWorkspaceShell = false,
  });

  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final bool scrollable;
  final EdgeInsetsGeometry padding;
  final Widget? bottomNavigation;
  final bool embeddedInWorkspaceShell;

  @override
  Widget build(BuildContext context) {
    return WafloScaffold(
      title: embeddedInWorkspaceShell ? null : title,
      actions: embeddedInWorkspaceShell ? null : actions,
      scrollable: scrollable,
      padding: padding,
      bottomNavigation: bottomNavigation,
      child: child,
    );
  }
}
