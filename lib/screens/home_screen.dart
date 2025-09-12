import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../constants/app_colors.dart';
import '../constants/game_constants.dart';
import '../widgets/common/game_dialog.dart';
import '../widgets/common/dialog_button.dart';
import '../widgets/common/ad_banner.dart';
import '../widgets/dialogs/how_to_play_content.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../models/level.dart';
import 'game_screen.dart';

/// Particle class for background animation
class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double opacity;
  double life;
  double maxLife;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.opacity,
    required this.life,
    required this.maxLife,
  });

  void update() {
    x += vx;
    y += vy;
    life -= 0.01;
    opacity = ((life / maxLife) * 0.8).clamp(0.0, 1.0);
  }

  bool get isDead => life <= 0;
}

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
  late AnimationController _particleController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;
  
  // Level selector state
  List<bool> _levelUnlocked = [];
  List<bool> _levelCompleted = [];
  bool _isLoadingProgress = true;
  
  // Particle system
  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // _initializeParticles(); // Disabled to prevent crashes
    _initializeSoundService();
    _loadProgress();
  }

  Future<void> _initializeSoundService() async {
    await SoundService.instance.init();
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
    // _particleController.dispose(); // Disabled
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
    
    // _particleController = AnimationController(
    //   duration: const Duration(seconds: 1),
    //   vsync: this,
    // )..repeat();
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    // _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(parent: _particleController, curve: Curves.linear),
    // );
  }

  void _initializeParticles() {
    _particles = List.generate(20, (index) {
      final random = math.Random();
      return Particle(
        x: random.nextDouble() * 400,
        y: random.nextDouble() * 800,
        vx: (random.nextDouble() - 0.5) * 0.3,
        vy: (random.nextDouble() - 0.5) * 0.3,
        size: random.nextDouble() * 2 + 1,
        color: [
          AppColors.neonBlue,
          AppColors.neonPink,
          AppColors.neonGreen,
          AppColors.neonPurple,
          AppColors.primary,
          AppColors.secondary,
        ][random.nextInt(6)],
        opacity: (random.nextDouble() * 0.4 + 0.3).clamp(0.0, 1.0),
        life: random.nextDouble() * 50 + 30,
        maxLife: random.nextDouble() * 50 + 30,
      );
    });
  }

  Future<void> _loadProgress() async {
    final progressService = ProgressService.instance;
    await progressService.init();
    
    final unlocked = <bool>[];
    final completed = <bool>[];
    
    for (int i = 0; i < GameLevels.levels.length; i++) {
      final level = i + 1;
      final isUnlocked = await progressService.isLevelUnlocked(level);
      final isCompleted = await progressService.isLevelCompleted(level);
      
      unlocked.add(isUnlocked);
      completed.add(isCompleted);
    }
    
    setState(() {
      _levelUnlocked = unlocked;
      _levelCompleted = completed;
      _isLoadingProgress = false;
    });
  }

  void _onLevelSelected(int level) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          selectedLevel: level,
          onLevelCompleted: () {
            // Refresh progress immediately when a level is completed
            _loadProgress();
          },
        ),
      ),
    );
  }

  void _showHowToPlay() {
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
              Navigator.of(context).pop();
            },
          ),
        ],
        showCloseButton: false,
      ),
    );
  }




  Widget _buildLevelGrid(bool isTablet) {
    if (_isLoadingProgress) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading Levels...',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
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

    return SingleChildScrollView(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 4 : 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: GameLevels.levels.length,
        itemBuilder: (context, index) {
          final level = GameLevels.levels[index];
          final isUnlocked = _levelUnlocked[index];
          final isCompleted = _levelCompleted[index];
          
          return _buildLevelCard(level, isUnlocked, isCompleted, isTablet);
        },
      ),
    );
  }

  Widget _buildLevelCard(Level level, bool isUnlocked, bool isCompleted, bool isTablet) {
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
                    : null,
                  color: isUnlocked ? null : AppColors.bgCard.withOpacity(0.2),
                border: Border.all(
                  color: isUnlocked
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.textMuted.withOpacity(0.2),
                  width: 1,
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
                    : null,
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
                                fontSize: isTablet ? 28 : 24,
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
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.neonGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.neonGreen.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'COMPLETED',
                                style: TextStyle(
                                  fontSize: isTablet ? 10 : 8,
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
                              padding: const EdgeInsets.all(8),
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
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Text(
                                '${level.level}',
                                style: TextStyle(
                                  fontSize: isTablet ? 32 : 28,
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
                            const SizedBox(height: 4),
                            Text(
                              '${level.gridSize}×${level.gridSize}',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
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
                            const SizedBox(height: 2),
                            Text(
                              _getDifficultyText(level.level),
                              style: TextStyle(
                                fontSize: isTablet ? 10 : 8,
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.bgCard.withOpacity(0.3),
                                border: Border.all(
                                  color: AppColors.textMuted.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.lock,
                                color: AppColors.textMuted,
                                size: isTablet ? 28 : 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'LOCKED',
                              style: TextStyle(
                                fontSize: isTablet ? 10 : 8,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > GameConstants.tabletBreakpoint;
    
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
                  // Disabled particle background to prevent crashes
                  // AnimatedBuilder(
                  //   animation: _particleAnimation,
                  //   builder: (context, child) {
                  //     return CustomPaint(
                  //       painter: ParticleBackgroundPainter(
                  //         particles: _particles,
                  //         animation: _particleAnimation.value,
                  //       ),
                  //       size: Size.infinite,
                  //     );
                  //   },
                  // ),
                  
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
                  
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                        vertical: 20,
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
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
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
                                            blurRadius: 30,
                                            spreadRadius: 5,
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
                                        fontSize: isTablet ? 40 : 32,
                                        fontWeight: FontWeight.w900,
                                color: Colors.white,
                                        letterSpacing: 2.5,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.5),
                                            offset: const Offset(2, 2),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                                
                                    const SizedBox(height: 8),
                                    
                                    // Subtitle
                                    Text(
                                      'Master the Art of Color',
                                      style: TextStyle(
                                        fontSize: isTablet ? 18 : 14,
                                        color: AppColors.textAccent,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.8),
                                            offset: const Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                            ],
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Level Selector Header with glassmorphism styling
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.bgCard.withOpacity(0.1),
                                  AppColors.bgCardHover.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
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
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Row(
                              children: [
                                // Select Level Title - no animation
                                Expanded(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        AppColors.gradientStart,
                                        AppColors.gradientEnd,
                                        AppColors.secondary,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: Text(
                                      'SELECT LEVEL',
                                      style: TextStyle(
                                        fontSize: isTablet ? 20 : 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.8),
                                            offset: const Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                          Shadow(
                                            color: AppColors.primary.withOpacity(0.6),
                                            blurRadius: 8,
                                            offset: const Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(width: 20),
                                
                                // How to Play Button with enhanced styling
                                Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      colors: [AppColors.primary, AppColors.gradientEnd],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.4),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _showHowToPlay,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'HOW TO PLAY',
                                      style: TextStyle(
                                        fontSize: isTablet ? 12 : 11,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Level Selector Grid
                          Expanded(
                            child: _buildLevelGrid(isTablet),
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

/// Custom painter for particle background animation
class ParticleBackgroundPainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticleBackgroundPainter({
    required this.particles,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update();
      
      if (particle.isDead) {
        // Reset particle
        final random = math.Random();
        particle.x = random.nextDouble() * size.width;
        particle.y = random.nextDouble() * size.height;
        particle.life = particle.maxLife;
        particle.opacity = 0.8;
      }
      
      // Clamp opacity to valid range
      final clampedOpacity = particle.opacity.clamp(0.0, 1.0);
      
      final paint = Paint()
        ..color = particle.color.withOpacity(clampedOpacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
