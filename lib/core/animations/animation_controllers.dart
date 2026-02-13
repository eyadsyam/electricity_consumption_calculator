import 'package:flutter/material.dart';

/// Slide animation controller for widgets
class SlideAnimationController {
  SlideAnimationController._();

  /// Slide in from left
  static Widget slideInFromLeft({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, offset, child) {
        return FractionalTranslation(translation: offset, child: child);
      },
      child: child,
    );
  }

  /// Slide in from right
  static Widget slideInFromRight({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, offset, child) {
        return FractionalTranslation(translation: offset, child: child);
      },
      child: child,
    );
  }

  /// Slide in from top
  static Widget slideInFromTop({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(0.0, -1.0), end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, offset, child) {
        return FractionalTranslation(translation: offset, child: child);
      },
      child: child,
    );
  }

  /// Slide in from bottom
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(0.0, 1.0), end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, offset, child) {
        return FractionalTranslation(translation: offset, child: child);
      },
      child: child,
    );
  }
}

/// Fade animation controller
class FadeAnimationController {
  FadeAnimationController._();

  /// Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeIn,
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: child,
    );
  }

  /// Fade in with slide
  static Widget fadeInWithSlide({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Offset begin = const Offset(0.0, 0.3),
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            begin.dx * (1 - value) * 100,
            begin.dy * (1 - value) * 100,
          ),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

/// Scale animation controller
class ScaleAnimationController {
  ScaleAnimationController._();

  /// Scale up animation
  static Widget scaleUp({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.easeOutBack,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }

  /// Scale with fade
  static Widget scaleWithFade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    double beginScale = 0.8,
    double endScale = 1.0,
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        final scale = beginScale + (endScale - beginScale) * value;
        return Transform.scale(
          scale: scale,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

/// Rotation animation controller
class RotationAnimationController {
  RotationAnimationController._();

  /// Rotate animation
  static Widget rotate({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, turns, child) {
        return RotationTransition(
          turns: AlwaysStoppedAnimation(turns),
          child: child,
        );
      },
      child: child,
    );
  }
}
