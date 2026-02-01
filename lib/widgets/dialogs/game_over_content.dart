import 'package:flutter/material.dart';
import '../../models/game_state.dart';

/// Game over dialog content widget
class GameOverContent extends StatelessWidget {
  final GameState gameState;
  final bool isAllLevelsCompleted;

  const GameOverContent({
    super.key,
    required this.gameState,
    this.isAllLevelsCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
