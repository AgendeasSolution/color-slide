import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';

/// Reusable gradient action button with icon and label
class GradientActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const GradientActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = ResponsiveHelper.getBorderRadius(context, 24);
    final height = ResponsiveHelper.getButtonHeight(context) * 0.8;
    final maxWidth = ResponsiveHelper.getSpacing(context, 120);
    final primaryColor = gradientColors.first;

    return Expanded(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: primaryColor.withOpacity(0.8),
            width: ResponsiveHelper.getSpacing(context, 1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.6),
              blurRadius: ResponsiveHelper.getSpacing(context, 12),
              spreadRadius: ResponsiveHelper.getSpacing(context, 1),
              offset: Offset(0, ResponsiveHelper.getSpacing(context, 4)),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getSpacing(context, 10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: ResponsiveHelper.getIconSize(context, 16),
                    color: Colors.white,
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context, 8)),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 12.8),
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
    );
  }
}
