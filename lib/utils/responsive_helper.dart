import 'package:flutter/material.dart';
import '../constants/game_constants.dart';

/// Responsive helper utility for handling various screen sizes
class ResponsiveHelper {
  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is phone (small screen)
  static bool isPhone(BuildContext context) {
    return screenWidth(context) < GameConstants.tabletBreakpoint;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= GameConstants.tabletBreakpoint;
  }

  /// Check if device is large tablet
  static bool isLargeTablet(BuildContext context) {
    return screenWidth(context) >= GameConstants.largeTabletBreakpoint;
  }

  /// Get responsive padding based on screen size
  static double getHorizontalPadding(BuildContext context) {
    if (isLargeTablet(context)) {
      return GameConstants.horizontalPaddingLargeTablet;
    } else if (isTablet(context)) {
      return GameConstants.horizontalPaddingTablet;
    } else {
      return GameConstants.horizontalPaddingMobile;
    }
  }

  /// Get responsive vertical padding
  static double getVerticalPadding(BuildContext context) {
    if (isLargeTablet(context)) {
      return GameConstants.verticalPaddingLargeTablet;
    } else if (isTablet(context)) {
      return GameConstants.verticalPaddingTablet;
    } else {
      return GameConstants.verticalPaddingMobile;
    }
  }

  /// Get responsive font size with scale factor
  static double getFontSize(BuildContext context, double baseFontSize) {
    if (isLargeTablet(context)) {
      return baseFontSize * GameConstants.fontScaleLargeTablet;
    } else if (isTablet(context)) {
      return baseFontSize * GameConstants.fontScaleTablet;
    } else {
      return baseFontSize * GameConstants.fontScaleMobile;
    }
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, double baseIconSize) {
    if (isLargeTablet(context)) {
      return baseIconSize * GameConstants.iconScaleLargeTablet;
    } else if (isTablet(context)) {
      return baseIconSize * GameConstants.iconScaleTablet;
    } else {
      return baseIconSize * GameConstants.iconScaleMobile;
    }
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context, double baseSpacing) {
    if (isLargeTablet(context)) {
      return baseSpacing * GameConstants.spacingScaleLargeTablet;
    } else if (isTablet(context)) {
      return baseSpacing * GameConstants.spacingScaleTablet;
    } else {
      return baseSpacing * GameConstants.spacingScaleMobile;
    }
  }

  /// Get responsive board width
  static double getMaxBoardWidth(BuildContext context) {
    if (isLargeTablet(context)) {
      return GameConstants.maxBoardWidthLargeTablet;
    } else if (isTablet(context)) {
      return GameConstants.maxBoardWidthTablet;
    } else {
      return GameConstants.maxBoardWidthMobile;
    }
  }

  /// Get responsive grid spacing
  static double getGridSpacing(BuildContext context) {
    if (isLargeTablet(context)) {
      return GameConstants.gridSpacingLargeTablet;
    } else if (isTablet(context)) {
      return GameConstants.gridSpacingTablet;
    } else {
      return GameConstants.gridSpacingMobile;
    }
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context, double baseRadius) {
    if (isLargeTablet(context)) {
      return baseRadius * GameConstants.borderRadiusScaleLargeTablet;
    } else if (isTablet(context)) {
      return baseRadius * GameConstants.borderRadiusScaleTablet;
    } else {
      return baseRadius * GameConstants.borderRadiusScaleMobile;
    }
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    if (isLargeTablet(context)) {
      return GameConstants.buttonHeightLargeTablet;
    } else if (isTablet(context)) {
      return GameConstants.buttonHeightTablet;
    } else {
      return GameConstants.buttonHeightMobile;
    }
  }

  /// Get responsive dialog max width
  static double getDialogMaxWidth(BuildContext context) {
    final screenWidth = ResponsiveHelper.screenWidth(context);
    if (isLargeTablet(context)) {
      return GameConstants.maxDialogWidthLargeTablet;
    } else if (isTablet(context)) {
      return GameConstants.maxDialogWidthTablet;
    } else {
      // For mobile, use 90% of screen width with padding
      return screenWidth * 0.9;
    }
  }

  /// Get responsive level grid cross axis count
  static int getLevelGridCrossAxisCount(BuildContext context) {
    if (isLargeTablet(context)) {
      return GameConstants.levelGridCrossAxisCountLargeTablet;
    } else if (isTablet(context)) {
      return GameConstants.levelGridCrossAxisCountTablet;
    } else {
      return GameConstants.levelGridCrossAxisCountMobile;
    }
  }

  /// Get responsive timer widget size
  static double getTimerIconSize(BuildContext context) {
    if (isLargeTablet(context)) {
      return GameConstants.timerIconSizeLargeTablet;
    } else if (isTablet(context)) {
      return GameConstants.timerIconSizeTablet;
    } else {
      return GameConstants.timerIconSizeMobile;
    }
  }

  /// Get responsive timer font size
  static double getTimerFontSize(BuildContext context) {
    if (isLargeTablet(context)) {
      return GameConstants.timerFontSizeLargeTablet;
    } else if (isTablet(context)) {
      return GameConstants.timerFontSizeTablet;
    } else {
      return GameConstants.timerFontSizeMobile;
    }
  }

  /// Get responsive ball padding
  static double getBallPadding(BuildContext context) {
    if (isLargeTablet(context)) {
      return GameConstants.ballPaddingLargeTablet;
    } else if (isTablet(context)) {
      return GameConstants.ballPaddingTablet;
    } else {
      return GameConstants.ballPaddingMobile;
    }
  }
}

