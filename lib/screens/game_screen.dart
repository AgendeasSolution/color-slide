import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_colors.dart';
import '../constants/game_constants.dart';
import '../models/level.dart';
import '../models/game_state.dart';
import '../utils/game_logic.dart';
import '../utils/responsive_helper.dart';
import '../widgets/common/game_dialog.dart';
import '../widgets/common/dialog_button.dart';
import '../widgets/common/ad_banner.dart';
import '../widgets/game/game_header.dart';
import '../widgets/game/color_indicators.dart';
import '../widgets/game/game_board.dart';
import '../widgets/dialogs/how_to_play_content.dart';
import '../widgets/dialogs/game_over_content.dart';
import '../services/progress_service.dart';
import '../services/interstitial_ad_service.dart';
import '../services/sound_service.dart';

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
  
  // Timer (disabled - clock removed)
  Timer? _gameTimer;
  int _timerTick = 0; // Force UI updates

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeGameState();
    
    // Preload interstitial ad for better user experience
    InterstitialAdService.instance.preloadAd();
    
    // Show interstitial ad with 50% probability when entering game screen
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final adShown = await InterstitialAdService.instance.showAdWithProbability(
        onAdDismissed: () {
          _startNewGame();
        }
      );
      
      // If ad was NOT shown, start game immediately
      if (!adShown) {
        _startNewGame();
      }
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
    try {
      final selectedLevel = widget.selectedLevel ?? 1;
      // Validate level is within bounds
      if (selectedLevel < 1 || selectedLevel > GameLevels.levels.length) {
        final levelIndex = 0;
        final currentConfig = GameLevels.levels[levelIndex];
        _gameState = GameState(
          currentLevel: 1,
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
        return;
      }
      
      final levelIndex = selectedLevel - 1;
      if (levelIndex < 0 || levelIndex >= GameLevels.levels.length) {
        return;
      }
      
      final currentConfig = GameLevels.levels[levelIndex];
      _gameState = GameState(
        currentLevel: selectedLevel,
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
    } catch (e) {
      // Default to level 1 on error
      if (GameLevels.levels.isNotEmpty) {
        try {
          final currentConfig = GameLevels.levels[0];
          _gameState = GameState(
            currentLevel: 1,
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
        } catch (e2) {
          // Game state will remain uninitialized - caller should handle
        }
      }
    }
  }

  //============================================================================
  // Timer Management
  //============================================================================
  void _startGameTimer() {
    // Timer disabled - clock removed from game
    // Timer logic kept for potential future use but time-up checking is disabled
    _gameTimer?.cancel();
    _timerTick = 0; // Reset tick counter
    // Timer periodic callback removed - no time-up checking
  }

  void _stopGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  // _handleTimeUp method removed - clock removed from game

  //============================================================================
  // Game Core Logic
  //============================================================================
  void _startNewGame() {
    try {
      // Validate level bounds before accessing
      final currentLevel = _gameState.currentLevel;
      if (currentLevel < 1 || currentLevel > GameLevels.levels.length) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }
      
      final levelIndex = currentLevel - 1;
      if (levelIndex < 0 || levelIndex >= GameLevels.levels.length) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }
      
        setState(() {
          final currentConfig = GameLevels.levels[levelIndex];
          final solvedBoard = GameLogic.createSolvedBoard(currentConfig);
        
          final shuffleResult = GameLogic.shuffleBoard(
            solvedBoard,
            solvedBoard.length - 1,
            currentConfig,
          );
          
          // Validate the shuffled board
          final bool isShuffledValid = GameLogic.validateBoardDistribution(
            shuffleResult['boardState'], 
            currentConfig.columns,
            currentConfig.rows,
          );
          
          if (!isShuffledValid) {
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
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
  }

  void _resetToInitialPosition() async {
    if (!mounted) return;
    
    // Stop the current timer completely before showing ad
    _stopGameTimer();
    
    // Reset the game state
    if (mounted) {
      try {
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
      } catch (e) {
        // Silently handle reset error
      }
    }
    
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
    if (!mounted) return;
    
    // Preload next ad for better user experience
    try {
      InterstitialAdService.instance.preloadAd();
    } catch (e) {
      // Silently handle ad preload error
    }
    
    // Start the timer fresh after ad is finished
    final freshStartTime = DateTime.now();
    if (mounted) {
      try {
        setState(() {
          _gameState = _gameState.copyWith(
            startTime: freshStartTime,
            timerPaused: false,
          );
          _timerTick = 0;
        });
      } catch (e) {
        // Silently handle timer start error
      }
    }
    
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

    if (GameLogic.isAdjacent(index, _gameState.emptyCellIndex, _gameState.currentConfig.columns, _gameState.currentConfig.rows)) {
      _moveBall(index, _gameState.emptyCellIndex);
    }
  }

  void _moveBall(int fromIndex, int toIndex) {
    if (!mounted) return;
    
    try {
      final moveResult = GameLogic.moveBall(_gameState.boardState, fromIndex, toIndex);
      
      if (mounted) {
        setState(() {
          _gameState = _gameState.copyWith(
            boardState: moveResult['boardState'],
            emptyCellIndex: moveResult['emptyCellIndex'],
            moves: _gameState.moves + 1,
          );
        });
      }

      // Use a short delay to allow the UI to update before checking for win
      if (mounted) {
        Timer(GameConstants.winCheckDelay, _checkWinCondition);
      }
    } catch (e) {
      // Silently handle move error
    }
  }

  void _checkWinCondition() {
    if (GameLogic.checkWinCondition(_gameState.boardState, _gameState.currentConfig)) {
      _handleWin();
    }
  }

  void _handleWin() async {
    if (!mounted) return;
    
    // Stop the timer
    _stopGameTimer();
    
    // Play win sound
    try {
      SoundService.instance.playWin();
    } catch (e) {
      // Silently handle sound error
    }
    
    if (mounted) {
      try {
        setState(() {
          _gameState = _gameState.copyWith(
            gameWon: true,
            gameOver: true,
            endTime: DateTime.now(),
          );
        });
      } catch (e) {
        // Silently handle state update error
      }
    }
    
    // Save level completion progress
    try {
      final progressService = ProgressService.instance;
      await progressService.completeLevel(_gameState.currentLevel);
    } catch (e) {
      // Silently handle progress save error
    }
    
    // Notify home screen that a level was completed
    try {
      if (widget.onLevelCompleted != null) {
        widget.onLevelCompleted!();
      }
    } catch (e) {
      // Silently handle callback error
    }
    
    // Show game over dialog
    if (mounted) {
      try {
        _showGameOverDialog();
      } catch (e) {
        // Silently handle dialog error
      }
    }
  }


  void _nextLevel() async {
    if (!mounted) return;
    
    // Ensure timer is stopped before starting new level
    _stopGameTimer();
    
    if (_gameState.currentLevel < GameLevels.levels.length) {
      if (mounted) {
        try {
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
        } catch (e) {
          // Silently handle state update error
        }
      }
      
      // Show interstitial ad with 100% probability for next level
      final adShown = await InterstitialAdService.instance.showAdAlways(
        onAdDismissed: () {
          _startNewGame();
        }
      );
      
      // If ad was not shown (loading error), start game immediately
      if (!adShown) {
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

  void _exitGame() async {
    _stopGameTimer(); // Stop timer before showing ad
    
    // Store navigator context before async operation
    final navigator = Navigator.of(context);
    
    final adShown = await InterstitialAdService.instance.showAdAlways(
      onAdDismissed: () {
        // Navigate immediately after ad is dismissed using Future.microtask for faster execution
        Future.microtask(() => navigator.pop());
      }
    );
    
    // If no ad was shown (loading error), navigate immediately
    if (!adShown) {
      Future.microtask(() => navigator.pop());
    }
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

  // _showTimeUpDialog method removed - clock removed from game



  //============================================================================
  // Build Method & Responsive Layout
  //============================================================================
  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    final maxBoardWidth = ResponsiveHelper.getMaxBoardWidth(context);
    final verticalPadding = ResponsiveHelper.getVerticalPadding(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background image - fills entire screen including safe areas
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content with SafeArea
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      bottom: verticalPadding,
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
                        // Timer widget removed - clock removed from game
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
                                SizedBox(height: ResponsiveHelper.getSpacing(context, 12)),
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
                // Ad Banner at the bottom with proper spacing
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: const AdBanner(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
