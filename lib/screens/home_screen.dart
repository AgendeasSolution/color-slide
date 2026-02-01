import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../utils/responsive_helper.dart';
import '../widgets/common/game_dialog.dart';
import '../widgets/common/dialog_button.dart';
import '../widgets/common/ad_banner.dart';
import '../widgets/common/accent_icon_button.dart';
import '../widgets/common/gradient_action_button.dart';
import '../widgets/common/background_image.dart';
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

  void _dismissUpdatePopup() async {
    // Mark pop-up as dismissed so it won't show again for 24 hours
    try {
      await _updateService.markPopupAsDismissed();
    } catch (e) {
      // Silently handle error
    }
    
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
          return false;
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

    // Current level = next level to play (first incomplete, or level 1 if all complete)
    final totalLevels = GameLevels.levels.length;
    int currentIndex = 0;
    for (int i = 0; i < totalLevels && i < _levelCompleted.length; i++) {
      if (!_levelCompleted[i]) {
        currentIndex = i;
        break;
      }
      currentIndex = i;
    }
    if (currentIndex >= totalLevels) currentIndex = 0;
    final level = GameLevels.levels[currentIndex];
    final isUnlocked = (currentIndex < _levelUnlocked.length) ? _levelUnlocked[currentIndex] : true;
    final isCompleted = (currentIndex < _levelCompleted.length) ? _levelCompleted[currentIndex] : false;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              maxWidth: constraints.maxWidth,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, -ResponsiveHelper.getSpacing(context, 28)),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.getSpacing(context, 200),
                      maxHeight: ResponsiveHelper.getSpacing(context, 200),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: _buildLevelCard(context, level, isUnlocked, isCompleted),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelCard(BuildContext context, Level level, bool isUnlocked, bool isCompleted) {
    const topColor = Color(0xFF33EBFF);
    const bottomColor = Color(0xFF00B8D4);
    const glowColor = Color(0xFF00E5FF);

    return GestureDetector(
      onTap: isUnlocked ? () => _onLevelSelected(level.level) : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [topColor, glowColor, bottomColor],
            stops: const [0.0, 0.5, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.6),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: glowColor.withOpacity(0.35),
              blurRadius: 32,
              spreadRadius: 4,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Top highlight edge
            Positioned(
              top: 0,
              left: 12,
              right: 12,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.6),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Level ${level.level}',
                    style: GoogleFonts.rajdhani(
                      fontSize: ResponsiveHelper.getFontSize(context, 30),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  if (isCompleted) ...[
                    SizedBox(height: ResponsiveHelper.getSpacing(context, 6)),
                    Icon(
                      Icons.check_circle,
                      color: Colors.black,
                      size: ResponsiveHelper.getIconSize(context, 28),
                    ),
                  ] else if (!isUnlocked) ...[
                    SizedBox(height: ResponsiveHelper.getSpacing(context, 6)),
                    Icon(
                      Icons.lock,
                      color: Colors.black,
                      size: ResponsiveHelper.getIconSize(context, 26),
                    ),
                  ],
                ],
              ),
            ),
            if (isUnlocked && !isCompleted)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(level.level),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(int level) {
    // Using game board ballColors for consistency
    if (level <= 2) return AppColors.ballColors['yellow']!;
    if (level <= 4) return AppColors.ballColors['cyan']!;
    if (level <= 6) return AppColors.ballColors['blue']!;
    return AppColors.ballColors['red']!;
  }


  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundImage(),
          // Content with SafeArea
          SafeArea(
            child: Stack(
              children: [
                // Main content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Section with logo – more top space, slightly larger logo
                    SizedBox(height: ResponsiveHelper.getSpacing(context, 76)),
                    Container(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: Image.asset(
                        'assets/img/logo.png',
                        width: ResponsiveHelper.getSpacing(context, 268),
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
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(context, 8)),
                    
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
                    
                    // Mobile Games and Web Games buttons
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GradientActionButton(
                              icon: Icons.smartphone,
                              label: 'Mobile Games',
                              gradientColors: [
                                AppColors.ballColors['orange']!,
                                AppColors.ballColors['red']!,
                              ],
                              onTap: _navigateToMobileGames,
                            ),
                            SizedBox(width: ResponsiveHelper.getSpacing(context, 12)),
                            GradientActionButton(
                              icon: Icons.laptop,
                              label: 'Web Games',
                              gradientColors: [
                                AppColors.ballColors['blue']!,
                                AppColors.ballColors['cyan']!,
                              ],
                              onTap: _navigateToWebGames,
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
                
                Positioned(
                  top: ResponsiveHelper.getSpacing(context, 2),
                  left: horizontalPadding,
                  child: AccentIconButton(
                    icon: Icons.help_outline,
                    onTap: _showHowToPlay,
                  ),
                ),
                Positioned(
                  top: ResponsiveHelper.getSpacing(context, 2),
                  right: horizontalPadding,
                  child: AccentIconButton(
                    icon: _isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                    onTap: _toggleSound,
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
