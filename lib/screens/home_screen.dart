import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/game_constants.dart';
import '../utils/responsive_helper.dart';
import '../widgets/common/game_dialog.dart';
import '../widgets/common/dialog_button.dart';
import '../widgets/common/ad_banner.dart';
import '../widgets/dialogs/how_to_play_content.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../services/connectivity_service.dart';
import '../services/update_service.dart';
import '../models/level.dart';
import '../widgets/update_popup.dart';
import 'game_screen.dart';
import 'other_games_screen.dart';

/// Home screen widget - main entry point of the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;
  
  // Level selector state
  List<bool> _levelUnlocked = [];
  List<bool> _levelCompleted = [];
  bool _isLoadingProgress = true;
  
  // Sound state
  bool _isSoundEnabled = true;
  
  // Connectivity service
  final ConnectivityService _connectivityService = ConnectivityService();
  
  // Update state
  bool _showUpdatePopup = false;
  final UpdateService _updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSoundService();
    _loadProgress();
    _loadSoundState();
    _checkForUpdate();
  }
  
  void _loadSoundState() {
    if (mounted) {
      try {
        setState(() {
          _isSoundEnabled = SoundService.instance.isSoundEnabled;
        });
      } catch (e) {
        // Silently handle sound state error
      }
    }
  }
  
  void _toggleSound() {
    try {
      SoundService.instance.playButtonTap();
      SoundService.instance.toggleSound();
      if (mounted) {
        setState(() {
          _isSoundEnabled = SoundService.instance.isSoundEnabled;
        });
      }
    } catch (e) {
      // Silently handle sound toggle error
    }
  }

  Future<void> _initializeSoundService() async {
    try {
      await SoundService.instance.init();
    } catch (e) {
      // Game continues without sound
    }
  }

  Future<void> _checkForUpdate() async {
    try {
      final hasUpdate = await _updateService.checkForUpdate();
      if (mounted) {
        setState(() {
          _showUpdatePopup = hasUpdate;
        });
      }
    } catch (e) {
      // Silently fail - don't show popup if check fails
    }
  }

  void _dismissUpdatePopup() {
    if (mounted) {
      setState(() {
        _showUpdatePopup = false;
      });
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh progress when returning from game screen
    _loadProgress();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadProgress() async {
    try {
      final progressService = ProgressService.instance;
      await progressService.init();
      
      final unlocked = <bool>[];
      final completed = <bool>[];
      
      // Ensure we don't exceed level bounds
      final levelCount = GameLevels.levels.length;
      if (levelCount == 0) {
        if (mounted) {
          setState(() {
            _levelUnlocked = [];
            _levelCompleted = [];
            _isLoadingProgress = false;
          });
        }
        return;
      }
      
      for (int i = 0; i < levelCount; i++) {
        try {
          final level = i + 1;
          final isUnlocked = await progressService.isLevelUnlocked(level);
          final isCompleted = await progressService.isLevelCompleted(level);
          
          unlocked.add(isUnlocked);
          completed.add(isCompleted);
        } catch (e) {
          // Default to locked and not completed on error
          unlocked.add(i == 0); // First level always unlocked
          completed.add(false);
        }
      }
      
      if (mounted) {
        setState(() {
          _levelUnlocked = unlocked;
          _levelCompleted = completed;
          _isLoadingProgress = false;
        });
      }
    } catch (e) {
      // Initialize with default values
      if (mounted) {
        setState(() {
          final levelCount = GameLevels.levels.length;
          _levelUnlocked = List.generate(levelCount, (index) => index == 0);
          _levelCompleted = List.filled(levelCount, false);
          _isLoadingProgress = false;
        });
      }
    }
  }

  void _onLevelSelected(int level) async {
    // Safety check: validate level is within bounds
    if (level < 1 || level > GameLevels.levels.length) {
      return;
    }
    
    try {
      SoundService.instance.playButtonTap();
    } catch (e) {
      // Silently handle sound error
    }
    
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GameScreen(
            selectedLevel: level,
            onLevelCompleted: () {
              // Refresh progress immediately when a level is completed
              if (mounted) {
                _loadProgress();
              }
            },
          ),
        ),
      );
    }
  }

  void _showHowToPlay() {
    try {
      SoundService.instance.playButtonTap();
    } catch (e) {
      // Silently handle sound error
    }
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => GameDialog(
        title: "How to Play",
        subtitle: "",
        content: const HowToPlayContent(),
        actions: [
          DialogButton(
            text: "Got it!",
            onPressed: () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
        showCloseButton: false,
      ),
    );
  }

  void _navigateToMobileGames() {
    try {
      SoundService.instance.playButtonTap();
    } catch (e) {
      // Silently handle sound error
    }
    
    if (!mounted) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OtherGamesScreen(),
      ),
    );
  }

  Future<void> _navigateToWebGames() async {
    try {
      SoundService.instance.playButtonTap();
    } catch (e) {
      // Silently handle sound error
    }
    
    if (!mounted) return;
    
    // Check internet connectivity before attempting to open URL
    try {
      final hasInternet = await _connectivityService.hasInternetConnection();
      if (!hasInternet) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No internet connection. Please check your network and try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    } catch (e) {
      // Continue anyway - let URL launcher handle it
    }
    
    try {
      final Uri url = Uri.parse('https://freegametoplay.com');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication).catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to open website. Please try again.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open website. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open website. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }




  Widget _buildLevelGrid(BuildContext context) {
    if (_isLoadingProgress) {
      final loadingPadding = ResponsiveHelper.getSpacing(context, 20);
      final loadingSpacing = ResponsiveHelper.getSpacing(context, 20);
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(loadingPadding),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: ResponsiveHelper.getSpacing(context, 20),
                    spreadRadius: ResponsiveHelper.getSpacing(context, 5),
                  ),
                ],
              ),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: ResponsiveHelper.getSpacing(context, 4),
              ),
            ),
            SizedBox(height: loadingSpacing),
            Text(
              'Loading Levels...',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 18),
                color: AppColors.textAccent,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final crossAxisCount = ResponsiveHelper.getLevelGridCrossAxisCount(context);
    final gridSpacing = ResponsiveHelper.getSpacing(context, 12);

    return SingleChildScrollView(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: gridSpacing,
          mainAxisSpacing: gridSpacing,
          childAspectRatio: 1.0,
        ),
        itemCount: GameLevels.levels.length,
        itemBuilder: (context, index) {
          // Safety check: ensure index is valid
          if (index < 0 || index >= GameLevels.levels.length) {
            return const SizedBox.shrink();
          }
          
          final level = GameLevels.levels[index];
          
          // Safety check: ensure arrays are properly sized
          final isUnlocked = (index < _levelUnlocked.length) ? _levelUnlocked[index] : false;
          final isCompleted = (index < _levelCompleted.length) ? _levelCompleted[index] : false;
          
          return _buildLevelCard(context, level, isUnlocked, isCompleted);
        },
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, Level level, bool isUnlocked, bool isCompleted) {
    return GestureDetector(
              onTap: isUnlocked ? () {
                _onLevelSelected(level.level);
              } : null,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                gradient: isUnlocked
                    ? LinearGradient(
                        colors: isCompleted
                              ? [
                                  AppColors.neonGreen.withOpacity(0.15),
                                  AppColors.neonGreen.withOpacity(0.08),
                                  AppColors.neonGreen.withOpacity(0.12),
                                ]
                              : [
                                  AppColors.bgCard.withOpacity(0.1),
                                  AppColors.bgCardHover.withOpacity(0.05),
                                ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          AppColors.bgCard.withOpacity(0.3),
                          AppColors.bgCardHover.withOpacity(0.2),
                          AppColors.textMuted.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                border: Border.all(
                  color: isUnlocked
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.textMuted.withOpacity(0.4),
                  width: isUnlocked ? 1 : 1.5,
                ),
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.textMuted.withOpacity(0.15),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0.5,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Stack(
                children: [
                    // Animated background pattern
                    if (isUnlocked)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: LevelCardPatternPainter(
                                animation: _shimmerController.value,
                                color: _getDifficultyColor(level.level),
                              ),
                            );
                          },
                        ),
                      ),
                    
                    // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          if (isCompleted) ...[
                            // Completed level - clean styling
                            // Level number
                            Text(
                              '${level.level}',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(context, 24),
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    offset: const Offset(2, 2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.getSpacing(context, 4)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.getSpacing(context, 8),
                                vertical: ResponsiveHelper.getSpacing(context, 4),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.neonGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context, 12)),
                                border: Border.all(
                                  color: AppColors.neonGreen.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'COMPLETED',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getFontSize(context, 8),
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.neonGreen,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.6),
                                      offset: const Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else if (isUnlocked) ...[
                            // Unlocked level
                            Container(
                              padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 8)),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _getDifficultyColor(level.level).withOpacity(0.2),
                                    _getDifficultyColor(level.level).withOpacity(0.05),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getDifficultyColor(level.level).withOpacity(0.2),
                                    blurRadius: ResponsiveHelper.getSpacing(context, 8),
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Text(
                                '${level.level}',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getFontSize(context, 28),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.8),
                                      offset: const Offset(2, 2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.getSpacing(context, 4)),
                            Text(
                              '${level.gridSize}×${level.gridSize}',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(context, 12),
                                color: AppColors.textAccent,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.6),
                                    offset: const Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.getSpacing(context, 2)),
                            Text(
                              _getDifficultyText(level.level),
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(context, 8),
                                color: _getDifficultyColor(level.level),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    offset: const Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // Locked level
                            Container(
                              padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 12)),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.secondary.withOpacity(0.25),
                                    AppColors.bgCard.withOpacity(0.3),
                                  ],
                                ),
                                border: Border.all(
                                  color: AppColors.secondary.withOpacity(0.6),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.lock,
                                color: AppColors.secondary,
                                size: ResponsiveHelper.getIconSize(context, 24),
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.getSpacing(context, 4)),
                            Text(
                              'LOCKED',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(context, 8),
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    offset: const Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  
                    // Difficulty indicator - no animation
                    if (isUnlocked && !isCompleted)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(level.level),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    
                    // Lock overlay - clear and readable
                  if (!isUnlocked)
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                  ],
                ),
              ),
            );
  }

  Color _getDifficultyColor(int level) {
    if (level <= 2) return AppColors.easy;
    if (level <= 4) return AppColors.medium;
    if (level <= 6) return AppColors.hard;
    return AppColors.expert;
  }

  String _getDifficultyText(int level) {
    if (level <= 2) return 'EASY';
    if (level <= 4) return 'MEDIUM';
    if (level <= 6) return 'HARD';
    return 'EXPERT';
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    final verticalPadding = ResponsiveHelper.getVerticalPadding(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient - fills entire screen including safe areas
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.bgDark, AppColors.bgDarker],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Subtle gradient overlays for depth - less blur
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
              ],
            ),
          ),
          // Content with SafeArea
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                          // Header Section with animated title
                          AnimatedBuilder(
                            animation: _floatAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _floatAnimation.value * 0.3),
                                child: Column(
                            children: [
                                    // App Title with stunning gradient and glow
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: ResponsiveHelper.getSpacing(context, 20),
                                        vertical: ResponsiveHelper.getSpacing(context, 10),
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          ResponsiveHelper.getBorderRadius(context, 30),
                                        ),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0x20FF6B35),
                                            Color(0x104ECDC4),
                                            Color(0x20FFE66D),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.3),
                                            blurRadius: ResponsiveHelper.getSpacing(context, 30),
                                            spreadRadius: ResponsiveHelper.getSpacing(context, 5),
                                          ),
                                        ],
                                      ),
                                      child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                          colors: [
                                            AppColors.gradientStart,
                                            AppColors.gradientEnd,
                                            AppColors.secondary,
                                          ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                                    child: Text(
                                      'COLOR SLIDE',
                              style: TextStyle(
                                        fontSize: ResponsiveHelper.getFontSize(context, 32),
                                        fontWeight: FontWeight.w900,
                                color: Colors.white,
                                        letterSpacing: 2.5,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.5),
                                            offset: Offset(
                                              ResponsiveHelper.getSpacing(context, 2),
                                              ResponsiveHelper.getSpacing(context, 2),
                                            ),
                                            blurRadius: ResponsiveHelper.getSpacing(context, 8),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                                
                                    SizedBox(height: ResponsiveHelper.getSpacing(context, 8)),
                                    
                                    // Subtitle
                                    Text(
                                      'Master the Art of Color',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.getFontSize(context, 14),
                                        color: AppColors.textAccent,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.8),
                                            offset: Offset(
                                              ResponsiveHelper.getSpacing(context, 1),
                                              ResponsiveHelper.getSpacing(context, 1),
                                            ),
                                            blurRadius: ResponsiveHelper.getSpacing(context, 2),
                                          ),
                                        ],
                                ),
                              ),
                              
                              SizedBox(height: ResponsiveHelper.getSpacing(context, 12)),
                            ],
                                ),
                              );
                            },
                          ),
                          
                          SizedBox(height: ResponsiveHelper.getSpacing(context, 24)),
                          
                          // Level Selector Grid
                          Expanded(
                            child: _buildLevelGrid(context),
                          ),
                          
                          SizedBox(height: ResponsiveHelper.getSpacing(context, 12)),
                          
                          // Sound and How to Play buttons in same row (icon-only, square)
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // How to Play button (icon-only, matching sound button style)
                                Container(
                                  width: ResponsiveHelper.getButtonHeight(context),
                                  height: ResponsiveHelper.getButtonHeight(context),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveHelper.getBorderRadius(context, 8),
                                    ),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.bgCard.withOpacity(0.2),
                                        AppColors.bgCardHover.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3),
                                      width: ResponsiveHelper.getSpacing(context, 1.5),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.15),
                                        blurRadius: ResponsiveHelper.getSpacing(context, 12),
                                        spreadRadius: ResponsiveHelper.getSpacing(context, 1),
                                        offset: Offset(0, ResponsiveHelper.getSpacing(context, 4)),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _showHowToPlay,
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveHelper.getBorderRadius(context, 8),
                                      ),
                                      child: Icon(
                                        Icons.help_outline,
                                        color: AppColors.primary,
                                        size: ResponsiveHelper.getIconSize(context, 24),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                SizedBox(width: ResponsiveHelper.getSpacing(context, 12)),
                                
                                // Sound toggle button (icon-only, rounded)
                                Container(
                                  width: ResponsiveHelper.getButtonHeight(context),
                                  height: ResponsiveHelper.getButtonHeight(context),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveHelper.getBorderRadius(context, 8),
                                    ),
                                    gradient: LinearGradient(
                                      colors: _isSoundEnabled
                                          ? [
                                              AppColors.bgCard.withOpacity(0.2),
                                              AppColors.bgCardHover.withOpacity(0.1),
                                            ]
                                          : [
                                              AppColors.bgCard.withOpacity(0.15),
                                              AppColors.bgCardHover.withOpacity(0.08),
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: _isSoundEnabled
                                          ? AppColors.primary.withOpacity(0.3)
                                          : AppColors.textMuted.withOpacity(0.3),
                                      width: ResponsiveHelper.getSpacing(context, 1.5),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _isSoundEnabled
                                            ? AppColors.primary.withOpacity(0.15)
                                            : Colors.black.withOpacity(0.2),
                                        blurRadius: ResponsiveHelper.getSpacing(context, 12),
                                        spreadRadius: ResponsiveHelper.getSpacing(context, 1),
                                        offset: Offset(0, ResponsiveHelper.getSpacing(context, 4)),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _toggleSound,
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveHelper.getBorderRadius(context, 8),
                                      ),
                                      child: Icon(
                                        _isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                                        color: _isSoundEnabled
                                            ? AppColors.primary
                                            : AppColors.textMuted,
                                        size: ResponsiveHelper.getIconSize(context, 24),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: ResponsiveHelper.getSpacing(context, 24)),
                          
                          // Explore More Games Heading (centered)
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: ResponsiveHelper.getIconSize(context, 16),
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: ResponsiveHelper.getSpacing(context, 8)),
                                Text(
                                  'Explore More Games',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(context, 14),
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.8),
                                        offset: Offset(
                                          ResponsiveHelper.getSpacing(context, 1),
                                          ResponsiveHelper.getSpacing(context, 1),
                                        ),
                                        blurRadius: ResponsiveHelper.getSpacing(context, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: ResponsiveHelper.getSpacing(context, 10)),
                          
                          // Mobile Games and Web Games buttons in same row (not full width)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.getSpacing(context, 16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Mobile Games button (purple)
                                  Flexible(
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: ResponsiveHelper.screenWidth(context) * 0.42,
                                      ),
                                      height: ResponsiveHelper.getButtonHeight(context),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          ResponsiveHelper.getBorderRadius(context, 24),
                                        ),
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.neonPurple.withOpacity(0.8),
                                          AppColors.neonPurple.withOpacity(0.6),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(
                                        color: AppColors.neonPurple.withOpacity(0.5),
                                        width: ResponsiveHelper.getSpacing(context, 1.5),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.neonPurple.withOpacity(0.3),
                                          blurRadius: ResponsiveHelper.getSpacing(context, 12),
                                          spreadRadius: ResponsiveHelper.getSpacing(context, 1),
                                          offset: Offset(0, ResponsiveHelper.getSpacing(context, 4)),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _navigateToMobileGames,
                                        borderRadius: BorderRadius.circular(
                                          ResponsiveHelper.getBorderRadius(context, 24),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: ResponsiveHelper.getSpacing(context, 16),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.smartphone,
                                                color: Colors.white,
                                                size: ResponsiveHelper.getIconSize(context, 20),
                                              ),
                                              SizedBox(width: ResponsiveHelper.getSpacing(context, 8)),
                                              Flexible(
                                                child: Text(
                                                  'Mobile Games',
                                                  style: TextStyle(
                                                    fontSize: ResponsiveHelper.getFontSize(context, 12),
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                    letterSpacing: 1.0,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black.withOpacity(0.6),
                                                        offset: const Offset(1, 1),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ),
                                  
                                  SizedBox(width: ResponsiveHelper.getSpacing(context, 12)),
                                  
                                  // Web Games button (blue)
                                  Flexible(
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: ResponsiveHelper.screenWidth(context) * 0.42,
                                      ),
                                      height: ResponsiveHelper.getButtonHeight(context),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          ResponsiveHelper.getBorderRadius(context, 24),
                                        ),
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.secondary.withOpacity(0.8),
                                          AppColors.secondary.withOpacity(0.6),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(
                                        color: AppColors.secondary.withOpacity(0.5),
                                        width: ResponsiveHelper.getSpacing(context, 1.5),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.secondary.withOpacity(0.3),
                                          blurRadius: ResponsiveHelper.getSpacing(context, 12),
                                          spreadRadius: ResponsiveHelper.getSpacing(context, 1),
                                          offset: Offset(0, ResponsiveHelper.getSpacing(context, 4)),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _navigateToWebGames,
                                        borderRadius: BorderRadius.circular(
                                          ResponsiveHelper.getBorderRadius(context, 24),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: ResponsiveHelper.getSpacing(context, 16),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.laptop,
                                                color: Colors.white,
                                                size: ResponsiveHelper.getIconSize(context, 20),
                                              ),
                                              SizedBox(width: ResponsiveHelper.getSpacing(context, 8)),
                                              Flexible(
                                                child: Text(
                                                  'Web Games',
                                                  style: TextStyle(
                                                    fontSize: ResponsiveHelper.getFontSize(context, 12),
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                    letterSpacing: 1.0,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black.withOpacity(0.6),
                                                        offset: const Offset(1, 1),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Ad Banner at the bottom with proper spacing
                Container(
                  margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context, 8)),
                  child: const AdBanner(),
                ),
              ],
            ),
          ),
          // Update Pop-up at the bottom
          if (_showUpdatePopup)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: UpdatePopup(
                onDismiss: _dismissUpdatePopup,
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom painter for level card pattern animation
class LevelCardPatternPainter extends CustomPainter {
  final double animation;
  final Color color;

  LevelCardPatternPainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw animated geometric patterns
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 3;
    
    // Rotating hexagon pattern
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + (animation * 2 * math.pi);
      final x = center.dx + math.cos(angle) * radius * 0.7;
      final y = center.dy + math.sin(angle) * radius * 0.7;
      
      canvas.drawCircle(
        Offset(x, y),
        3 + math.sin(animation * 2 * math.pi + i) * 2,
        paint,
      );
    }
    
    // Pulsing center circle
    final centerRadius = 8 + math.sin(animation * 4 * math.pi) * 4;
    canvas.drawCircle(center, centerRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
