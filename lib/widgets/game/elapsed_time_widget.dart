import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/responsive_helper.dart';
import '../../models/game_state.dart';

/// Elapsed time widget that displays the time since game started
class ElapsedTimeWidget extends StatelessWidget {
  final GameState gameState;
  final int tick; // Force rebuilds

  const ElapsedTimeWidget({
    super.key,
    required this.gameState,
    required this.tick,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate elapsed time in real-time
    final now = DateTime.now();
    final startTime = gameState.startTime;
    
    int elapsedSeconds = 0;
    
    if (startTime != null && !gameState.timerPaused) {
      final end = gameState.endTime ?? now;
      elapsedSeconds = end.difference(startTime).inSeconds;
    }
    
    final fontSize = ResponsiveHelper.getFontSize(context, 18);
    final iconSize = ResponsiveHelper.getIconSize(context, 20);
    final spacing = ResponsiveHelper.getSpacing(context, 8);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getSpacing(context, 12),
        vertical: ResponsiveHelper.getSpacing(context, 6),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.ballColors['blue']!,
            AppColors.ballColors['cyan']!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context, 12)),
       
        boxShadow: [
          BoxShadow(
            color: AppColors.ballColors['blue']!.withOpacity(0.6),
            blurRadius: ResponsiveHelper.getSpacing(context, 8),
            spreadRadius: ResponsiveHelper.getSpacing(context, 1),
            offset: Offset(0, ResponsiveHelper.getSpacing(context, 2)),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            color: Colors.white,
            size: iconSize,
          ),
          SizedBox(width: spacing),
          Text(
            _formatTime(elapsedSeconds),
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.8),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
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
