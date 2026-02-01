import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/game_constants.dart';

/// Empty cell widget for the game board
class EmptyCell extends StatelessWidget {
  const EmptyCell({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: DottedBorderPainter(
        color: Colors.white.withOpacity(0.5),
        strokeWidth: 2,
        dashPattern: const [6, 4],
        radius: GameConstants.borderRadius,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCell,
          borderRadius: BorderRadius.circular(GameConstants.borderRadius),
        ),
      ),
    );
  }
}

/// Custom painter for drawing dashed/dotted borders
class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<int> dashPattern;
  final double radius;

  DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashPattern,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    final dashWidth = dashPattern[0].toDouble();
    final dashSpace = dashPattern[1].toDouble();
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final extractPath = pathMetric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(DottedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashPattern != dashPattern ||
        oldDelegate.radius != radius;
  }
}
