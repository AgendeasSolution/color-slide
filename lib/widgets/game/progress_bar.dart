import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/game_constants.dart';
import '../../models/level.dart';
import '../common/shimmer_effect.dart';

/// Progress bar widget showing level completion
class ProgressBar extends StatelessWidget {
  final int currentLevel;
  final int totalLevels;
  final AnimationController shimmerController;

  const ProgressBar({
    super.key,
    required this.currentLevel,
    required this.totalLevels,
    required this.shimmerController,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = currentLevel / totalLevels;
    
    return Container(
      height: GameConstants.progressBarHeight,
      decoration: BoxDecoration(
        color: AppColors.bgDarker,
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress,
            child: ShimmerEffect(
              controller: shimmerController,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFFFFD93D)],
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
