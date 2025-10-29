import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/game_constants.dart';
import '../../utils/responsive_helper.dart';
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
    
    // If startTime is null, show full time (timer not started)
    // If timerPaused is true, show full time (timer paused)
    if (startTime == null || gameState.timerPaused) {
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
    
    // Color based on remaining time
    Color timerColor;
    if (remainingTime <= 30) {
      timerColor = AppColors.error; // Red when less than 30 seconds
    } else if (remainingTime <= 60) {
      timerColor = AppColors.warning; // Orange when less than 1 minute
    } else {
      timerColor = AppColors.primary; // Blue for normal time
    }

    final iconSize = ResponsiveHelper.getTimerIconSize(context);
    final fontSize = ResponsiveHelper.getTimerFontSize(context);
    final spacing = ResponsiveHelper.getSpacing(context, 8);
    final progressBarHeight = ResponsiveHelper.getSpacing(context, 4);
    final progressBarWidth = ResponsiveHelper.getSpacing(context, 120);
    
    return Container(
      margin: EdgeInsets.only(top: spacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              color: timerColor,
              size: iconSize,
            ),
            SizedBox(width: spacing),
            Text(
              _formatTime(remainingTime),
              style: TextStyle(
                color: isTimeUp ? AppColors.error : timerColor,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        // Progress bar
        Container(
          height: progressBarHeight,
          width: progressBarWidth,
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
