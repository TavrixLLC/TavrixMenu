import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// A [PageTransitionsBuilder] that uses Material [SharedAxisTransition]
/// from Google's animations package (same effect as Google Photos, Play Store).
/// Applied globally via [PageTransitionsTheme] so every named route gets
/// a smooth horizontal slide-fade transition automatically.
class FadeThroughPageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeThroughPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.horizontal,
      child: child,
    );
  }
}
