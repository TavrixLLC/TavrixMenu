import 'package:flutter/material.dart';
import '../../../../core/theme/v2/waflo_tokens_v2.dart';

/// Waflo Screen V2 Component
///
/// A layout wrapper combining premium Waflo V2 backgrounds, gradients, AppBars,
/// and layouts. Replaces Scaffold/AppScaffold to ensure aesthetic consistency.
class WafloScreenV2 extends StatelessWidget {
  const WafloScreenV2({
    required this.child,
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.scrollable = true,
    this.padding,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.showGradient = true,
  });

  final Widget child;
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool showGradient;

  @override
  Widget build(BuildContext context) {
    final finalPadding =
        padding ??
        const EdgeInsets.symmetric(
          horizontal: WafloSpacingV2.md,
          vertical: WafloSpacingV2.md,
        );

    Widget bodyContent = child;

    if (scrollable) {
      bodyContent = SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: finalPadding,
        child: child,
      );
    } else {
      bodyContent = Padding(padding: finalPadding, child: child);
    }

    final hasAppBar =
        title != null ||
        titleWidget != null ||
        leading != null ||
        actions != null;

    final backgroundDecoration = showGradient && backgroundColor == null
        ? const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [WafloColorsV2.backgroundWarm, WafloColorsV2.cardWarm],
            ),
          )
        : BoxDecoration(
            color: backgroundColor ?? WafloColorsV2.backgroundCanvas,
          );

    return Scaffold(
      backgroundColor: backgroundColor ?? WafloColorsV2.backgroundCanvas,
      appBar: hasAppBar
          ? AppBar(
              title: titleWidget ?? (title != null ? Text(title!) : null),
              actions: actions,
              leading: leading,
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: backgroundDecoration,
        child: SafeArea(
          bottom: bottomNavigationBar == null,
          child: bodyContent,
        ),
      ),
    );
  }
}
