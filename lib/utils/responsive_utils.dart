import 'package:flutter/material.dart';
import 'responsive_helper.dart';

/// Responsive utilities - exports ResponsiveHelper methods for backward compatibility
/// 
/// This class is deprecated. Use ResponsiveHelper directly for better performance.
/// Kept for backward compatibility with existing code.
@Deprecated('Use ResponsiveHelper directly instead')
class ResponsiveUtils {
  ResponsiveUtils._(); // Private constructor

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    return ResponsiveHelper.getResponsiveSpacing(context, baseSpacing);
  }

  /// Get responsive text style
  static TextStyle getResponsiveTextStyle(
    BuildContext context, {
    required double baseFontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return ResponsiveHelper.getResponsiveTextStyle(
      context,
      baseFontSize: baseFontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context, double baseRadius) {
    return ResponsiveHelper.getResponsiveBorderRadius(context, baseRadius);
  }

  /// Get responsive box shadow
  static List<BoxShadow> getResponsiveBoxShadow(
    BuildContext context, {
    required Color color,
    required double baseBlurRadius,
    required double baseSpreadRadius,
    required Offset baseOffset,
  }) {
    return ResponsiveHelper.getResponsiveBoxShadow(
      context,
      color: color,
      baseBlurRadius: baseBlurRadius,
      baseSpreadRadius: baseSpreadRadius,
      baseOffset: baseOffset,
    );
  }
}

