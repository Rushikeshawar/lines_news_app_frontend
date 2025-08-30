import 'package:flutter/material.dart';

class InteractiveSlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration transitionDuration;

  InteractiveSlideUpPageRoute({
    required this.child,
    this.transitionDuration = const Duration(milliseconds: 400),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: transitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Main slide animation
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var slideTween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            // Scale animation for more natural feel
            var scaleTween = Tween(begin: 0.95, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            // Opacity animation
            var opacityTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(slideTween),
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                child: FadeTransition(
                  opacity: animation.drive(opacityTween),
                  child: child,
                ),
              ),
            );
          },
        );

  // Remove the conflicting overrides - they're not needed
  // The default implementations work fine for our use case
}
