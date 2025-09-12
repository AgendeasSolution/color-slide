/// Game configuration constants
class GameConstants {
  // Animation durations
  static const Duration ballMoveAnimation = Duration(milliseconds: 200);
  static const Duration pulseAnimation = Duration(milliseconds: 500);
  static const Duration shimmerAnimation = Duration(seconds: 2);
  static const Duration winDelay = Duration(milliseconds: 1500);
  static const Duration winCheckDelay = Duration(milliseconds: 100);
  
  // UI constants
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double progressBarHeight = 6.0;
  static const double colorIndicatorHeight = 12.0;
  
  // Responsive breakpoints
  static const double tabletBreakpoint = 600.0;
  static const double maxBoardWidthTablet = 500.0;
  static const double maxBoardWidthMobile = 400.0;
  
  // Padding and spacing
  static const double horizontalPaddingMobile = 12.0;
  static const double horizontalPaddingTablet = 20.0;
  static const double verticalPadding = 15.0;
  static const double gridSpacing = 8.0;
  static const double ballPadding = 4.0;
  
  // Dialog constraints
  static const double maxDialogWidth = 500.0;
  static const double dialogHorizontalPadding = 25.0;
  static const double dialogVerticalPadding = 30.0;
}
