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
    final buttonHeight = ResponsiveHelper.getButtonHeight(context) * 0.8; // 20% smaller
    final iconSize = ResponsiveHelper.getIconSize(context, 14.4); // 18 * 0.8 = 14.4 (20% smaller)
    final fontSize = ResponsiveHelper.getFontSize(context, 16); // 20 * 0.8 = 16 (20% smaller)
    final buttonPadding = ResponsiveHelper.getSpacing(context, 8);
    final borderRadius = ResponsiveHelper.getBorderRadius(context, GameConstants.borderRadius);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Exit button (top-left)
        ElevatedButton(
          onPressed: _handleExit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.all(buttonPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              
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
                color: Colors.white,
                fontSize: fontSize * 1.3, // 16 * 1.3 = 20.8 (smaller than before)
                fontWeight: FontWeight.w900,
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
            foregroundColor: Colors.white, // Changed to white to match back button
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
