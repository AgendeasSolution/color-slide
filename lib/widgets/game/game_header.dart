import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/game_constants.dart';

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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Exit button (top-left)
        ElevatedButton(
          onPressed: onExit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textSecondary.withOpacity(0.1),
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GameConstants.borderRadius),
              side: BorderSide(
                color: AppColors.textSecondary.withOpacity(0.3),
                width: 1,
              ),
            ),
            minimumSize: const Size(48, 48),
          ),
          child: const Icon(Icons.arrow_back, size: 20),
        ),
        
        // Level name (center)
        Expanded(
          child: Center(
            child: Text(
              "Level $currentLevel",
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        
        // Reset button (top-right)
        ElevatedButton(
          onPressed: onReset,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.bgDark,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GameConstants.borderRadius),
            ),
            minimumSize: const Size(48, 48),
          ),
          child: const Icon(Icons.refresh, size: 20),
        ),
      ],
    );
  }
}
