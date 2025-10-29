import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/game_constants.dart';
import '../../utils/responsive_helper.dart';
import '../../models/level.dart';
import 'game_ball.dart';
import 'empty_cell.dart';

/// Game board widget
class GameBoard extends StatelessWidget {
  final Level config;
  final List<String?> boardState;
  final int emptyCellIndex;
  final Function(int) onCellTap;
  final Animation<double> pulseAnimation;

  const GameBoard({
    super.key,
    required this.config,
    required this.boardState,
    required this.emptyCellIndex,
    required this.onCellTap,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final gridSpacing = ResponsiveHelper.getGridSpacing(context);
    final cardBorderRadius = ResponsiveHelper.getBorderRadius(context, GameConstants.cardBorderRadius);
    final padding = ResponsiveHelper.getSpacing(context, 10);
    
    return Center(
      child: ScaleTransition(
        scale: pulseAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: config.colors.map((colorName) => 
                AppColors.ballColors[colorName]!.withOpacity(0.15)
              ).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(cardBorderRadius),
            border: Border.all(
              color: config.colors.isNotEmpty 
                ? AppColors.ballColors[config.colors.first]!.withOpacity(0.3)
                : AppColors.primary.withOpacity(0.1)
            ),
            boxShadow: [
              BoxShadow(
                color: config.colors.isNotEmpty 
                  ? AppColors.ballColors[config.colors.first]!.withOpacity(0.2)
                  : Colors.black.withOpacity(0.2),
                blurRadius: ResponsiveHelper.getSpacing(context, 35),
                offset: Offset(0, ResponsiveHelper.getSpacing(context, 15)),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: config.gridSize,
                  crossAxisSpacing: gridSpacing,
                  mainAxisSpacing: gridSpacing,
                ),
                itemCount: boardState.length,
                itemBuilder: (context, index) {
                  final colorName = boardState[index];
                  return colorName != null
                      ? GameBall(
                          colorName: colorName,
                          onTap: () => onCellTap(index),
                        )
                      : const EmptyCell();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
