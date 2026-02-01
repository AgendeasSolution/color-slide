import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/game_constants.dart';
import '../models/level.dart';
import '../models/game_state.dart';
import '../utils/game_logic.dart';
import '../utils/responsive_helper.dart';
import '../widgets/common/game_dialog.dart';
import '../widgets/common/dialog_button.dart';
import '../widgets/common/ad_banner.dart';
import '../widgets/common/background_image.dart';
import '../widgets/game/game_header.dart';
import '../widgets/game/color_indicators.dart';
import '../widgets/game/game_board.dart';
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
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Game State
  late GameState _gameState;

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
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: GameConstants.pulseAnimation,
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _initializeGameState() {
    final selectedLevel = (widget.selectedLevel ?? 1).clamp(1, GameLevels.levels.length);
    final levelIndex = selectedLevel - 1;
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
    );
  }

  //============================================================================
  // Game Core Logic
  //============================================================================
  void _startNewGame() {
    final levelIndex = _gameState.currentLevel - 1;
    if (levelIndex < 0 || levelIndex >= GameLevels.levels.length) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final currentConfig = GameLevels.levels[levelIndex];
    final solvedBoard = GameLogic.createSolvedBoard(currentConfig);
    final shuffleResult = GameLogic.shuffleBoard(
      solvedBoard,
      solvedBoard.length - 1,
      currentConfig,
    );

    final boardState = GameLogic.validateBoardDistribution(
      shuffleResult['boardState'],
      currentConfig.columns,
      currentConfig.rows,
    )
        ? shuffleResult['boardState']
        : solvedBoard;
    final emptyIdx = boardState == solvedBoard ? solvedBoard.length - 1 : shuffleResult['emptyCellIndex'];

    if (!mounted) return;
    setState(() {
      _gameState = _gameState.copyWith(
        currentConfig: currentConfig,
        boardState: boardState,
        initialBoardState: List.from(boardState),
        emptyCellIndex: emptyIdx,
        initialEmptyCellIndex: emptyIdx,
        gameWon: false,
        gameOver: false,
        moves: 0,
      );
    });
  }

  void _resetToInitialPosition() async {
    if (!mounted) return;
    setState(() {
      _gameState = _gameState.copyWith(
        boardState: List.from(_gameState.initialBoardState),
        emptyCellIndex: _gameState.initialEmptyCellIndex,
        gameWon: false,
        gameOver: false,
        moves: 0,
      );
    });
    await InterstitialAdService.instance.showAdWithProbability(onAdDismissed: () {});
  }

  void _handleCellTap(int index) {
    if (_gameState.gameWon || _gameState.gameOver || _gameState.boardState[index] == null) return;

    if (GameLogic.isAdjacent(index, _gameState.emptyCellIndex, _gameState.currentConfig.columns, _gameState.currentConfig.rows)) {
      _moveBall(index, _gameState.emptyCellIndex);
    }
  }

  void _moveBall(int fromIndex, int toIndex) {
    if (!mounted) return;
    final moveResult = GameLogic.moveBall(_gameState.boardState, fromIndex, toIndex);
    setState(() {
      _gameState = _gameState.copyWith(
        boardState: moveResult['boardState'],
        emptyCellIndex: moveResult['emptyCellIndex'],
        moves: _gameState.moves + 1,
      );
    });
    if (mounted) Timer(GameConstants.winCheckDelay, _checkWinCondition);
  }

  void _checkWinCondition() {
    if (GameLogic.checkWinCondition(_gameState.boardState, _gameState.currentConfig)) {
      _handleWin();
    }
  }

  void _handleWin() async {
    if (!mounted) return;
    SoundService.instance.playWin();
    setState(() {
      _gameState = _gameState.copyWith(gameWon: true, gameOver: true);
    });
    await ProgressService.instance.completeLevel(_gameState.currentLevel);
    widget.onLevelCompleted?.call();
    if (mounted) _showGameOverDialog();
  }


  void _nextLevel() async {
    if (!mounted) return;
    if (_gameState.currentLevel < GameLevels.levels.length) {
      setState(() {
        _gameState = _gameState.copyWith(
          currentLevel: _gameState.currentLevel + 1,
          gameWon: false,
          gameOver: false,
          moves: 0,
        );
      });
      final adShown = await InterstitialAdService.instance.showAdAlways(
        onAdDismissed: _startNewGame,
      );
      if (!adShown) _startNewGame();
    } else {
      _showAllLevelsCompletedDialog();
    }
  }

  void _goToLevelSelector() {
    Navigator.of(context).pop();
  }

  void _exitGame() async {
    
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
              text: "Home",
              onPressed: () {
                Navigator.of(context).pop();
                _goToLevelSelector();
              },
            ),
            DialogButton(
              text: "Next Level",
              onPressed: () {
                Navigator.of(context).pop();
                _nextLevel();
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
        compactSpacing: true,
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
        compactSpacing: true,
      ),
    );
  }

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
          const BackgroundImage(),
          // Content with SafeArea
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Header at the top with reduced horizontal padding
                      Positioned(
                        top: 0,
                        left: horizontalPadding * 0.5, // 50% of normal padding
                        right: horizontalPadding * 0.5, // 50% of normal padding
                        child: GameHeader(
                          currentLevel: _gameState.currentLevel,
                          onReset: _resetToInitialPosition,
                          onExit: _exitGame,
                        ),
                      ),
                      // Game board centered independently in the middle of the screen
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: verticalPadding,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_gameState.boardState.isNotEmpty) ...[
                                SizedBox(height: ResponsiveHelper.getSpacing(context, 20)), // Top margin for game board
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
        ],
      ),
    );
  }
}
