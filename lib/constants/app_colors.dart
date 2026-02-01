import 'package:flutter/material.dart';

/// App color constants for consistent theming throughout the game
/// Aligned with CSS variables (game-accent, bg-dark, bg-card, etc.)
class AppColors {
  // Game accent (arcade / primary UI, buttons)
  static const gameAccent = Color(0xFF00E5FF);
  static const gameAccentHover = Color(0xFF00B8D4);
  static const gameAccentHoverBright = Color(0xFF33EBFF); // Hover background
  static const gameAccentPress = Color(0xFF0097A7); // Bottom of 3D shadow, press state
  static const gameAccentGlow = Color(0x9900E5FF); // rgba(0, 229, 255, 0.6)
  static const gameAccentDim = Color(0x3300E5FF); // rgba(0, 229, 255, 0.2)
  /// Dark text on accent buttons (icon-btn, modal-btn)
  static const iconBtnTextColor = Color(0xFF0A0E14);

  // Primary colors - use game accent as primary
  static const primary = Color(0xFF00E5FF);
  static const primaryHover = Color(0xFF00B8D4);
  static const secondary = Color(0xFF00E5FF);
  static const accent = Color(0xFF00E5FF);
  
  // Gradient colors for logo and UI elements
  static const gradientStart = Color(0xFF00E5FF);
  static const gradientEnd = Color(0xFF00B8D4);
  static const gradientSecondary = Color(0xFF00E5FF);
  static const gradientTertiary = Color(0xFF0097A7);
  
  // Background colors - dark theme (--bg-dark, --bg-darker, --bg-card)
  static const bgDark = Color(0xFF0A0E14);
  static const bgDarker = Color(0xFF05080C);
  static const bgCard = Color(0xFF0D1219);
  static const bgCardHover = Color(0xFF141C26);
  
  // Neon accent colors
  static const neonBlue = Color(0xFF00D4FF);
  static const neonPink = Color(0xFFFF0080);
  static const neonGreen = Color(0xFF00FF88);
  static const neonPurple = Color(0xFF8A2BE2);
  
  // Text colors (--text-primary, --text-secondary, --text-muted)
  static const textPrimary = Color(0xFFE8F4F8);
  static const textSecondary = Color(0xFF7DD3FC);
  static const textMuted = Color(0xFF0E7490);
  static const textAccent = Color(0xFF00E5FF);

  /// Ball colors (fallback / legacy; emoji cells don't use these for fill)
  static const Map<String, Color> ballColors = {
    'red': Color(0xFFff8585),
    'blue': Color(0xFF3b82f6),
    'yellow': Color(0xFFffe66d),
    'green': Color(0xFF849E00),
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
