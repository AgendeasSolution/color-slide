import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/game_constants.dart';
import '../../utils/responsive_helper.dart';
import '../../services/sound_service.dart';

/// Game header widget with exit button, level name, and reset button
class GameHeader extends StatelessWidget {
  final int currentLevel;
  final VoidCallback onReset;
  final VoidCallback onExit;

  const GameHeader({
    super.key,
    required this.currentLevel,
    required this.onReset,
    required this.onExit,
  });

  void _handleExit() {
    SoundService.instance.playButtonTap();
    onExit();
  }

  void _handleReset() {
    SoundService.instance.playButtonTap();
    onReset();
  }

  @override
  Widget build(BuildContext context) {
    final buttonHeight = ResponsiveHelper.getButtonHeight(context);
    final iconSize = ResponsiveHelper.getIconSize(context, 18);
    final fontSize = ResponsiveHelper.getFontSize(context, 20);
    final buttonPadding = ResponsiveHelper.getSpacing(context, 8);
    final borderRadius = ResponsiveHelper.getBorderRadius(context, GameConstants.borderRadius);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Exit button (top-left)
        ElevatedButton(
          onPressed: _handleExit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textSecondary.withOpacity(0.1),
            foregroundColor: AppColors.textSecondary,
            padding: EdgeInsets.all(buttonPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(
                color: AppColors.textSecondary.withOpacity(0.3),
                width: 1,
              ),
            ),
            minimumSize: Size(buttonHeight, buttonHeight),
          ),
          child: Icon(Icons.arrow_back, size: iconSize),
        ),
        
        // Level name (center)
        Expanded(
          child: Center(
            child: Text(
              "Level $currentLevel",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        
        // Reset button (top-right)
        ElevatedButton(
          onPressed: _handleReset,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.bgDark,
            padding: EdgeInsets.all(buttonPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            minimumSize: Size(buttonHeight, buttonHeight),
          ),
          child: Icon(Icons.refresh, size: iconSize),
        ),
      ],
    );
  }
}
