import 'package:flutter/material.dart';

/// App color constants for consistent theming throughout the game
class AppColors {
  // Primary colors - Vibrant game colors
  static const primary = Color(0xFFFF6B35);
  static const primaryHover = Color(0xFFE55A2B);
  static const secondary = Color(0xFF4ECDC4);
  static const accent = Color(0xFFFFE66D);
  
  // Gradient colors for logo and UI elements
  static const gradientStart = Color(0xFFFF6B35);
  static const gradientEnd = Color(0xFFFFE66D);
  static const gradientSecondary = Color(0xFF4ECDC4);
  static const gradientTertiary = Color(0xFF45B7AA);
  
  // Background colors - Deep space theme
  static const bgDark = Color(0xFF0A0A0F);
  static const bgDarker = Color(0xFF050508);
  static const bgCard = Color(0xFF1A1A2E);
  static const bgCardHover = Color(0xFF2A2A3E);
  
  // Neon accent colors
  static const neonBlue = Color(0xFF00D4FF);
  static const neonPink = Color(0xFFFF0080);
  static const neonGreen = Color(0xFF00FF88);
  static const neonPurple = Color(0xFF8A2BE2);
  
  // Text colors
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB8B8D1);
  static const textMuted = Color(0xFF6B6B8A);
  static const textAccent = Color(0xFFFFE66D);

  /// Ball colors used in the game - Enhanced vibrant colors
  static const Map<String, Color> ballColors = {
    'red': Color(0xFFff6b6b),
    'blue': Color(0xFF3b82f6),
    'yellow': Color(0xFFffe66d),
    'green': Color(0xFF95e1d3),
    'purple': Color(0xFF9c27b0),
    'orange': Color(0xFFff9800),
    'cyan': Color(0xFF00bcd4),
    'pink': Color(0xFFe91e63),
    'teal': Color(0xFF009688),
    'indigo': Color(0xFF3f51b5),
    'lime': Color(0xFFcddc39),
  };
  
  // Level difficulty colors
  static const easy = Color(0xFF2ED573);
  static const medium = Color(0xFFFFE66D);
  static const hard = Color(0xFFFF4757);
  static const expert = Color(0xFF8A2BE2);
  
  // Status colors
  static const success = Color(0xFF2ED573);
  static const error = Color(0xFFFF4757);
  static const warning = Color(0xFFFFA726);
  
  // Card colors
  static const cardDark = Color(0xFF1A1A2E);
  
  // Additional colors for other games screen
  static const background = bgDark;
  static const surface = bgCard;
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const border = Color(0xFF2A2A3E);
  static const surfaceLight = Color(0xFF2A2A3E);
  static const transparent = Color(0x00000000);
  
  // Gradient lists
  static const List<Color> surfaceGradient = [
    bgCard,
    bgCardHover,
  ];
  
  static const List<Color> buttonGradient = [
    primary,
    primaryHover,
  ];
}
