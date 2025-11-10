import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants/app_colors.dart';

/// Animated background component with particle effects
class AnimatedBackground extends StatelessWidget {
  final AnimationController controller;

  const AnimatedBackground({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _AnimatedBackgroundPainter(
            animationValue: controller.value,
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.bgDark, AppColors.bgDarker],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedBackgroundPainter extends CustomPainter {
  final double animationValue;

  _AnimatedBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Draw animated particles
    final particleCount = 50;
    for (int i = 0; i < particleCount; i++) {
      final seed = i * 0.1;
      final x = (size.width * 0.5) +
          (size.width * 0.4) *
              math.sin(animationValue * 2 * math.pi + seed) *
              math.cos(seed * 2);
      final y = (size.height * 0.5) +
          (size.height * 0.4) *
              math.cos(animationValue * 2 * math.pi + seed) *
              math.sin(seed * 2);

      final opacity = 0.1 + (math.sin(animationValue * 2 * math.pi + seed) * 0.05);
      final radius = 2.0 + (math.sin(animationValue * 2 * math.pi + seed * 2) * 1.0);

      paint.color = AppColors.primary.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_AnimatedBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

