import 'package:flutter/material.dart';

/// Responsive utility class for adaptive sizing across different screen sizes
/// 
/// Breakpoints:
/// - Mobile: 0 - 600dp
/// - Tablet: 600 - 1200dp
/// - Desktop: 1200dp+
class ResponsiveUtils {
  final BuildContext context;
  
  ResponsiveUtils(this.context);
  
  /// Get screen width
  double get width => MediaQuery.of(context).size.width;
  
  /// Get screen height
  double get height => MediaQuery.of(context).size.height;
  
  /// Check if device is mobile
  bool get isMobile => width < 600;
  
  /// Check if device is tablet
  bool get isTablet => width >= 600 && width < 1200;
  
  /// Check if device is desktop
  bool get isDesktop => width >= 1200;
  
  /// Scale value based on width percentage
  double scale(double value) {
    return width * (value / 375); // 375 is base width (iPhone SE)
  }
  
  /// Responsive padding
  double padding({double mobile = 16, double tablet = 24, double desktop = 32}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }
  
  /// Responsive button height
  double buttonHeight({double mobile = 48, double tablet = 56, double desktop = 64}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }
  
  /// Responsive icon size
  double iconSize({double mobile = 24, double tablet = 28, double desktop = 32}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }
}

/// Extension on BuildContext for easy access to responsive utils
extension ResponsiveContext on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils(this);
}

/// Predefined size constants for common UI elements
class AppSizes {
  // Spacing
  static double spaceXS(BuildContext context) => context.responsive.scale(4);
  static double spaceS(BuildContext context) => context.responsive.scale(8);
  static double spaceM(BuildContext context) => context.responsive.scale(16);
  static double spaceL(BuildContext context) => context.responsive.scale(24);
  static double spaceXL(BuildContext context) => context.responsive.scale(32);
  
  // Padding
  static double paddingXS(BuildContext context) => context.responsive.scale(4);
  static double paddingS(BuildContext context) => context.responsive.scale(8);
  static double paddingM(BuildContext context) => context.responsive.scale(16);
  static double paddingL(BuildContext context) => context.responsive.scale(24);
  static double paddingXL(BuildContext context) => context.responsive.scale(32);
  
  // Font sizes
  static double fontXS(BuildContext context) => context.responsive.scale(10);
  static double fontS(BuildContext context) => context.responsive.scale(12);
  static double fontM(BuildContext context) => context.responsive.scale(14);
  static double fontL(BuildContext context) => context.responsive.scale(16);
  static double fontXL(BuildContext context) => context.responsive.scale(20);
  static double fontXXL(BuildContext context) => context.responsive.scale(24);
  
  // Icon sizes
  static double iconS(BuildContext context) => context.responsive.scale(16);
  static double iconM(BuildContext context) => context.responsive.scale(24);
  static double iconL(BuildContext context) => context.responsive.scale(32);
  static double iconXL(BuildContext context) => context.responsive.scale(48);
  
  // Border radius
  static double radiusS(BuildContext context) => context.responsive.scale(4);
  static double radiusM(BuildContext context) => context.responsive.scale(8);
  static double radiusL(BuildContext context) => context.responsive.scale(12);
  static double radiusXL(BuildContext context) => context.responsive.scale(16);
}
