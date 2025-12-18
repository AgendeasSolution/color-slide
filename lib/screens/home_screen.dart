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
    final gridSpacing = ResponsiveHelper.getSpacing(context, 8);

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
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
                  borderRadius: BorderRadius.circular(16),
                gradient: isUnlocked
                    ? LinearGradient(
                        colors: isCompleted
                              ? [
                                  Color(0xFF8A2BE2), // Deep purple - matching glowing purple cell
                                  Color(0xFF6A1B9A), // Darker purple
                                  Color(0xFF9C27B0), // Vibrant purple
                                ]
                              : [
                                  Color(0xFF1A1A2E), // Dark cosmic blue
                                  Color(0xFF2A2A3E), // Slightly lighter
                                ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          AppColors.bgCard,
                          AppColors.bgCardHover,
                          AppColors.textMuted,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                border: Border.all(
                  color: isUnlocked
                        ? (isCompleted 
                            ? Color(0xFFBA68C8) // Light purple for completed
                            : _getDifficultyColor(level.level)) // Orb colors for unlocked
                        : AppColors.textMuted,
                  width: isUnlocked ? 1 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
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
                                fontSize: ResponsiveHelper.getFontSize(context, 18),
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
                            SizedBox(height: ResponsiveHelper.getSpacing(context, 2)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.getSpacing(context, 6),
                                vertical: ResponsiveHelper.getSpacing(context, 2),
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF8A2BE2), // Deep purple - matching glowing purple cell
                                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context, 8)),
                                border: Border.all(
                                  color: Color(0xFFBA68C8), // Lighter purple for border
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'COMPLETED',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getFontSize(context, 7),
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFE1BEE7), // Light purple text
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
                              padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 6)),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _getDifficultyColor(level.level),
                                    _getDifficultyColor(level.level),
                                  ],
                                ),
                              ),
                              child: Text(
                                '${level.level}',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getFontSize(context, 20),
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
                            SizedBox(height: ResponsiveHelper.getSpacing(context, 2)),
                            Text(
                              '${level.columns}×${level.rows}',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(context, 10),
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
                          ] else ...[
                            // Locked level - show level number and lock icon
                            // Level number
                            Text(
                              '${level.level}',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(context, 20),
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMuted,
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
                            // Lock icon
                            Container(
                              padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 6)),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Color(0xFF4A148C), // Deep purple
                                    Color(0xFF2A2A3E), // Dark cosmic blue
                                  ],
                                ),
                                border: Border.all(
                                  color: Color(0xFF6A1B9A), // Purple border
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.lock,
                                color: Color(0xFFBA68C8), // Light purple
                                size: ResponsiveHelper.getIconSize(context, 20),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  
                    // Difficulty indicator - no animation
                    if (isUnlocked && !isCompleted)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(level.level),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
  }

  Color _getDifficultyColor(int level) {
    // Matching orb colors from the background image
    if (level <= 2) return Color(0xFFFFE66D); // Bright Yellow (like the yellow orb)
    if (level <= 4) return Color(0xFF00BCD4); // Turquoise/Cyan (like the turquoise orb)
    if (level <= 6) return Color(0xFF3B82F6); // Deep Blue (like the blue orb)
    return Color(0xFFFF6B6B); // Vibrant Red (like the red orb)
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
            child: Stack(
              children: [
                // Main content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Section with logo - with spacing
                    SizedBox(height: ResponsiveHelper.getSpacing(context, 40)),
                    Container(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: Image.asset(
                        'assets/img/logo.png',
                        width: ResponsiveHelper.getSpacing(context, 250),
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context, 24)),
                    // Level Selector Grid - after logo with spacing
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: _buildLevelGrid(context),
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(context, 24)),
                    
                    // Explore More Games Heading (centered)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: ResponsiveHelper.getIconSize(context, 16),
                              color: Color(0xFFFF6B35), // Radiant reddish-orange
                            ),
                            SizedBox(width: ResponsiveHelper.getSpacing(context, 8)),
                            Text(
                              'Explore More Games',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(context, 16),
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
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(context, 10)),
                    
                    // Mobile Games and Web Games buttons in same row (not full width)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Mobile Games button
                            Expanded(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: ResponsiveHelper.getSpacing(context, 150),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveHelper.getBorderRadius(context, 24),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFF6B35), // Radiant reddish-orange glow
                                      Color(0xFFFF8C42), // Lighter orange
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Color(0xFFFF8C42), // Orange border
                                    width: ResponsiveHelper.getSpacing(context, 1.5),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFFF6B35), // Radiant reddish-orange
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
                                        vertical: ResponsiveHelper.getSpacing(context, 12),
                                        horizontal: ResponsiveHelper.getSpacing(context, 10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.smartphone,
                                            size: ResponsiveHelper.getIconSize(context, 20),
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: ResponsiveHelper.getSpacing(context, 8)),
                                          Flexible(
                                            child: Text(
                                              'Mobile Games',
                                              style: TextStyle(
                                                fontSize: ResponsiveHelper.getFontSize(context, 16),
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
                            
                            // Web Games button
                            Expanded(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: ResponsiveHelper.getSpacing(context, 150),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveHelper.getBorderRadius(context, 24),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF4A148C), // Deep purple from sky
                                      Color(0xFF6A1B9A), // Slightly lighter purple
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Color(0xFF8A2BE2), // Purple border
                                    width: ResponsiveHelper.getSpacing(context, 1.5),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF6A1B9A), // Deep purple
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
                                        vertical: ResponsiveHelper.getSpacing(context, 10),
                                        horizontal: ResponsiveHelper.getSpacing(context, 10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.laptop,
                                            size: ResponsiveHelper.getIconSize(context, 20),
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: ResponsiveHelper.getSpacing(context, 8)),
                                          Flexible(
                                            child: Text(
                                              'Web Games',
                                              style: TextStyle(
                                                fontSize: ResponsiveHelper.getFontSize(context, 16),
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
                    
                    // Ad Banner at the bottom with proper spacing
                    Container(
                      margin: EdgeInsets.only(
                        bottom: ResponsiveHelper.getSpacing(context, 8),
                        top: ResponsiveHelper.getSpacing(context, 12),
                      ),
                      child: const AdBanner(),
                    ),
                  ],
                ),
                
                // How to Play button in top-left corner
                Positioned(
                  top: ResponsiveHelper.getSpacing(context, 2),
                  left: horizontalPadding,
                  child: Container(
                    width: ResponsiveHelper.getButtonHeight(context),
                    height: ResponsiveHelper.getButtonHeight(context),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getBorderRadius(context, 12),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF4A148C), // Deep purple
                          Color(0xFF6A1B9A), // Lighter purple
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Color(0xFFBA68C8), // Light purple border
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4A148C).withOpacity(0.6),
                          blurRadius: ResponsiveHelper.getSpacing(context, 8),
                          spreadRadius: ResponsiveHelper.getSpacing(context, 1),
                          offset: Offset(0, ResponsiveHelper.getSpacing(context, 2)),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showHowToPlay,
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getBorderRadius(context, 12),
                        ),
                        child: Icon(
                          Icons.help_outline,
                          color: Colors.white,
                          size: ResponsiveHelper.getIconSize(context, 24),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Sound toggle button in top-right corner
                Positioned(
                  top: ResponsiveHelper.getSpacing(context, 2),
                  right: horizontalPadding,
                  child: Container(
                    width: ResponsiveHelper.getButtonHeight(context),
                    height: ResponsiveHelper.getButtonHeight(context),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getBorderRadius(context, 12),
                      ),
                      gradient: LinearGradient(
                        colors: _isSoundEnabled
                            ? [
                                Color(0xFFFF6B35), // Radiant reddish-orange
                                Color(0xFFFF8C42), // Lighter orange
                              ]
                            : [
                                Color(0xFF1A1A2E), // Dark when disabled
                                Color(0xFF2A2A3E),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: _isSoundEnabled
                            ? Color(0xFFFF8C42) // Orange border
                            : AppColors.textMuted,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isSoundEnabled
                              ? Color(0xFFFF6B35).withOpacity(0.6) // Orange glow
                              : Colors.black,
                          blurRadius: ResponsiveHelper.getSpacing(context, 8),
                          spreadRadius: ResponsiveHelper.getSpacing(context, 1),
                          offset: Offset(0, ResponsiveHelper.getSpacing(context, 2)),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _toggleSound,
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getBorderRadius(context, 12),
                        ),
                        child: Icon(
                          _isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                          color: Colors.white,
                          size: ResponsiveHelper.getIconSize(context, 24),
                        ),
                      ),
                    ),
                  ),
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
      ..color = color
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
