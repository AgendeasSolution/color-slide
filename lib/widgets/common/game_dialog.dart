import 'package:flutter/material.dart';
import 'dart:ui';
import '../../constants/app_colors.dart';
import '../../constants/game_constants.dart';
import '../../utils/responsive_helper.dart';
import '../../services/sound_service.dart';

/// Reusable game dialog widget with enhanced styling
class GameDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget content;
  final List<Widget> actions;
  final bool showCloseButton;

  const GameDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.actions,
    this.showCloseButton = true,
  });

  @override
  State<GameDialog> createState() => _GameDialogState();
}

class _GameDialogState extends State<GameDialog> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final dialogMaxWidth = ResponsiveHelper.getDialogMaxWidth(context);
    final dialogPadding = ResponsiveHelper.getSpacing(context, 24);
    final titleFontSize = ResponsiveHelper.getFontSize(context, 28);
    final subtitleFontSize = ResponsiveHelper.getFontSize(context, 18);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: dialogMaxWidth),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.bgCard,
                      AppColors.bgCardHover,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: EdgeInsets.all(dialogPadding),
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.8,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          // Animated glow effect behind title
                          AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveHelper.getSpacing(context, 20),
                                  vertical: ResponsiveHelper.getSpacing(context, 10),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context, 20)),
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.primary.withOpacity(_glowAnimation.value * 0.3),
                                      AppColors.secondary.withOpacity(_glowAnimation.value * 0.2),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                                child: child,
                              );
                            },
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
                                widget.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.8),
                                      offset: const Offset(2, 2),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Only show subtitle if it's not empty
                          if (widget.subtitle.isNotEmpty) ...[
                            SizedBox(height: ResponsiveHelper.getSpacing(context, 16)),
                            
                            // Subtitle with enhanced styling
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.getSpacing(context, 16),
                                vertical: ResponsiveHelper.getSpacing(context, 8),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bgDarker,
                                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context, 12)),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textAccent,
                                  fontSize: subtitleFontSize,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
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
                            
                            SizedBox(height: ResponsiveHelper.getSpacing(context, 24)),
                          ] else
                            SizedBox(height: ResponsiveHelper.getSpacing(context, 16)),
                          
                          // Content without background to reduce overflow
                          widget.content,
                          
                          SizedBox(height: ResponsiveHelper.getSpacing(context, 24)),
                          
                          // Action buttons with enhanced styling
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: widget.actions.map((action) => 
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, 8)),
                                  child: action,
                                ),
                              )
                            ).toList(),
                          ),
                          
                          // Close button if enabled
                          if (widget.showCloseButton) ...[
                            SizedBox(height: ResponsiveHelper.getSpacing(context, 16)),
                            GestureDetector(
                              onTap: () {
                                SoundService.instance.playButtonTap();
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 8)),
                                decoration: BoxDecoration(
                                  color: AppColors.bgDarker,
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context, 20)),
                                  border: Border.all(
                                    color: AppColors.textMuted.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.textMuted,
                                  size: ResponsiveHelper.getIconSize(context, 20),
                                ),
                              ),
                            ),
                          ],
                        ],
                        ),
                          ),
                        ),
                      ),
                    ),
                ),
              ),
            );
        },
      ),
    );
  }
}

/// Custom painter for shimmer effect
class ShimmerPainter extends CustomPainter {
  final double animation;
  final Color color;

  ShimmerPainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shimmerWidth = size.width * 0.3;
    final shimmerX = (size.width + shimmerWidth) * animation - shimmerWidth;
    
    final shimmerRect = Rect.fromLTWH(
      shimmerX,
      0,
      shimmerWidth,
      size.height,
    );
    
    final gradient = LinearGradient(
      colors: [
        Colors.transparent,
        color,
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final shimmerPaint = Paint()
      ..shader = gradient.createShader(shimmerRect);
    
    canvas.drawRect(shimmerRect, shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}