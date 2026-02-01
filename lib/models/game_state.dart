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
    );
  }
}
