/// Level configuration model
class Level {
  final int level;
  final int columns;
  final int rows;
  final List<String> colors;
  final int shuffleMoves;
  final int timeLimitMinutes;

  const Level({
    required this.level,
    required this.columns,
    required this.rows,
    required this.colors,
    required this.shuffleMoves,
    required this.timeLimitMinutes,
  });

  /// Total number of cells (columns * rows)
  int get totalCells => columns * rows;
  
  /// For backward compatibility - returns columns (assuming square grid)
  @Deprecated('Use columns instead')
  int get gridSize => columns;
}

/// Game levels configuration
class GameLevels {
  static const List<Level> levels = [
    // Levels 1-3: 4 columns
    Level(
      level: 1,
      columns: 4,
      rows: 4,
      colors: ["red", "blue", "yellow", "green"],
      shuffleMoves: 50,
      timeLimitMinutes: 1,
    ),
    Level(
      level: 2,
      columns: 4,
      rows: 5,
      colors: ["red", "blue", "yellow", "green"],
      shuffleMoves: 60,
      timeLimitMinutes: 1,
    ),
    Level(
      level: 3,
      columns: 4,
      rows: 6,
      colors: ["red", "blue", "yellow", "green"],
      shuffleMoves: 70,
      timeLimitMinutes: 2,
    ),
    // Levels 4-6: 5 columns
    Level(
      level: 4,
      columns: 5,
      rows: 5,
      colors: ["red", "blue", "yellow", "green", "purple"],
      shuffleMoves: 80,
      timeLimitMinutes: 2,
    ),
    Level(
      level: 5,
      columns: 5,
      rows: 6,
      colors: ["red", "blue", "yellow", "green", "purple"],
      shuffleMoves: 95,
      timeLimitMinutes: 2,
    ),
    Level(
      level: 6,
      columns: 5,
      rows: 7,
      colors: ["red", "blue", "yellow", "green", "purple"],
      shuffleMoves: 110,
      timeLimitMinutes: 3,
    ),
    // Levels 7-9: 6 columns
    Level(
      level: 7,
      columns: 6,
      rows: 6,
      colors: ["red", "blue", "yellow", "green", "purple", "orange"],
      shuffleMoves: 125,
      timeLimitMinutes: 3,
    ),
    Level(
      level: 8,
      columns: 6,
      rows: 7,
      colors: ["red", "blue", "yellow", "green", "purple", "orange"],
      shuffleMoves: 145,
      timeLimitMinutes: 3,
    ),
    Level(
      level: 9,
      columns: 6,
      rows: 8,
      colors: ["red", "blue", "yellow", "green", "purple", "orange"],
      shuffleMoves: 165,
      timeLimitMinutes: 4,
    ),
    // Levels 10-12: 7 columns
    Level(
      level: 10,
      columns: 7,
      rows: 7,
      colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan"],
      shuffleMoves: 175,
      timeLimitMinutes: 4,
    ),
    Level(
      level: 11,
      columns: 7,
      rows: 8,
      colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan"],
      shuffleMoves: 200,
      timeLimitMinutes: 4,
    ),
    Level(
      level: 12,
      columns: 7,
      rows: 9,
      colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan"],
      shuffleMoves: 225,
      timeLimitMinutes: 5,
    ),
    // Levels 13-15: 8 columns
    Level(
      level: 13,
      columns: 8,
      rows: 8,
      colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink"],
      shuffleMoves: 250,
      timeLimitMinutes: 5,
    ),
    Level(
      level: 14,
      columns: 8,
      rows: 9,
      colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink"],
      shuffleMoves: 280,
      timeLimitMinutes: 5,
    ),
    Level(
      level: 15,
      columns: 8,
      rows: 10,
      colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink"],
      shuffleMoves: 310,
      timeLimitMinutes: 6,
    ),
    // Levels 16-18: 9 columns
    Level(
      level: 16,
      columns: 9,
      rows: 9,
      colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink", "teal"],
      shuffleMoves: 325,
      timeLimitMinutes: 6,
    ),
    Level(
      level: 17,
      columns: 9,
      rows: 10,
      colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink", "teal"],
      shuffleMoves: 360,
      timeLimitMinutes: 6,
    ),
    Level(
      level: 18,
      columns: 9,
      rows: 11,
      colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink", "teal"],
      shuffleMoves: 395,
      timeLimitMinutes: 7,
    ),
  ];
}
