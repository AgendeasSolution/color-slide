import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/responsive_helper.dart';

/// Reusable accent-colored icon button with glow effect
class AccentIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const AccentIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = ResponsiveHelper.getBorderRadius(context, 14);
    final size = ResponsiveHelper.getButtonHeight(context) * 0.88;
    final iconSize = ResponsiveHelper.getIconSize(context, 22);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: AppColors.gameAccent,
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gameAccent.withOpacity(0.5),
                blurRadius: 14,
                spreadRadius: 0,
                offset: const Offset(0, 0),
              ),
              BoxShadow(
                color: AppColors.gameAccent.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.black, size: iconSize),
        ),
      ),
    );
  }
}
