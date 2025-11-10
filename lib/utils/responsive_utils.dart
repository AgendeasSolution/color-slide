import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../constants/app_colors.dart';

/// Responsive utilities wrapper for consistent API
class ResponsiveUtils {
  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    return ResponsiveHelper.getSpacing(context, baseSpacing);
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
    final fontSize = ResponsiveHelper.getFontSize(context, baseFontSize);
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context, double baseRadius) {
    return ResponsiveHelper.getBorderRadius(context, baseRadius);
  }

  /// Get responsive box shadow
  static List<BoxShadow> getResponsiveBoxShadow(
    BuildContext context, {
    required Color color,
    required double baseBlurRadius,
    required double baseSpreadRadius,
    required Offset baseOffset,
  }) {
    final blurRadius = ResponsiveHelper.getSpacing(context, baseBlurRadius);
    final spreadRadius = ResponsiveHelper.getSpacing(context, baseSpreadRadius);
    return [
      BoxShadow(
        color: color,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
        offset: baseOffset,
      ),
    ];
  }
}

