import 'package:flutter/material.dart';

/// Custom page transitions for the app
class AppPageTransitions {
  AppPageTransitions._();

  /// Fade transition
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

  /// Slide from right transition
  static Widget slideFromRight(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(position: animation.drive(tween), child: child);
  }

  /// Slide from bottom transition
  static Widget slideFromBottom(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(position: animation.drive(tween), child: child);
  }

  /// Scale transition
  static Widget scaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: FadeTransition(opacity: animation, child: child),
    );
  }

  /// Slide and fade transition (combined)
  static Widget slideAndFade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 0.3);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    var slideTween = Tween(
      begin: begin,
      end: end,
    ).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(slideTween),
      child: FadeTransition(opacity: animation, child: child),
    );
  }

  static Route<T> createRoute<T>({
    required Widget page,
    RouteSettings? settings,
    RouteTransitionsBuilder? transitionsBuilder,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: transitionsBuilder ?? slideAndFade,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }
}
