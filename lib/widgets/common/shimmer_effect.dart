import 'package:flutter/material.dart';

/// Shimmer effect widget for animated elements
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  const ShimmerEffect({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final position = widget.controller.value * 2 * bounds.width;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.transparent,
                Color(0x80FFFFFF),
                Colors.transparent,
              ],
              stops: const [0.4, 0.5, 0.6],
              transform: _SlidingGradientTransform(position - bounds.width),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.dx);
  final double dx;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0.0, 0.0);
  }
}
