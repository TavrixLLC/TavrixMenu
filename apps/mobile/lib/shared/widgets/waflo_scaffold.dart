import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class WafloScaffold extends StatelessWidget {
  const WafloScaffold({
    required this.child,
    super.key,
    this.title,
    this.subtitle,
    this.actions,
    this.scrollable = false,
    this.padding = const EdgeInsetsDirectional.all(AppSpacing.md),
    this.bottomNavigation,
    this.leading,
  });

  final String? title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final bool scrollable;
  final EdgeInsetsGeometry padding;
  final Widget? bottomNavigation;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);

    return Scaffold(
      backgroundColor: AppColors.neutralCanvas,
      appBar: title == null
          ? null
          : WafloAppBar(
              title: title!,
              subtitle: subtitle,
              actions: actions,
              leading: leading,
            ),
      bottomNavigationBar: bottomNavigation,
      body: SafeArea(
        child: scrollable
            ? ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [body],
              )
            : body,
      ),
    );
  }
}

class WafloAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WafloAppBar({
    required this.title,
    super.key,
    this.subtitle,
    this.actions,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 64 : 76);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      actions: actions,
      toolbarHeight: preferredSize.height,
      titleSpacing: leading == null ? AppSpacing.md : 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
