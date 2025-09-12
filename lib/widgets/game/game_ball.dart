import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/game_constants.dart';

/// Game ball widget
class GameBall extends StatelessWidget {
  final String colorName;
  final VoidCallback? onTap;

  const GameBall({
    super.key,
    required this.colorName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgDarker,
          borderRadius: BorderRadius.circular(GameConstants.borderRadius),
        ),
        padding: const EdgeInsets.all(GameConstants.ballPadding),
        child: AnimatedContainer(
          duration: GameConstants.ballMoveAnimation,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.ballColors[colorName],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 0.5,
              alignment: const Alignment(-0.5, -0.5),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.6),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
