import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/game_constants.dart';
import '../../utils/responsive_helper.dart';
import '../../services/sound_service.dart';

/// Game ball widget
class GameBall extends StatelessWidget {
  final String colorName;
  final VoidCallback? onTap;

  const GameBall({
    super.key,
    required this.colorName,
    this.onTap,
  });

  void _handleTap() {
    SoundService.instance.playSwipe();
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final ballPadding = ResponsiveHelper.getBallPadding(context);
    final borderRadius = ResponsiveHelper.getBorderRadius(context, GameConstants.borderRadius);
    final blurRadius = ResponsiveHelper.getSpacing(context, 8);
    final shadowOffset = ResponsiveHelper.getSpacing(context, 4);
    
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgDarker,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: EdgeInsets.all(ballPadding),
        child: AnimatedContainer(
          duration: GameConstants.ballMoveAnimation,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.ballColors[colorName],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: blurRadius,
                spreadRadius: 1,
                offset: Offset(0, shadowOffset),
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
