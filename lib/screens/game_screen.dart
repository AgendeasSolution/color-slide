import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_colors.dart';
import '../constants/game_constants.dart';
import '../models/level.dart';
import '../models/game_state.dart';
import '../utils/game_logic.dart';
import '../widgets/common/game_dialog.dart';
import '../widgets/common/dialog_button.dart';
import '../widgets/common/ad_banner.dart';
import '../widgets/game/game_header.dart';
import '../widgets/game/color_indicators.dart';
import '../widgets/game/game_board.dart';
import '../widgets/game/timer_widget.dart';
import '../widgets/dialogs/how_to_play_content.dart';
import '../widgets/dialogs/stats_content.dart';
import '../widgets/dialogs/game_over_content.dart';
import '../services/progress_service.dart';
import '../services/interstitial_ad_service.dart';

/// Main game screen widget
class GameScreen extends StatefulWidget {
  final int? selectedLevel;
  final VoidCallback? onLevelCompleted;
  
  const GameScreen({super.key, this.selectedLevel, this.onLevelCompleted});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Game State
  late GameState _gameState;
  
  // Timer
  Timer? _gameTimer;
  int _timerTick = 0; // Force UI updates

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeGameState();
    
    // Preload interstitial ad for better user experience
    InterstitialAdService.instance.preloadAd();
    
    // Start the game immediately when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNewGame();
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _shimmerController = AnimationController(
      vsync: this,
      duration: GameConstants.shimmerAnimation,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: GameConstants.pulseAnimation,
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _initializeGameState() {
    final levelIndex = (widget.selectedLevel ?? 1) - 1;
    final currentConfig = GameLevels.levels[levelIndex];
    _gameState = GameState(
      currentLevel: widget.selectedLevel ?? 1,
      currentConfig: currentConfig,
      boardState: [],
      initialBoardState: [],
      emptyCellIndex: -1,
      initialEmptyCellIndex: -1,
      gameWon: false,
      gameOver: false,
      moves: 0,
      timeUp: false,
    );
  }

  //============================================================================
  // Timer Management
  //============================================================================
  void _startGameTimer() {
    _gameTimer?.cancel();
    _timerTick = 0; // Reset tick counter
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _gameState.startTime != null) {
        setState(() {
          // Increment tick to force UI update
          _timerTick++;
          
          // Check if time is up using real-time calculation
          final now = DateTime.now();
          final elapsed = now.difference(_gameState.startTime!).inSeconds;
          final remaining = _gameState.currentConfig.timeLimitMinutes * 60 - elapsed;
          if (remaining <= 0 && !_gameState.gameWon && !_gameState.gameOver) {
            _handleTimeUp();
          }
        });
      }
    });
  }

  void _stopGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void _handleTimeUp() {
    setState(() {
      _gameState = _gameState.copyWith(
        gameOver: true,
        timeUp: true,
        endTime: DateTime.now(),
      );
    });
    
    _stopGameTimer();
    _showTimeUpDialog();
  }

  //============================================================================
  // Game Core Logic
  //============================================================================
  void _startNewGame() {
    print('🎮 _startNewGame called for Level ${_gameState.currentLevel}');
    setState(() {
      final currentConfig = GameLevels.levels[_gameState.currentLevel - 1];
      final solvedBoard = GameLogic.createSolvedBoard(currentConfig);
      
      // Validate that the solved board has no adjacent same colors
      final bool isValidDistribution = GameLogic.validateBoardDistribution(
        solvedBoard, 
        currentConfig.gridSize
      );
      
      if (!isValidDistribution) {
        print('❌ CRITICAL: Solved board has adjacent same colors!');
        GameLogic.printBoardDebug(solvedBoard, currentConfig.gridSize);
      } else {
        print('✅ Solved board distribution is valid - no adjacent same colors');
        GameLogic.printBoardDebug(solvedBoard, currentConfig.gridSize);
      }
      
      final shuffleResult = GameLogic.shuffleBoard(
        solvedBoard,
        solvedBoard.length - 1,
        currentConfig,
      );
      
      // Validate the shuffled board
      final bool isShuffledValid = GameLogic.validateBoardDistribution(
        shuffleResult['boardState'], 
        currentConfig.gridSize
      );
      
      if (!isShuffledValid) {
        print('⚠️ Shuffled board has adjacent same colors, using original solved board');
        // Use the original solved board if shuffle created adjacencies
        _gameState = _gameState.copyWith(
          currentConfig: currentConfig,
          boardState: solvedBoard,
          initialBoardState: List.from(solvedBoard),
          emptyCellIndex: solvedBoard.length - 1,
          initialEmptyCellIndex: solvedBoard.length - 1,
          gameWon: false,
          gameOver: false,
          moves: 0,
          startTime: DateTime.now(),
          endTime: null,
          timeUp: false,
        );
      } else {
        print('✅ Shuffled board is valid - no adjacent same colors');
        _gameState = _gameState.copyWith(
          currentConfig: currentConfig,
          boardState: shuffleResult['boardState'],
          initialBoardState: List.from(shuffleResult['boardState']),
          emptyCellIndex: shuffleResult['emptyCellIndex'],
          initialEmptyCellIndex: shuffleResult['emptyCellIndex'],
          gameWon: false,
          gameOver: false,
          moves: 0,
          startTime: DateTime.now(),
          endTime: null,
          timeUp: false,
        );
      }
    });
    
    // Start the game timer AFTER setState
    _startGameTimer();
  }

  void _resetToInitialPosition() async {
    // Stop the current timer completely before showing ad
    _stopGameTimer();
    
    // Reset the game state
    setState(() {
      _gameState = _gameState.copyWith(
        boardState: List.from(_gameState.initialBoardState),
        emptyCellIndex: _gameState.initialEmptyCellIndex,
        gameWon: false,
        gameOver: false,
        moves: 0,
        startTime: null, // No start time - timer not running
        endTime: null,
        timeUp: false,
        timerPaused: false,
      );
      _timerTick = 0;
    });
    
    // Show interstitial ad with 50% probability and callback
    final adShown = await InterstitialAdService.instance.showAdWithProbability(
      onAdDismissed: () {
        _startTimerAfterAd();
      }
    );
    
    // If ad was NOT shown (skipped due to probability), start timer immediately
    if (!adShown) {
      _startTimerAfterAd();
    }
  }

  void _startTimerAfterAd() {
    // Preload next ad for better user experience
    InterstitialAdService.instance.preloadAd();
    
    // Start the timer fresh after ad is finished
    final freshStartTime = DateTime.now();
    setState(() {
      _gameState = _gameState.copyWith(
        startTime: freshStartTime,
        timerPaused: false,
      );
      _timerTick = 0;
    });
    
    // Start the timer
    _startGameTimer();
    
    // Force immediate UI update
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _timerTick = 1;
        });
      }
    });
  }

  void _handleCellTap(int index) {
    if (_gameState.gameWon || _gameState.gameOver || _gameState.boardState[index] == null) return;

    if (GameLogic.isAdjacent(index, _gameState.emptyCellIndex, _gameState.currentConfig.gridSize)) {
      _moveBall(index, _gameState.emptyCellIndex);
    }
  }

  void _moveBall(int fromIndex, int toIndex) {
    final moveResult = GameLogic.moveBall(_gameState.boardState, fromIndex, toIndex);
    
    setState(() {
      _gameState = _gameState.copyWith(
        boardState: moveResult['boardState'],
        emptyCellIndex: moveResult['emptyCellIndex'],
        moves: _gameState.moves + 1,
      );
    });

    // Use a short delay to allow the UI to update before checking for win
    Timer(GameConstants.winCheckDelay, _checkWinCondition);
  }

  void _checkWinCondition() {
    if (GameLogic.checkWinCondition(_gameState.boardState, _gameState.currentConfig)) {
      _handleWin();
    }
  }

  void _handleWin() async {
    // Stop the timer
    _stopGameTimer();
    
    setState(() {
      _gameState = _gameState.copyWith(
        gameWon: true,
        gameOver: true,
        endTime: DateTime.now(),
      );
    });
    
    // Save level completion progress
    final progressService = ProgressService.instance;
    await progressService.completeLevel(_gameState.currentLevel);
    
    // Notify home screen that a level was completed
    if (widget.onLevelCompleted != null) {
      widget.onLevelCompleted!();
    }
    
    // Show game over dialog
    _showGameOverDialog();
  }


  void _nextLevel() async {
    print('🔄 Next Level called - Current Level: ${_gameState.currentLevel}');
    
    // Ensure timer is stopped before starting new level
    _stopGameTimer();
    
    if (_gameState.currentLevel < GameLevels.levels.length) {
      setState(() {
        _gameState = _gameState.copyWith(
          currentLevel: _gameState.currentLevel + 1,
          gameWon: false,
          gameOver: false,
          moves: 0,
          startTime: null, // Don't set startTime here, let _startNewGame handle it
          endTime: null,
          timeUp: false,
        );
      });
      print('🔄 Starting new game for Level ${_gameState.currentLevel}');
      
      // Show interstitial ad with 100% probability for next level
      final adShown = await InterstitialAdService.instance.showAdAlways(
        onAdDismissed: () {
          print('🔄 NEXT LEVEL AD DISMISSED - Starting new game');
          _startNewGame();
        }
      );
      
      // If ad was not shown (loading error), start game immediately
      if (!adShown) {
        print('🔄 Next level ad not shown, starting game immediately');
        _startNewGame();
      }
    } else {
      // All levels completed, show completion dialog
      _showAllLevelsCompletedDialog();
    }
  }

  void _goToLevelSelector() {
    Navigator.of(context).pop();
  }

  void _exitGame() {
    Navigator.of(context).pop();
  }

  //============================================================================
  // Modals / Dialogs
  //============================================================================
  Future<void> _showStartModal() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameDialog(
        title: "Color Slide",
        subtitle: "Welcome to the ultimate color puzzle challenge!",
        content: const HowToPlayContent(),
        actions: [
          DialogButton(
            text: "Start Game",
            onPressed: () {
              Navigator.of(context).pop();
              _startNewGame();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showGameOverDialog() {
    final bool isLastLevel = _gameState.currentLevel >= GameLevels.levels.length;
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameDialog(
        title: isLastLevel ? "All Levels Complete!" : "Level ${_gameState.currentLevel} Complete!",
        subtitle: isLastLevel ? "Congratulations on completing all levels!" : "",
        content: GameOverContent(
          gameState: _gameState,
          isAllLevelsCompleted: isLastLevel,
        ),
        actions: [
          if (!isLastLevel) ...[
            DialogButton(
              text: "Next Level",
              onPressed: () {
                Navigator.of(context).pop();
                _nextLevel();
              },
            ),
            DialogButton(
              text: "Home",
              onPressed: () {
                Navigator.of(context).pop();
                _goToLevelSelector();
              },
            ),
          ] else ...[
            DialogButton(
              text: "Home",
              onPressed: () {
                Navigator.of(context).pop();
                _goToLevelSelector();
              },
            ),
          ],
        ],
        showCloseButton: false,
      ),
    );
  }

  Future<void> _showAllLevelsCompletedDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameDialog(
        title: "Congratulations!",
        subtitle: "",
        content: GameOverContent(
          gameState: _gameState,
          isAllLevelsCompleted: true,
        ),
        actions: [
          DialogButton(
            text: "Home",
            onPressed: () {
              Navigator.of(context).pop();
              _goToLevelSelector();
            },
          ),
        ],
        showCloseButton: false,
      ),
    );
  }

  Future<void> _showTimeUpDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameDialog(
        title: "Time's Up!",
        subtitle: "Don't worry, you can try again!",
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_off,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              "Level ${_gameState.currentLevel}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Time Limit: ${_gameState.currentConfig.timeLimitMinutes} minutes",
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Moves Made: ${_gameState.moves}",
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          DialogButton(
            text: "Try Again",
            onPressed: () {
              Navigator.of(context).pop();
              _resetToInitialPosition();
            },
          ),
          DialogButton(
            text: "Home",
            onPressed: () {
              Navigator.of(context).pop();
              _goToLevelSelector();
            },
          ),
        ],
        showCloseButton: false,
      ),
    );
  }



  //============================================================================
  // Build Method & Responsive Layout
  //============================================================================
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive layout adjustments
    final double horizontalPadding = screenWidth > GameConstants.tabletBreakpoint 
        ? GameConstants.horizontalPaddingTablet 
        : GameConstants.horizontalPaddingMobile;
    final double maxBoardWidth = screenWidth > GameConstants.tabletBreakpoint 
        ? GameConstants.maxBoardWidthTablet 
        : GameConstants.maxBoardWidthMobile;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgDarker],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Subtle gradient overlays for depth - matching home screen
                  Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.8, -0.8),
                        radius: 1.0,
                        colors: [
                          Color(0x15FF6B35),
                          Color(0x08FF6B35),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.8, 0.8),
                        radius: 1.0,
                        colors: [
                          Color(0x154ECDC4),
                          Color(0x084ECDC4),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: GameConstants.verticalPadding,
                      ),
                      child: Stack(
                        children: [
                          // Header at the top
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: GameHeader(
                              currentLevel: _gameState.currentLevel,
                              onReset: _resetToInitialPosition,
                              onExit: _exitGame,
                            ),
                          ),
                          // Timer below header
                          if (_gameState.boardState.isNotEmpty && !_gameState.gameWon && !_gameState.gameOver)
                            Positioned(
                              top: 80, // Adjust based on header height
                              left: 0,
                              right: 0,
                              child: Builder(
                                builder: (context) {
                                  // Only show timer widget if timer is actually running
                                  if (_gameState.startTime == null) {
                                    return const SizedBox.shrink(); // Hide timer when not started
                                  }
                                  return TimerWidget(gameState: _gameState, tick: _timerTick);
                                },
                              ),
                            ),
                          // Game board centered in the middle of the screen
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_gameState.boardState.isNotEmpty) ...[
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: maxBoardWidth),
                                    child: ColorIndicators(config: _gameState.currentConfig),
                                  ),
                                  const SizedBox(height: 12),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: maxBoardWidth),
                                    child: GameBoard(
                                      config: _gameState.currentConfig,
                                      boardState: _gameState.boardState,
                                      emptyCellIndex: _gameState.emptyCellIndex,
                                      onCellTap: _handleCellTap,
                                      pulseAnimation: _pulseAnimation,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Ad Banner at the bottom with proper spacing
            Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: const AdBanner(),
            ),
          ],
        ),
      ),
    );
  }
}
