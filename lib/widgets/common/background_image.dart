import 'package:flutter/material.dart';

/// Reusable full-screen background image
class BackgroundImage extends StatelessWidget {
  final Widget? child;
  final String imagePath;

  const BackgroundImage({
    super.key,
    this.child,
    this.imagePath = 'assets/img/bg.png',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
