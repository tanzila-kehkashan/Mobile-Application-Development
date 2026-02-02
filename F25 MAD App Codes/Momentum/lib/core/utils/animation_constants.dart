import 'package:flutter/material.dart';

/// Centralized animation constants for consistent animations across the app
class AnimationConstants {
  // Private constructor to prevent instantiation
  AnimationConstants._();

  // ============ Durations ============
  
  /// Extra fast animations (button press, micro-interactions)
  static const Duration durationExtraFast = Duration(milliseconds: 100);
  
  /// Fast animations (small UI changes)
  static const Duration durationFast = Duration(milliseconds: 200);
  
  /// Normal animations (standard transitions)
  static const Duration durationNormal = Duration(milliseconds: 300);
  
  /// Slow animations (emphasis, larger transitions)
  static const Duration durationSlow = Duration(milliseconds: 400);
  
  /// Extra slow animations (dramatic effects)
  static const Duration durationExtraSlow = Duration(milliseconds: 500);
  
  /// Page transition duration
  static const Duration pageTransition = Duration(milliseconds: 300);
  
  /// Stagger delay between list items
  static const Duration staggerDelay = Duration(milliseconds: 50);

  // ============ Curves ============
  
  /// Standard ease-in-out curve
  static const Curve curveStandard = Curves.easeInOutCubic;
  
  /// Deceleration curve (for entering elements)
  static const Curve curveDecelerate = Curves.easeOutCubic;
  
  /// Acceleration curve (for exiting elements)
  static const Curve curveAccelerate = Curves.easeInCubic;
  
  /// Bounce curve (for playful animations)
  static const Curve curveBounce = Curves.elasticOut;
  
  /// Overshoot curve (for attention-grabbing)
  static const Curve curveOvershoot = Curves.easeOutBack;
  
  /// Smooth curve for fades
  static const Curve curveFade = Curves.easeOut;

  // ============ Scale Values ============
  
  /// Button press scale
  static const double scalePressed = 0.95;
  
  /// Card entrance scale
  static const double scaleCardEntrance = 0.9;
  
  /// Icon pop scale
  static const double scaleIconPop = 1.2;

  // ============ Offset Values ============
  
  /// Slide in from right offset
  static const Offset slideFromRight = Offset(1.0, 0.0);
  
  /// Slide in from left offset
  static const Offset slideFromLeft = Offset(-1.0, 0.0);
  
  /// Slide in from bottom offset
  static const Offset slideFromBottom = Offset(0.0, 1.0);
  
  /// Slide in from top offset
  static const Offset slideFromTop = Offset(0.0, -1.0);
  
  /// Subtle slide up for list items
  static const Offset subtleSlideUp = Offset(0.0, 0.15);
}

/// Extension for easy animation on widgets
extension AnimatedWidgetExtension on Widget {
  /// Wrap widget with fade-in animation
  Widget fadeIn({
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: this,
    );
  }

  /// Wrap widget with slide-in animation
  Widget slideIn({
    Duration duration = const Duration(milliseconds: 300),
    Offset beginOffset = const Offset(0.0, 0.15),
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: beginOffset, end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            value.dx * MediaQuery.of(context).size.width,
            value.dy * MediaQuery.of(context).size.height,
          ),
          child: child,
        );
      },
      child: this,
    );
  }

  /// Wrap widget with scale animation
  Widget scaleIn({
    Duration duration = const Duration(milliseconds: 300),
    double beginScale = 0.9,
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: beginScale, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: this,
    );
  }
}
