/// Level configuration model
class Level {
  final int level;
  final int gridSize;
  final List<String> colors;
  final int shuffleMoves;
  final int timeLimitMinutes;

  const Level({
    required this.level,
    required this.gridSize,
    required this.colors,
    required this.shuffleMoves,
    required this.timeLimitMinutes,
  });
}

/// Game levels configuration
class GameLevels {
  static const List<Level> levels = [
    Level(
      level: 1,
      gridSize: 4,
      colors: ["red", "blue", "yellow", "green"],
      shuffleMoves: 50,
      timeLimitMinutes: 1, // 1 second per move: 50 moves = 1 minute
    ),
    Level(
      level: 2,
      gridSize: 5,
      colors: ["red", "blue", "yellow", "green", "purple"],
      shuffleMoves: 75,
      timeLimitMinutes: 2, // 1 second per move: 75 moves = 2 minutes
    ),
    Level(
      level: 3,
      gridSize: 6,
      colors: ["red", "blue", "yellow", "green", "purple", "orange"],
      shuffleMoves: 125,
      timeLimitMinutes: 3, // 1 second per move: 125 moves = 3 minutes
    ),
    Level(
      level: 4,
      gridSize: 7,
      colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan"],
      shuffleMoves: 175,
      timeLimitMinutes: 4, // 1 second per move: 175 moves = 4 minutes
    ),
    Level(
      level: 5,
      gridSize: 8,
      colors: [
        "red",
        "blue",
        "yellow",
        "green",
        "purple",
        "orange",
        "cyan",
        "pink",
      ],
      shuffleMoves: 225,
      timeLimitMinutes: 5, // 1 second per move: 225 moves = 5 minutes
    ),
    Level(
      level: 6,
      gridSize: 9,
      colors: [
        "red",
        "blue",
        "yellow",
        "green",
        "purple",
        "orange",
        "cyan",
        "pink",
        "teal",
      ],
      shuffleMoves: 325,
      timeLimitMinutes: 6, // 1 second per move: 325 moves = 6 minutes
    ),
    Level(
      level: 7,
      gridSize: 10,
      colors: [
        "red",
        "blue",
        "yellow",
        "green",
        "purple",
        "orange",
        "cyan",
        "pink",
        "teal",
        "indigo",
      ],
      shuffleMoves: 350,
      timeLimitMinutes: 7, // 1 second per move: 350 moves = 7 minutes
    ),
    Level(
      level: 8,
      gridSize: 11,
      colors: [
        "red",
        "blue",
        "yellow",
        "green",
        "purple",
        "orange",
        "cyan",
        "pink",
        "teal",
        "indigo",
        "lime",
      ],
      shuffleMoves: 375,
      timeLimitMinutes: 7, // 1 second per move: 375 moves = 7 minutes
    ),
  ];
}
