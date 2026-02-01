import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import '../constants/app_colors.dart';

/// Optimized responsive utility for handling various screen sizes
/// Consolidates all responsive helper methods in one place
class ResponsiveHelper {
  ResponsiveHelper._(); // Private constructor to prevent instantiation

  // Cache MediaQuery to avoid repeated lookups
  static MediaQueryData _getMediaQuery(BuildContext context) {
    return MediaQuery.of(context);
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return _getMediaQuery(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return _getMediaQuery(context).size.height;
  }

  /// Get device type enum for better performance
  static _DeviceType _getDeviceType(BuildContext context) {
    final width = screenWidth(context);
    if (width >= GameConstants.largeTabletBreakpoint) {
      return _DeviceType.largeTablet;
    } else if (width >= GameConstants.tabletBreakpoint) {
      return _DeviceType.tablet;
    }
    return _DeviceType.phone;
  }

  /// Check if device is phone (small screen)
  static bool isPhone(BuildContext context) {
    return _getDeviceType(context) == _DeviceType.phone;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final type = _getDeviceType(context);
    return type == _DeviceType.tablet || type == _DeviceType.largeTablet;
  }

  /// Check if device is large tablet
  static bool isLargeTablet(BuildContext context) {
    return _getDeviceType(context) == _DeviceType.largeTablet;
  }

  /// Get responsive scale factor based on device type
  static double _getScaleFactor(BuildContext context, {
    required double mobile,
    required double tablet,
    required double largeTablet,
  }) {
    switch (_getDeviceType(context)) {
      case _DeviceType.largeTablet:
        return largeTablet;
      case _DeviceType.tablet:
        return tablet;
      case _DeviceType.phone:
        return mobile;
    }
  }

  /// Get responsive padding based on screen size
  static double getHorizontalPadding(BuildContext context) {
    return _getScaleFactor(
      context,
      mobile: GameConstants.horizontalPaddingMobile,
      tablet: GameConstants.horizontalPaddingTablet,
      largeTablet: GameConstants.horizontalPaddingLargeTablet,
    );
  }

  /// Get responsive vertical padding
  static double getVerticalPadding(BuildContext context) {
    return _getScaleFactor(
      context,
      mobile: GameConstants.verticalPaddingMobile,
      tablet: GameConstants.verticalPaddingTablet,
      largeTablet: GameConstants.verticalPaddingLargeTablet,
    );
  }

  /// Get responsive font size with scale factor
  static double getFontSize(BuildContext context, double baseFontSize) {
    return baseFontSize * _getScaleFactor(
      context,
      mobile: GameConstants.fontScaleMobile,
      tablet: GameConstants.fontScaleTablet,
      largeTablet: GameConstants.fontScaleLargeTablet,
    );
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, double baseIconSize) {
    return baseIconSize * _getScaleFactor(
      context,
      mobile: GameConstants.iconScaleMobile,
      tablet: GameConstants.iconScaleTablet,
      largeTablet: GameConstants.iconScaleLargeTablet,
    );
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context, double baseSpacing) {
    return baseSpacing * _getScaleFactor(
      context,
      mobile: GameConstants.spacingScaleMobile,
      tablet: GameConstants.spacingScaleTablet,
      largeTablet: GameConstants.spacingScaleLargeTablet,
    );
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    return getSpacing(context, baseSpacing);
  }

  /// Get responsive board width
  static double getMaxBoardWidth(BuildContext context) {
    return _getScaleFactor(
      context,
      mobile: GameConstants.maxBoardWidthMobile,
      tablet: GameConstants.maxBoardWidthTablet,
      largeTablet: GameConstants.maxBoardWidthLargeTablet,
    );
  }

  /// Get responsive grid spacing
  static double getGridSpacing(BuildContext context) {
    return _getScaleFactor(
      context,
      mobile: GameConstants.gridSpacingMobile,
      tablet: GameConstants.gridSpacingTablet,
      largeTablet: GameConstants.gridSpacingLargeTablet,
    );
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context, double baseRadius) {
    return baseRadius * _getScaleFactor(
      context,
      mobile: GameConstants.borderRadiusScaleMobile,
      tablet: GameConstants.borderRadiusScaleTablet,
      largeTablet: GameConstants.borderRadiusScaleLargeTablet,
    );
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context, double baseRadius) {
    return getBorderRadius(context, baseRadius);
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    return _getScaleFactor(
      context,
      mobile: GameConstants.buttonHeightMobile,
      tablet: GameConstants.buttonHeightTablet,
      largeTablet: GameConstants.buttonHeightLargeTablet,
    );
  }

  /// Get responsive dialog max width
  static double getDialogMaxWidth(BuildContext context) {
    final type = _getDeviceType(context);
    if (type == _DeviceType.largeTablet) {
      return GameConstants.maxDialogWidthLargeTablet;
    } else if (type == _DeviceType.tablet) {
      return GameConstants.maxDialogWidthTablet;
    } else {
      // For mobile, use 90% of screen width with padding
      return screenWidth(context) * 0.9;
    }
  }

  /// Get responsive level grid cross axis count
  static int getLevelGridCrossAxisCount(BuildContext context) {
    return _getScaleFactor(
      context,
      mobile: GameConstants.levelGridCrossAxisCountMobile.toDouble(),
      tablet: GameConstants.levelGridCrossAxisCountTablet.toDouble(),
      largeTablet: GameConstants.levelGridCrossAxisCountLargeTablet.toDouble(),
    ).toInt();
  }

  /// Get responsive ball padding
  static double getBallPadding(BuildContext context) {
    return _getScaleFactor(
      context,
      mobile: GameConstants.ballPaddingMobile,
      tablet: GameConstants.ballPaddingTablet,
      largeTablet: GameConstants.ballPaddingLargeTablet,
    );
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
    return TextStyle(
      fontSize: getFontSize(context, baseFontSize),
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Get responsive box shadow
  static List<BoxShadow> getResponsiveBoxShadow(
    BuildContext context, {
    required Color color,
    required double baseBlurRadius,
    required double baseSpreadRadius,
    required Offset baseOffset,
  }) {
    return [
      BoxShadow(
        color: color,
        blurRadius: getSpacing(context, baseBlurRadius),
        spreadRadius: getSpacing(context, baseSpreadRadius),
        offset: baseOffset,
      ),
    ];
  }
}

/// Internal enum for device types
enum _DeviceType {
  phone,
  tablet,
  largeTablet,
}

