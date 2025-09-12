import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/game_constants.dart';
import '../../models/level.dart';

/// Stats content widget for win and game complete dialogs
class StatsContent extends StatelessWidget {
  final int moves;
  final String time;

  const StatsContent({
    super.key,
    required this.moves,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGameComplete = moves == -1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgDarker,
        borderRadius: BorderRadius.circular(GameConstants.borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StatItem(
            label: isGameComplete ? "Total Levels" : "Moves",
            value: isGameComplete
                ? GameLevels.levels.length.toString()
                : moves.toString(),
          ),
          if (!isGameComplete) StatItem(label: "Time", value: time),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String label;
  final String value;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
