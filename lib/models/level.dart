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
}

/// Game levels configuration – each grid appears twice (level count x2)
class GameLevels {
  static const List<Level> levels = [
    // Levels 1-2: 3x3
    Level(level: 1, columns: 3, rows: 3, colors: ["red", "blue", "yellow"], shuffleMoves: 35, timeLimitMinutes: 1),
    Level(level: 2, columns: 3, rows: 3, colors: ["red", "blue", "yellow"], shuffleMoves: 35, timeLimitMinutes: 1),
    // Levels 3-4: 3x4
    Level(level: 3, columns: 3, rows: 4, colors: ["red", "blue", "yellow"], shuffleMoves: 45, timeLimitMinutes: 1),
    Level(level: 4, columns: 3, rows: 4, colors: ["red", "blue", "yellow"], shuffleMoves: 45, timeLimitMinutes: 1),
    // Levels 5-6: 3x5
    Level(level: 5, columns: 3, rows: 5, colors: ["red", "blue", "yellow"], shuffleMoves: 55, timeLimitMinutes: 1),
    Level(level: 6, columns: 3, rows: 5, colors: ["red", "blue", "yellow"], shuffleMoves: 55, timeLimitMinutes: 1),
    // Levels 7-8: 4x4
    Level(level: 7, columns: 4, rows: 4, colors: ["red", "blue", "yellow", "green"], shuffleMoves: 50, timeLimitMinutes: 1),
    Level(level: 8, columns: 4, rows: 4, colors: ["red", "blue", "yellow", "green"], shuffleMoves: 50, timeLimitMinutes: 1),
    // Levels 9-10: 4x5
    Level(level: 9, columns: 4, rows: 5, colors: ["red", "blue", "yellow", "green"], shuffleMoves: 60, timeLimitMinutes: 1),
    Level(level: 10, columns: 4, rows: 5, colors: ["red", "blue", "yellow", "green"], shuffleMoves: 60, timeLimitMinutes: 1),
    // Levels 11-12: 4x6
    Level(level: 11, columns: 4, rows: 6, colors: ["red", "blue", "yellow", "green"], shuffleMoves: 70, timeLimitMinutes: 2),
    Level(level: 12, columns: 4, rows: 6, colors: ["red", "blue", "yellow", "green"], shuffleMoves: 70, timeLimitMinutes: 2),
    // Levels 13-14: 5x5
    Level(level: 13, columns: 5, rows: 5, colors: ["red", "blue", "yellow", "green", "purple"], shuffleMoves: 80, timeLimitMinutes: 2),
    Level(level: 14, columns: 5, rows: 5, colors: ["red", "blue", "yellow", "green", "purple"], shuffleMoves: 80, timeLimitMinutes: 2),
    // Levels 15-16: 5x6
    Level(level: 15, columns: 5, rows: 6, colors: ["red", "blue", "yellow", "green", "purple"], shuffleMoves: 95, timeLimitMinutes: 2),
    Level(level: 16, columns: 5, rows: 6, colors: ["red", "blue", "yellow", "green", "purple"], shuffleMoves: 95, timeLimitMinutes: 2),
    // Levels 17-18: 5x7
    Level(level: 17, columns: 5, rows: 7, colors: ["red", "blue", "yellow", "green", "purple"], shuffleMoves: 110, timeLimitMinutes: 3),
    Level(level: 18, columns: 5, rows: 7, colors: ["red", "blue", "yellow", "green", "purple"], shuffleMoves: 110, timeLimitMinutes: 3),
    // Levels 19-20: 6x6
    Level(level: 19, columns: 6, rows: 6, colors: ["red", "blue", "yellow", "green", "purple", "orange"], shuffleMoves: 125, timeLimitMinutes: 3),
    Level(level: 20, columns: 6, rows: 6, colors: ["red", "blue", "yellow", "green", "purple", "orange"], shuffleMoves: 125, timeLimitMinutes: 3),
    // Levels 21-22: 6x7
    Level(level: 21, columns: 6, rows: 7, colors: ["red", "blue", "yellow", "green", "purple", "orange"], shuffleMoves: 145, timeLimitMinutes: 3),
    Level(level: 22, columns: 6, rows: 7, colors: ["red", "blue", "yellow", "green", "purple", "orange"], shuffleMoves: 145, timeLimitMinutes: 3),
    // Levels 23-24: 6x8
    Level(level: 23, columns: 6, rows: 8, colors: ["red", "blue", "yellow", "green", "purple", "orange"], shuffleMoves: 165, timeLimitMinutes: 4),
    Level(level: 24, columns: 6, rows: 8, colors: ["red", "blue", "yellow", "green", "purple", "orange"], shuffleMoves: 165, timeLimitMinutes: 4),
    // Levels 25-26: 7x7
    Level(level: 25, columns: 7, rows: 7, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan"], shuffleMoves: 175, timeLimitMinutes: 4),
    Level(level: 26, columns: 7, rows: 7, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan"], shuffleMoves: 175, timeLimitMinutes: 4),
    // Levels 27-28: 7x8
    Level(level: 27, columns: 7, rows: 8, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan"], shuffleMoves: 200, timeLimitMinutes: 4),
    Level(level: 28, columns: 7, rows: 8, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan"], shuffleMoves: 200, timeLimitMinutes: 4),
    // Levels 29-30: 7x9
    Level(level: 29, columns: 7, rows: 9, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan"], shuffleMoves: 225, timeLimitMinutes: 5),
    Level(level: 30, columns: 7, rows: 9, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan"], shuffleMoves: 225, timeLimitMinutes: 5),
    // Levels 31-32: 8x8
    Level(level: 31, columns: 8, rows: 8, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink"], shuffleMoves: 250, timeLimitMinutes: 5),
    Level(level: 32, columns: 8, rows: 8, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink"], shuffleMoves: 250, timeLimitMinutes: 5),
    // Levels 33-34: 8x9
    Level(level: 33, columns: 8, rows: 9, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink"], shuffleMoves: 280, timeLimitMinutes: 5),
    Level(level: 34, columns: 8, rows: 9, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink"], shuffleMoves: 280, timeLimitMinutes: 5),
    // Levels 35-36: 8x10
    Level(level: 35, columns: 8, rows: 10, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink"], shuffleMoves: 310, timeLimitMinutes: 6),
    Level(level: 36, columns: 8, rows: 10, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink"], shuffleMoves: 310, timeLimitMinutes: 6),
    // Levels 37-38: 9x9
    Level(level: 37, columns: 9, rows: 9, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink", "teal"], shuffleMoves: 325, timeLimitMinutes: 6),
    Level(level: 38, columns: 9, rows: 9, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink", "teal"], shuffleMoves: 325, timeLimitMinutes: 6),
    // Levels 39-40: 9x10
    Level(level: 39, columns: 9, rows: 10, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink", "teal"], shuffleMoves: 360, timeLimitMinutes: 6),
    Level(level: 40, columns: 9, rows: 10, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink", "teal"], shuffleMoves: 360, timeLimitMinutes: 6),
    // Levels 41-42: 9x11
    Level(level: 41, columns: 9, rows: 11, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink", "teal"], shuffleMoves: 395, timeLimitMinutes: 7),
    Level(level: 42, columns: 9, rows: 11, colors: ["red", "blue", "yellow", "green", "purple", "orange", "cyan", "pink", "teal"], shuffleMoves: 395, timeLimitMinutes: 7),
  ];
}
