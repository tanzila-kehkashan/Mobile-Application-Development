import 'package:flutter/material.dart';

/// Custom page route with slide transition from right
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}

/// Custom page route with fade transition
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                Tween(begin: 0.0, end: 1.0).chain(
                  CurveTween(curve: Curves.easeIn),
                ),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 200),
        );
}

/// Custom page route with scale transition
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  ScalePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.9;
            const end = 1.0;
            const curve = Curves.easeOutCubic;
            
            var scaleTween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            
            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );
            
            return ScaleTransition(
              scale: animation.drive(scaleTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}

/// Custom page route with slide up transition (for modals/sheets)
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  SlideUpPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}

/// Extension to easily push routes with custom transitions
extension NavigatorExtension on NavigatorState {
  Future<T?> pushSlide<T>(Widget page) {
    return push(SlidePageRoute<T>(page: page));
  }
  
  Future<T?> pushFade<T>(Widget page) {
    return push(FadePageRoute<T>(page: page));
  }
  
  Future<T?> pushScale<T>(Widget page) {
    return push(ScalePageRoute<T>(page: page));
  }
  
  Future<T?> pushSlideUp<T>(Widget page) {
    return push(SlideUpPageRoute<T>(page: page));
  }
  
  Future<T?> pushReplacementSlide<T, TO>(Widget page) {
    return pushReplacement(SlidePageRoute<T>(page: page));
  }
  
  Future<T?> pushAndRemoveUntilSlide<T>(Widget page, RoutePredicate predicate) {
    return pushAndRemoveUntil(SlidePageRoute<T>(page: page), predicate);
  }
}

/// Helper class for navigation with transitions
class AppNavigator {
  static Future<T?> push<T>(BuildContext context, Widget page, {PageTransitionType type = PageTransitionType.slide}) {
    switch (type) {
      case PageTransitionType.slide:
        return Navigator.of(context).push(SlidePageRoute<T>(page: page));
      case PageTransitionType.fade:
        return Navigator.of(context).push(FadePageRoute<T>(page: page));
      case PageTransitionType.scale:
        return Navigator.of(context).push(ScalePageRoute<T>(page: page));
      case PageTransitionType.slideUp:
        return Navigator.of(context).push(SlideUpPageRoute<T>(page: page));
    }
  }
  
  static Future<T?> pushReplacement<T, TO>(BuildContext context, Widget page, {PageTransitionType type = PageTransitionType.slide}) {
    switch (type) {
      case PageTransitionType.slide:
        return Navigator.of(context).pushReplacement(SlidePageRoute<T>(page: page));
      case PageTransitionType.fade:
        return Navigator.of(context).pushReplacement(FadePageRoute<T>(page: page));
      case PageTransitionType.scale:
        return Navigator.of(context).pushReplacement(ScalePageRoute<T>(page: page));
      case PageTransitionType.slideUp:
        return Navigator.of(context).pushReplacement(SlideUpPageRoute<T>(page: page));
    }
  }
  
  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget page, RoutePredicate predicate, {PageTransitionType type = PageTransitionType.fade}) {
    switch (type) {
      case PageTransitionType.slide:
        return Navigator.of(context).pushAndRemoveUntil(SlidePageRoute<T>(page: page), predicate);
      case PageTransitionType.fade:
        return Navigator.of(context).pushAndRemoveUntil(FadePageRoute<T>(page: page), predicate);
      case PageTransitionType.scale:
        return Navigator.of(context).pushAndRemoveUntil(ScalePageRoute<T>(page: page), predicate);
      case PageTransitionType.slideUp:
        return Navigator.of(context).pushAndRemoveUntil(SlideUpPageRoute<T>(page: page), predicate);
    }
  }
}

enum PageTransitionType {
  slide,
  fade,
  scale,
  slideUp,
}
