import 'dart:math';
import '../models/level.dart';

/// Game logic utilities
class GameLogic {
  /// Creates a solved board state for the given level configuration
  /// Ensures no two same-colored balls are adjacent (horizontally, vertically, or diagonally)
  static List<String?> createSolvedBoard(Level config) {
    final int boardSize = config.columns * config.rows;
    List<String?> solvedState = List.filled(boardSize, null);
    
    // Set the empty cell at the end
    final emptyIndex = boardSize - 1;
    solvedState[emptyIndex] = null;
    
    // Generate a valid color distribution using column-by-column approach
    _generateColumnWiseValidBoard(solvedState, config);
    
    // Ensure exactly one empty cell and validate adjacency
    int nullCount = solvedState.where((cell) => cell == null).length;
    if (nullCount != 1 || !validateBoardDistribution(solvedState, config.columns, config.rows)) {
      // Emergency fix: fill any remaining nulls with valid colors
      for (int i = 0; i < boardSize; i++) {
        if (i != emptyIndex && solvedState[i] == null) {
          // Try to find a valid color for this position
          bool filled = false;
          for (String color in config.colors) {
            if (_isColorValidAtPosition(solvedState, config, i, color, emptyIndex)) {
              solvedState[i] = color;
              filled = true;
              break;
            }
          }
          // If no valid color found with strict rules, try any color
          if (!filled) {
            solvedState[i] = config.colors[0];
          }
        }
      }
      
      // Final validation - if still invalid, regenerate completely
      if (!validateBoardDistribution(solvedState, config.columns, config.rows)) {
        // Clear and regenerate from scratch
        for (int i = 0; i < boardSize; i++) {
          solvedState[i] = null;
        }
        solvedState[emptyIndex] = null;
        
        // Calculate color counts
        final int cellsToFill = boardSize - 1;
        final Map<String, int> colorCounts = {};
        for (String color in config.colors) {
          colorCounts[color] = cellsToFill ~/ config.colors.length;
        }
        final int remainder = cellsToFill % config.colors.length;
        for (int i = 0; i < remainder; i++) {
          colorCounts[config.colors[i]] = colorCounts[config.colors[i]]! + 1;
        }
        
        // Use fallback directly
        _generateFallbackCheckerboard(solvedState, config, colorCounts, emptyIndex);
      }
    }
    
    return solvedState;
  }

  /// Generates a valid board using advanced backtracking with constraint propagation
  static void _generateColumnWiseValidBoard(List<String?> board, Level config) {
    final int columns = config.columns;
    final int rows = config.rows;
    final int emptyIndex = board.length - 1;
    
    // Calculate how many times each color should appear
    final int cellsToFill = board.length - 1; // Exclude empty cell
    final Map<String, int> colorCounts = {};
    
    for (String color in config.colors) {
      colorCounts[color] = cellsToFill ~/ config.colors.length;
    }
    
    // Distribute remaining cells to first few colors
    final int remainder = cellsToFill % config.colors.length;
    for (int i = 0; i < remainder; i++) {
      colorCounts[config.colors[i]] = colorCounts[config.colors[i]]! + 1;
    }
    
    // Create list of positions to fill (excluding empty cell)
    List<int> positions = [];
    for (int i = 0; i < board.length; i++) {
      if (i != emptyIndex) positions.add(i);
    }
    
    // Sort positions by constraint level (most constrained first)
    positions.sort((a, b) => _getConstraintLevel(b, columns, rows, emptyIndex) - _getConstraintLevel(a, columns, rows, emptyIndex));
    
    // Use backtracking to place colors
    bool success = _backtrackWithSmartPlacement(board, config, colorCounts, positions, 0, emptyIndex);
    
    if (!success) {
      _generateFallbackBoard(board, config, colorCounts, emptyIndex);
    }
  }

  /// Calculates constraint level for a position (number of neighbors)
  static int _getConstraintLevel(int index, int columns, int rows, int emptyIndex) {
    final int row = index ~/ columns;
    final int col = index % columns;
    int constraints = 0;
    
    // Count neighbors
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        
        final int newRow = row + dr;
        final int newCol = col + dc;
        
        if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < columns) {
          final int neighborIndex = newRow * columns + newCol;
          if (neighborIndex != emptyIndex) {
            constraints++;
          }
        }
      }
    }
    
    return constraints;
  }

  /// Backtracking with smart placement and constraint propagation
  static bool _backtrackWithSmartPlacement(
    List<String?> board,
    Level config,
    Map<String, int> colorCounts,
    List<int> positions,
    int positionIndex,
    int emptyIndex,
  ) {
    if (positionIndex >= positions.length) {
      return true; // All positions filled successfully
    }
    
    final int currentPos = positions[positionIndex];
    
    // Get available colors for this position
    List<String> availableColors = _getAvailableColorsForPosition(board, config, currentPos, colorCounts, emptyIndex);
    
    // Try each available color
    for (String color in availableColors) {
      // Place the color
      board[currentPos] = color;
      colorCounts[color] = colorCounts[color]! - 1;
      
      // Recursively try next position
      if (_backtrackWithSmartPlacement(board, config, colorCounts, positions, positionIndex + 1, emptyIndex)) {
        return true;
      }
      
      // Backtrack: remove the color and restore count
      board[currentPos] = null;
      colorCounts[color] = colorCounts[color]! + 1;
    }
    
    return false; // No valid color found for this position
  }

  /// Gets available colors for a position that don't conflict with neighbors.
  /// Prefers colors that are farthest from their siblings so same emoji is distributed wildly.
  static List<String> _getAvailableColorsForPosition(
    List<String?> board,
    Level config,
    int index,
    Map<String, int> colorCounts,
    int emptyIndex,
  ) {
    List<String> availableColors = [];
    
    for (String color in config.colors) {
      if (colorCounts[color]! > 0 && _isColorValidAtPosition(board, config, index, color, emptyIndex)) {
        availableColors.add(color);
      }
    }
    
    // Prefer colors that spread same emoji far apart (max distance to nearest same color)
    final withDistance = availableColors.map((c) => (
      c,
      _minDistanceToNearestSameColor(board, config.columns, config.rows, index, c, emptyIndex),
    )).toList();
    withDistance.sort((a, b) => b.$2.compareTo(a.$2)); // larger distance first
    final maxDist = withDistance.isNotEmpty ? withDistance.first.$2 : 0;
    final best = withDistance.where((e) => e.$2 == maxDist).map((e) => e.$1).toList();
    best.shuffle(Random());
    final rest = withDistance.where((e) => e.$2 != maxDist).map((e) => e.$1).toList();
    rest.shuffle(Random());
    return [...best, ...rest];
  }

  /// Minimum Chebyshev distance (max of row diff, col diff) from [index] to any cell with [color].
  /// Used to spread same emoji as far apart as possible.
  static int _minDistanceToNearestSameColor(
    List<String?> board,
    int columns,
    int rows,
    int index,
    String color,
    int emptyIndex,
  ) {
    final row0 = index ~/ columns;
    final col0 = index % columns;
    int minDist = columns + rows; // large if no same color yet
    
    for (int i = 0; i < board.length; i++) {
      if (i == emptyIndex || board[i] != color) continue;
      final r = i ~/ columns;
      final c = i % columns;
      final dist = (row0 - r).abs() > (col0 - c).abs() ? (row0 - r).abs() : (col0 - c).abs();
      if (dist < minDist) minDist = dist;
    }
    return minDist;
  }

  /// Fallback method: never place same emoji adjacent. Retry with new position order until valid.
  static void _generateFallbackBoard(
    List<String?> board,
    Level config,
    Map<String, int> colorCounts,
    int emptyIndex,
  ) {
    const int maxTries = 50;
    for (int tryCount = 0; tryCount < maxTries; tryCount++) {
      // Clear all cells (keep empty)
      for (int i = 0; i < board.length; i++) {
        board[i] = null;
      }
      Map<String, int> remaining = Map.from(colorCounts);
      List<int> positions = [];
      for (int i = 0; i < board.length; i++) {
        if (i != emptyIndex) positions.add(i);
      }
      positions.shuffle(Random());
      bool allPlaced = true;
      for (int pos in positions) {
        List<String> available = [];
        for (String color in config.colors) {
          if ((remaining[color] ?? 0) > 0 &&
              _isColorValidAtPosition(board, config, pos, color, emptyIndex)) {
            available.add(color);
          }
        }
        if (available.isEmpty) {
          // Cannot find valid placement - retry with different shuffle
          allPlaced = false;
          break;
        }
        // Prefer color that spreads same emoji far (same as main backtrack)
        available.sort((a, b) {
          final da = _minDistanceToNearestSameColor(board, config.columns, config.rows, pos, a, emptyIndex);
          final db = _minDistanceToNearestSameColor(board, config.columns, config.rows, pos, b, emptyIndex);
          return db.compareTo(da);
        });
        final color = available[Random().nextInt(available.length)];
        board[pos] = color;
        remaining[color] = remaining[color]! - 1;
      }
      if (allPlaced) return;
    }
    // Last resort: fill using checkerboard-style order so same color never adjacent
    _generateFallbackCheckerboard(board, config, colorCounts, emptyIndex);
  }

  /// Last-resort fill: try diagonal order so same color tends to spread; retry until no adjacent same.
  static void _generateFallbackCheckerboard(
    List<String?> board,
    Level config,
    Map<String, int> colorCounts,
    int emptyIndex,
  ) {
    final int columns = config.columns;
    // Increase attempts significantly for better success rate
    for (int attempt = 0; attempt < 100; attempt++) {
      for (int i = 0; i < board.length; i++) {
        board[i] = null;
      }
      List<int> positions = [];
      for (int i = 0; i < board.length; i++) {
        if (i != emptyIndex) positions.add(i);
      }
      positions.sort((a, b) {
        final ra = a ~/ columns, ca = a % columns;
        final rb = b ~/ columns, cb = b % columns;
        final sumA = ra + ca, sumB = rb + cb;
        if (sumA != sumB) return sumA.compareTo(sumB);
        return ra.compareTo(rb);
      });
      // Always shuffle except first attempt
      if (attempt > 0) positions.shuffle(Random());
      Map<String, int> remaining = Map.from(colorCounts);
      bool ok = true;
      for (int pos in positions) {
        List<String> available = [];
        for (String color in config.colors) {
          if ((remaining[color] ?? 0) > 0 &&
              _isColorValidAtPosition(board, config, pos, color, emptyIndex)) {
            available.add(color);
          }
        }
        if (available.isEmpty) { 
          ok = false; 
          break; 
        }
        available.shuffle(Random());
        final color = available.first;
        board[pos] = color;
        remaining[color] = remaining[color]! - 1;
      }
      if (ok && validateBoardDistribution(board, columns, config.rows)) {
        return; // Success!
      }
    }
    
    // If still failing, there might be an impossible configuration
    // Fill remaining nulls carefully with validation
    for (int i = 0; i < board.length; i++) {
      if (i != emptyIndex && board[i] == null) {
        for (String color in config.colors) {
          if (_isColorValidAtPosition(board, config, i, color, emptyIndex)) {
            board[i] = color;
            break;
          }
        }
      }
    }
  }


  /// Checks if a color is valid at a specific position (no adjacent same colors)
  /// Only checks orthogonal neighbors (up, down, left, right), not diagonals
  static bool _isColorValidAtPosition(
    List<String?> board,
    Level config,
    int index,
    String color,
    int emptyIndex,
  ) {
    final int columns = config.columns;
    final int rows = config.rows;
    final int row = index ~/ columns;
    final int col = index % columns;
    
    // Check only orthogonal directions (up, down, left, right)
    final List<List<int>> directions = [
      [-1, 0], // up
      [1, 0],  // down
      [0, -1], // left
      [0, 1],  // right
    ];
    
    for (final dir in directions) {
      final int newRow = row + dir[0];
      final int newCol = col + dir[1];
      
      // Check bounds
      if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < columns) {
        final int neighborIndex = newRow * columns + newCol;
        
        // Skip empty cell
        if (neighborIndex == emptyIndex) continue;
        
        // Check if neighbor has the same color
        if (board[neighborIndex] == color) {
          return false; // Same color found in orthogonal position
        }
      }
    }
    
    return true; // Color is valid at this position
  }



  /// Shuffles the board by making random valid moves while maintaining adjacency constraints
  static Map<String, dynamic> shuffleBoard(
    List<String?> boardState,
    int emptyCellIndex,
    Level config,
  ) {
    List<String?> shuffledBoard = List.from(boardState);
    int currentEmptyIndex = emptyCellIndex;
    int attempts = 0;
    const int maxAttempts = 1000; // Prevent infinite loops

    int validMovesDone = 0;
    while (validMovesDone < config.shuffleMoves && attempts < maxAttempts) {
      final neighbors = _getValidNeighbors(currentEmptyIndex, config.columns, config.rows);
      final shuffledNeighbors = List<int>.from(neighbors)..shuffle(Random());
      bool moved = false;
      for (int neighbor in shuffledNeighbors) {
        if (_isValidMove(shuffledBoard, neighbor, currentEmptyIndex, config)) {
          _swapCells(shuffledBoard, neighbor, currentEmptyIndex);
          currentEmptyIndex = neighbor;
          moved = true;
          validMovesDone++;
          break;
        }
      }
      if (!moved) break; // no valid move exists – stop to keep board valid
      attempts++;
    }

    return {
      'boardState': shuffledBoard,
      'emptyCellIndex': currentEmptyIndex,
    };
  }

  /// Checks if a move would maintain adjacency constraints
  static bool _isValidMove(
    List<String?> board,
    int fromIndex,
    int toIndex,
    Level config,
  ) {
    // Create a temporary board to test the move
    List<String?> tempBoard = List.from(board);
    _swapCells(tempBoard, fromIndex, toIndex);
    
    // Check if the move creates any adjacent same colors
    return validateBoardDistribution(tempBoard, config.columns, config.rows);
  }

  /// Checks if two cells are adjacent
  static bool isAdjacent(int index1, int index2, int columns, int rows) {
    final row1 = index1 ~/ columns;
    final col1 = index1 % columns;
    final row2 = index2 ~/ columns;
    final col2 = index2 % columns;

    return (row1 == row2 && (col1 - col2).abs() == 1) ||
        (col1 == col2 && (row1 - row2).abs() == 1);
  }

  /// Gets valid neighbor indices for a given cell
  static List<int> _getValidNeighbors(int index, int columns, int rows) {
    List<int> neighbors = [];
    final row = index ~/ columns;
    final col = index % columns;

    if (row > 0) neighbors.add(index - columns); // Up
    if (row < rows - 1) neighbors.add(index + columns); // Down
    if (col > 0) neighbors.add(index - 1); // Left
    if (col < columns - 1) neighbors.add(index + 1); // Right

    return neighbors;
  }

  /// Swaps two cells in the board
  static void _swapCells(List<String?> board, int index1, int index2) {
    final temp = board[index1];
    board[index1] = board[index2];
    board[index2] = temp;
  }

  /// Checks if the current board state is a winning state
  static bool checkWinCondition(List<String?> boardState, Level config) {
    final int boardSize = config.columns * config.rows;
    for (int i = 0; i < boardSize; i++) {
      if (boardState[i] == null) continue;

      final targetColor = config.colors[i % config.colors.length];
      if (boardState[i] != targetColor) {
        return false; // Not a win yet
      }
    }
    return true;
  }

  /// Moves a ball from one position to another
  static Map<String, dynamic> moveBall(
    List<String?> boardState,
    int fromIndex,
    int toIndex,
  ) {
    List<String?> newBoardState = List.from(boardState);
    _swapCells(newBoardState, fromIndex, toIndex);
    
    // The empty cell is always the one that was originally empty (toIndex)
    // After swapping, the ball moves to the empty position, so fromIndex becomes empty
    final newEmptyIndex = fromIndex;
    
    return {
      'boardState': newBoardState,
      'emptyCellIndex': newEmptyIndex,
    };
  }

  /// Validates that no two same-colored balls are adjacent in the board
  /// Returns true if the board is valid (no orthogonally adjacent same colors), false otherwise
  static bool validateBoardDistribution(List<String?> boardState, int columns, int rows) {
    for (int i = 0; i < boardState.length; i++) {
      if (boardState[i] == null) continue;
      
      final int row = i ~/ columns;
      final int col = i % columns;
      
      // Check only orthogonal directions (up, down, left, right)
      final List<List<int>> directions = [
        [-1, 0], // up
        [1, 0],  // down
        [0, -1], // left
        [0, 1],  // right
      ];
      
      for (final dir in directions) {
        final int newRow = row + dir[0];
        final int newCol = col + dir[1];
        
        if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < columns) {
          final int neighborIndex = newRow * columns + newCol;
          if (boardState[neighborIndex] != null &&
              boardState[i] == boardState[neighborIndex]) {
            return false; // Same color found in orthogonal position
          }
        }
      }
    }
    return true;
  }
}
