import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/game_constants.dart';
import '../../models/game_state.dart';

/// Timer widget that displays countdown and progress
class TimerWidget extends StatelessWidget {
  final GameState gameState;
  final int tick; // Force rebuilds

  const TimerWidget({
    super.key,
    required this.gameState,
    required this.tick,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate time in real-time instead of relying on gameState
    final now = DateTime.now();
    final startTime = gameState.startTime;
    
    int remainingTime;
    double timeProgress;
    bool isTimeUp;
    
    if (startTime == null) {
      remainingTime = gameState.currentConfig.timeLimitMinutes * 60;
      timeProgress = 0.0;
      isTimeUp = false;
    } else {
      final elapsed = now.difference(startTime).inSeconds;
      final total = gameState.currentConfig.timeLimitMinutes * 60;
      remainingTime = (total - elapsed).clamp(0, total);
      timeProgress = (elapsed / total).clamp(0.0, 1.0);
      isTimeUp = remainingTime <= 0;
    }
    
    // Debug: Print timer widget rebuild (only every 5 seconds to reduce spam)
    if (tick % 5 == 0) {
      print('🕐 TimerWidget rebuild - Level ${gameState.currentLevel}, Tick: $tick, StartTime: $startTime, Now: $now, Remaining: $remainingTime');
    }
    
    // Color based on remaining time
    Color timerColor;
    if (remainingTime <= 30) {
      timerColor = AppColors.error; // Red when less than 30 seconds
    } else if (remainingTime <= 60) {
      timerColor = AppColors.warning; // Orange when less than 1 minute
    } else {
      timerColor = AppColors.primary; // Blue for normal time
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              color: timerColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _formatTime(remainingTime),
              style: TextStyle(
                color: isTimeUp ? AppColors.error : timerColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress bar
        Container(
          height: 4,
          width: 120,
          decoration: BoxDecoration(
            color: AppColors.bgDarker,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 1.0 - timeProgress,
            child: Container(
              decoration: BoxDecoration(
                color: timerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
