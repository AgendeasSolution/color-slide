import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants/app_colors.dart';
import '../../constants/tile_image_constants.dart';
import '../../constants/game_constants.dart';
import '../../utils/responsive_helper.dart';
import '../../models/level.dart';
import '../../services/sound_service.dart';
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
    final cellPadding = ResponsiveHelper.getBallPadding(context);
    final maxBoardWidth = ResponsiveHelper.getMaxBoardWidth(context);
    
    // Calculate available space from parent constraints
    final screenHeight = ResponsiveHelper.screenHeight(context);
    final screenWidth = ResponsiveHelper.screenWidth(context);
    
    // Estimate header + spacing (timer removed)
    final headerHeight = ResponsiveHelper.getButtonHeight(context);
    final topSpacing = ResponsiveHelper.getSpacing(context, 24);
    final bottomSpacing = ResponsiveHelper.getSpacing(context, 100); // Ad banner + safe area
    final colorIndicatorsHeight = ResponsiveHelper.getSpacing(context, 42);
    final colorIndicatorsSpacing = ResponsiveHelper.getSpacing(context, 12);
    
    // Calculate available vertical space
    final availableHeight = screenHeight - headerHeight - topSpacing - bottomSpacing - colorIndicatorsHeight - colorIndicatorsSpacing;
    
    // Calculate board dimensions based on aspect ratio and available space
    final aspectRatio = config.columns / config.rows;
    
    // Calculate maximum board height based on available space
    final maxBoardHeight = availableHeight * 0.85; // Use 85% of available space for safety
    
    // Calculate board width and height that fit within constraints
    double boardWidth;
    double boardHeight;
    
    // Use full screen width (no horizontal padding) but respect maxBoardWidth
    boardWidth = math.min(maxBoardWidth, screenWidth);
    boardHeight = boardWidth / aspectRatio;
    
    // If height exceeds available space, scale down by height
    if (boardHeight > maxBoardHeight) {
      boardHeight = maxBoardHeight;
      boardWidth = boardHeight * aspectRatio;
    }
    
    // Ensure board doesn't exceed max width
    if (boardWidth > maxBoardWidth) {
      boardWidth = maxBoardWidth;
      boardHeight = boardWidth / aspectRatio;
    }
    
    return Center(
      child: ScaleTransition(
        scale: pulseAnimation,
        child: Container(
          width: boardWidth,
          height: boardHeight,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(cardBorderRadius),
            border: Border.all(
              color: AppColors.gameAccent.withOpacity(0.25),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gameAccentGlow.withOpacity(0.15),
                blurRadius: ResponsiveHelper.getSpacing(context, 35),
                offset: Offset(0, ResponsiveHelper.getSpacing(context, 15)),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: config.columns,
                crossAxisSpacing: gridSpacing,
                mainAxisSpacing: gridSpacing,
                childAspectRatio: ((boardWidth - (padding * 2) - (gridSpacing * (config.columns - 1))) / config.columns) / 
                                 ((boardHeight - (padding * 2) - (gridSpacing * (config.rows - 1))) / config.rows),
              ),
              itemCount: boardState.length,
              itemBuilder: (context, index) {
                final colorName = boardState[index];
                if (colorName == null) {
                  return Padding(
                    padding: EdgeInsets.all(cellPadding),
                    child: const EmptyCell(),
                  );
                }
                final colorIndex = config.colors.indexOf(colorName);
                final imagePath = TileImageConstants.imageForColorIndex(colorIndex);
                return GestureDetector(
                  onTap: () {
                    SoundService.instance.playSwipe();
                    onCellTap(index);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(cellPadding),
                    child: Center(
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
