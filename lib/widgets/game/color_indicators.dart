import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/game_constants.dart';
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
    return Center(
      child: Row(
        children: config.colors.map((color) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Container(
                height: GameConstants.colorIndicatorHeight,
                decoration: BoxDecoration(
                  color: AppColors.ballColors[color],
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ballColors[color]!.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
