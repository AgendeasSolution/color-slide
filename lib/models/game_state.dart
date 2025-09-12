import 'level.dart';

/// Game state model
class GameState {
  final int currentLevel;
  final Level currentConfig;
  final List<String?> boardState;
  final List<String?> initialBoardState;
  final int emptyCellIndex;
  final int initialEmptyCellIndex;
  final bool gameWon;
  final bool gameOver;
  final int moves;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool timeUp;
  final bool timerPaused;

  const GameState({
    required this.currentLevel,
    required this.currentConfig,
    required this.boardState,
    required this.initialBoardState,
    required this.emptyCellIndex,
    required this.initialEmptyCellIndex,
    required this.gameWon,
    required this.gameOver,
    required this.moves,
    this.startTime,
    this.endTime,
    this.timeUp = false,
    this.timerPaused = false,
  });

  GameState copyWith({
    int? currentLevel,
    Level? currentConfig,
    List<String?>? boardState,
    List<String?>? initialBoardState,
    int? emptyCellIndex,
    int? initialEmptyCellIndex,
    bool? gameWon,
    bool? gameOver,
    int? moves,
    DateTime? startTime,
    DateTime? endTime,
    bool? timeUp,
    bool? timerPaused,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      currentConfig: currentConfig ?? this.currentConfig,
      boardState: boardState ?? this.boardState,
      initialBoardState: initialBoardState ?? this.initialBoardState,
      emptyCellIndex: emptyCellIndex ?? this.emptyCellIndex,
      initialEmptyCellIndex: initialEmptyCellIndex ?? this.initialEmptyCellIndex,
      gameWon: gameWon ?? this.gameWon,
      gameOver: gameOver ?? this.gameOver,
      moves: moves ?? this.moves,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeUp: timeUp ?? this.timeUp,
      timerPaused: timerPaused ?? this.timerPaused,
    );
  }

  /// Get elapsed time in seconds
  int get elapsedTimeInSeconds {
    if (startTime == null || timerPaused) return 0;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!).inSeconds;
  }

  /// Get formatted elapsed time as MM:SS
  String get formattedElapsedTime {
    final seconds = elapsedTimeInSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Get remaining time in seconds
  int get remainingTimeInSeconds {
    if (startTime == null || timerPaused) return currentConfig.timeLimitMinutes * 60;
    final elapsed = elapsedTimeInSeconds;
    final total = currentConfig.timeLimitMinutes * 60;
    return (total - elapsed).clamp(0, total);
  }

  /// Get formatted remaining time as MM:SS
  String get formattedRemainingTime {
    final seconds = remainingTimeInSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Check if time is up
  bool get isTimeUp {
    return remainingTimeInSeconds <= 0;
  }

  /// Get time progress as a percentage (0.0 to 1.0)
  double get timeProgress {
    if (startTime == null) return 1.0;
    final elapsed = elapsedTimeInSeconds;
    final total = currentConfig.timeLimitMinutes * 60;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}
