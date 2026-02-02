import 'package:flutter/material.dart';

/// Custom page route with fade transition
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

/// Custom page route with slide from right transition
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

/// Custom page route with slide from bottom transition
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

/// Custom page route with scale and fade transition
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScalePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeOutBack;

            var scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: curve),
            );

            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
              ),
            );

            return ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Custom page route with shared axis transition (horizontal)
class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SharedAxisPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade + slight slide for material shared axis effect
            const curve = Curves.easeInOutCubic;

            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: curve),
            );

            var slideAnimation = Tween<Offset>(
              begin: const Offset(0.05, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: curve));

            // Secondary animation for the exiting page
            var secondaryFade = Tween<double>(begin: 1.0, end: 0.9).animate(
              CurvedAnimation(parent: secondaryAnimation, curve: curve),
            );

            return FadeTransition(
              opacity: secondaryFade,
              child: SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: child,
                ),
              ),
            );
          },
        );
}

/// Extension to simplify navigation with transitions
extension NavigatorExtension on NavigatorState {
  /// Push with slide transition
  Future<T?> pushSlide<T>(Widget page) {
    return push(SlidePageRoute<T>(page: page));
  }

  /// Push with fade transition
  Future<T?> pushFade<T>(Widget page) {
    return push(FadePageRoute<T>(page: page));
  }

  /// Push with slide up transition
  Future<T?> pushSlideUp<T>(Widget page) {
    return push(SlideUpPageRoute<T>(page: page));
  }

  /// Push with scale transition
  Future<T?> pushScale<T>(Widget page) {
    return push(ScalePageRoute<T>(page: page));
  }

  /// Push replacement with fade transition
  Future<T?> pushReplacementFade<T, TO>(Widget page) {
    return pushReplacement(FadePageRoute<T>(page: page));
  }

  /// Push replacement with slide transition
  Future<T?> pushReplacementSlide<T, TO>(Widget page) {
    return pushReplacement(SlidePageRoute<T>(page: page));
  }
}
