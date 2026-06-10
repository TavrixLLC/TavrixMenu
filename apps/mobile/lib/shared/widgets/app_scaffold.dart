import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.child,
    super.key,
    this.title,
    this.actions,
    this.scrollable = false,
    this.padding = const EdgeInsetsDirectional.all(AppSpacing.md),
    this.bottomNavigation,
  });

  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final bool scrollable;
  final EdgeInsetsGeometry padding;
  final Widget? bottomNavigation;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);

    return Scaffold(
      backgroundColor: AppColors.neutralWarm,
      appBar: title == null
          ? null
          : AppBar(title: Text(title!), actions: actions),
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
