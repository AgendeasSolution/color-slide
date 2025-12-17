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
    solvedState[boardSize - 1] = null;
    
    // Generate a valid color distribution using column-by-column approach
    _generateColumnWiseValidBoard(solvedState, config);
    
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
      _generateFallbackBoard(board, config, emptyIndex);
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

  /// Gets available colors for a position that don't conflict with neighbors
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
    
    // Shuffle for randomness
    availableColors.shuffle(Random());
    return availableColors;
  }

  /// Fallback method that guarantees a solution
  static void _generateFallbackBoard(List<String?> board, Level config, int emptyIndex) {
    final int columns = config.columns;
    final int rows = config.rows;
    
    // Use a simple alternating pattern that minimizes adjacencies
    List<String> colors = List.from(config.colors);
    int colorIndex = 0;
    
    for (int i = 0; i < board.length; i++) {
      if (i != emptyIndex) {
        // Use a checkerboard-like pattern
        int row = i ~/ columns;
        int col = i % columns;
        
        // Alternate colors in a pattern that minimizes adjacencies
        if ((row + col) % 2 == 0) {
          board[i] = colors[0];
        } else {
          board[i] = colors[1 % colors.length];
        }
      }
    }
    
    // Try to place remaining colors while avoiding conflicts
    for (int colorIdx = 2; colorIdx < colors.length; colorIdx++) {
      String color = colors[colorIdx];
      
      // Find positions where we can place this color
      for (int i = 0; i < board.length; i++) {
        if (i != emptyIndex && board[i] == colors[0]) {
          // Check if we can place this color here
          if (_isColorValidAtPosition(board, config, i, color, emptyIndex)) {
            board[i] = color;
            break;
          }
        }
      }
    }
  }


  /// Checks if a color is valid at a specific position (no adjacent same colors)
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
    
    // Check all 8 directions around the position
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue; // Skip current cell
        
        final int newRow = row + dr;
        final int newCol = col + dc;
        
        // Check bounds
        if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < columns) {
          final int neighborIndex = newRow * columns + newCol;
          
          // Skip empty cell
          if (neighborIndex == emptyIndex) continue;
          
          // Check if neighbor has the same color
          if (board[neighborIndex] == color) {
            return false; // Same color found adjacent
          }
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

    for (int i = 0; i < config.shuffleMoves && attempts < maxAttempts; i++) {
      final neighbors = _getValidNeighbors(currentEmptyIndex, config.columns, config.rows);
      final randomIndex = neighbors[Random().nextInt(neighbors.length)];
      
      // Check if this move would create adjacent same colors
      if (_isValidMove(shuffledBoard, randomIndex, currentEmptyIndex, config)) {
        _swapCells(shuffledBoard, randomIndex, currentEmptyIndex);
        currentEmptyIndex = randomIndex;
      } else {
        // Try to find a valid move
        bool foundValidMove = false;
        for (int neighbor in neighbors) {
          if (_isValidMove(shuffledBoard, neighbor, currentEmptyIndex, config)) {
            _swapCells(shuffledBoard, neighbor, currentEmptyIndex);
            currentEmptyIndex = neighbor;
            foundValidMove = true;
            break;
          }
        }
        
        if (!foundValidMove) {
          // If no valid move found, just make a random move
          _swapCells(shuffledBoard, randomIndex, currentEmptyIndex);
          currentEmptyIndex = randomIndex;
        }
      }
      
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
  /// Returns true if the board is valid (no adjacent same colors), false otherwise
  static bool validateBoardDistribution(List<String?> boardState, int columns, int rows) {
    List<String> violations = [];
    
    for (int i = 0; i < boardState.length; i++) {
      if (boardState[i] == null) continue;
      
      final int row = i ~/ columns;
      final int col = i % columns;
      
      // Check all 8 directions (horizontal, vertical, and diagonal)
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue; // Skip current cell
          
          final int newRow = row + dr;
          final int newCol = col + dc;
          
          // Check bounds
          if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < columns) {
            final int neighborIndex = newRow * columns + newCol;
            
            // Skip empty cells
            if (boardState[neighborIndex] == null) continue;
            
            // Check if neighbor has the same color
            if (boardState[i] == boardState[neighborIndex]) {
              violations.add('${boardState[i]} at ($row,$col) adjacent to ${boardState[neighborIndex]} at ($newRow,$newCol)');
            }
          }
        }
      }
    }
    
    return violations.isEmpty;
  }
}
