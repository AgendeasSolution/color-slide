import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants/app_colors.dart';
import '../../constants/game_constants.dart';
import '../../utils/responsive_helper.dart';
import '../../models/level.dart';

/// Color indicators widget showing the target colors
class ColorIndicators extends StatelessWidget {
  final Level config;

  const ColorIndicators({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorHeight = ResponsiveHelper.getSpacing(context, GameConstants.colorIndicatorHeight);
    final padding = ResponsiveHelper.getSpacing(context, 4);
    final borderRadius = ResponsiveHelper.getBorderRadius(context, 6);
    final blurRadius = ResponsiveHelper.getSpacing(context, 10);
    final maxBoardWidth = ResponsiveHelper.getMaxBoardWidth(context);
    final screenWidth = ResponsiveHelper.screenWidth(context);
    
    // Match the exact width calculation used by game board (no horizontal padding)
    final boardWidth = math.min(maxBoardWidth, screenWidth);
    
    // Game board has internal padding of 10, so the actual content width is boardWidth - (padding * 2)
    final gameBoardPadding = ResponsiveHelper.getSpacing(context, 10);
    final contentWidth = boardWidth - (gameBoardPadding * 2);
    
    return Center(
      child: SizedBox(
        width: contentWidth,
        child: Row(
          children: config.colors.map((color) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Container(
                  height: indicatorHeight,
                  decoration: BoxDecoration(
                    color: AppColors.ballColors[color],
                    borderRadius: BorderRadius.circular(borderRadius),
                    
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ballColors[color]!.withOpacity(0.3),
                        blurRadius: blurRadius,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
